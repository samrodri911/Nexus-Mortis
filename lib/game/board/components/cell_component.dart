import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:nexus_mortis/game/board/models/cell_annotation.dart';
import 'package:nexus_mortis/game/board/models/cell_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';

/// Componente visual de una celda del tablero.
///
/// Responsabilidades:
/// - Renderizar su celda (fondos, bloqueos, X globales, candidatos).
/// - Calcular la mini-cuadrícula de iniciales de forma dinámica (sqrt).
/// - Notificar al padre cuando el jugador toca la celda.
class CellComponent extends PositionComponent with TapCallbacks {
  CellComponent({
    required this.cellData,
    required this.onTapped,
    required this.getActiveSuspectId,
    required this.allSuspects,
    this.objectLabel,
    required super.position,
    required super.size,
  });

  final CellData cellData;
  final void Function(int row, int col) onTapped;
  final String? Function() getActiveSuspectId;
  final List<SuspectData> allSuspects;
  final String? objectLabel;

  static const _colorBorder = ui.Color(0xFF2E2E3E);
  static const _colorBlockedBg = ui.Color(0xFF0F0F14); // Más oscuro para bloqueadas
  static const _colorBlockedStripe = ui.Color(0xFF16161D);
  static const _colorFreeBg = ui.Color(0xFF1A1A28);
  
  static const _colorEliminatedX = ui.Color(0xFF884444);
  static const _colorObjectText = ui.Color(0xFF55556A);
  
  // Colores para las iniciales
  static const _colorCandidateText = ui.Color(0xFFAAAAAA);
  static const _colorCandidateActiveText = ui.Color(0xFFFFFFFF);
  static const _colorCandidateActiveBox = ui.Color(0xFF444477);
  static const _colorCandidateActiveBoxBorder = ui.Color(0xFF8888DD);

  @override
  void render(ui.Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // 1. Dibujar el fondo
    _renderBackground(canvas, w, h);

    // 2. Celdas Bloqueadas (Objetos)
    if (cellData.isBlocked && objectLabel != null) {
      _renderCenteredText(canvas, objectLabel!, w, h, _colorObjectText, 11);
      return; // No se dibuja nada más en celdas bloqueadas
    }

    // 3. Marca X Global
    if (cellData.annotation == CellAnnotation.eliminated) {
      _renderEliminatedX(canvas, w, h);
    }

    // 4. Candidatos (Mini-cuadrícula)
    if (cellData.isFree && cellData.candidateSuspectIds.isNotEmpty) {
      _renderCandidates(canvas, w, h);
    }
  }

  void _renderBackground(ui.Canvas canvas, double w, double h) {
    // Fondo base
    canvas.drawRect(
      ui.Rect.fromLTWH(1, 1, w - 2, h - 2),
      ui.Paint()..color = cellData.isBlocked ? _colorBlockedBg : _colorFreeBg,
    );

    // Patrón de rayas sutil para celdas bloqueadas
    if (cellData.isBlocked) {
      final stripePaint = ui.Paint()
        ..color = _colorBlockedStripe
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2;
      for (double i = -h; i < w; i += 10) {
        canvas.drawLine(ui.Offset(i, 0), ui.Offset(i + h, h), stripePaint);
      }
    }

    // Borde
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, w, h),
      ui.Paint()
        ..color = _colorBorder
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _renderEliminatedX(ui.Canvas canvas, double w, double h) {
    final paint = ui.Paint()
      ..color = _colorEliminatedX
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2;
    
    const padding = 12.0;
    canvas.drawLine(const ui.Offset(padding, padding), ui.Offset(w - padding, h - padding), paint);
    canvas.drawLine(ui.Offset(w - padding, padding), ui.Offset(padding, h - padding), paint);
  }

  void _renderCandidates(ui.Canvas canvas, double w, double h) {
    final activeId = getActiveSuspectId();
    final count = allSuspects.length;
    
    // Cálculo dinámico para la cuadrícula interna (Ajuste 1)
    final cols = sqrt(count).ceil();
    final rows = (count / cols).ceil();

    final slotW = w / cols;
    final slotH = h / rows;

    for (var i = 0; i < count; i++) {
      final suspect = allSuspects[i];
      
      // Solo dibujar si es un candidato real
      if (!cellData.candidateSuspectIds.contains(suspect.id)) {
        continue;
      }

      final row = i ~/ cols;
      final col = i % cols;

      final cx = col * slotW + (slotW / 2);
      final cy = row * slotH + (slotH / 2);

      final isActive = suspect.id == activeId;
      final initial = suspect.name.isNotEmpty ? suspect.name[0].toUpperCase() : '?';

      // Ajuste 2: Recuadro distintivo para el sospechoso activo
      if (isActive) {
        final boxSize = min(slotW, slotH) * 0.7;
        final boxRect = ui.Rect.fromCenter(
          center: ui.Offset(cx, cy), 
          width: boxSize, 
          height: boxSize
        );
        
        canvas.drawRect(boxRect, ui.Paint()..color = _colorCandidateActiveBox);
        canvas.drawRect(
          boxRect, 
          ui.Paint()
            ..color = _colorCandidateActiveBoxBorder
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1
        );
      }

      // Dibujar la inicial centrada en su slot
      _renderInitial(
        canvas, 
        initial, 
        cx, 
        cy, 
        isActive ? _colorCandidateActiveText : _colorCandidateText,
        isActive ? ui.FontWeight.bold : ui.FontWeight.normal
      );
    }
  }

  void _renderCenteredText(ui.Canvas canvas, String text, double w, double h, ui.Color color, double fontSize) {
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: fontSize),
    )
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);

    final paragraph = pb.build()..layout(ui.ParagraphConstraints(width: w - 8));
    canvas.drawParagraph(paragraph, ui.Offset(4, (h - paragraph.height) / 2));
  }

  void _renderInitial(ui.Canvas canvas, String text, double cx, double cy, ui.Color color, ui.FontWeight weight) {
    // Un tamaño relativo al tamaño de la celda
    final fontSize = size.x * 0.15; 
    
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: fontSize),
    )
      ..pushStyle(ui.TextStyle(
        color: color, 
        fontWeight: weight,
        // Usar una fuente monospace o similar asegura proporciones
        fontFamily: 'Roboto', 
      ))
      ..addText(text);

    final paragraph = pb.build()..layout(const ui.ParagraphConstraints(width: 40));
    canvas.drawParagraph(paragraph, ui.Offset(cx - 20, cy - (paragraph.height / 2)));
  }

  @override
  void onTapUp(TapUpEvent event) => onTapped(cellData.row, cellData.col);
}
