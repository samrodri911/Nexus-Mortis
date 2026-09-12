import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:nexus_mortis/game/board/components/architectural_furniture_renderer.dart';
import 'package:nexus_mortis/game/board/models/cell_annotation.dart';
import 'package:nexus_mortis/game/board/models/cell_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';

/// Componente visual de una celda del tablero.
///
/// Responsabilidades:
/// - Delegar el dibujo de objetos lógicos a [ArchitecturalFurnitureRenderer].
/// - Renderizar confirmación como medallón/ficha de evidencia detective con alta jerarquía.
/// - Renderizar candidatos en carbón nítido con cápsula azul detective para el sospechoso activo.
/// - Renderizar marcas de eliminación (X manual roja y Auto-X lápiz).
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

  static const _furnitureRenderer = ArchitecturalFurnitureRenderer();

  // Jerarquía visual sobre plano claro arquitectónico
  // Manual X: rojo carmín nítido
  static const _colorEliminatedX = ui.Color(0xFFC62828);
  // Auto X: lápiz de grafito suave
  static const _colorAutoX = ui.Color(0xFF8C8D94);

  // Ficha de evidencia confirmada (medallón detective)
  static const _colorConfirmedMedalBg = ui.Color(0xFF1B1C22);
  static const _colorConfirmedOuterRim = ui.Color(0xFFC5A059);
  static const _colorConfirmedInnerRim = ui.Color(0xFFE5C88A);
  static const _colorConfirmedText = ui.Color(0xFFFAF6EE);
  static const _colorConfirmedBadgeBg = ui.Color(0xFF1B5E20);
  static const _colorConfirmedBadgeText = ui.Color(0xFFE8F5E9);

  // Candidatos sobre plano claro
  static const _colorCandidateText = ui.Color(0xFF2C2D35); // Carbón nítido
  static const _colorCandidateActiveBox = ui.Color(0xFF1565C0); // Azul detective
  static const _colorCandidateActiveBorder = ui.Color(0xFF64B5F6);
  static const _colorCandidateActiveText = ui.Color(0xFFFFFFFF);

  @override
  void render(ui.Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // 1. Celdas Bloqueadas (Objetos lógicos del puzzle)
    // Se renderizan directamente sobre la textura del suelo de la habitación
    if (cellData.isBlocked) {
      _furnitureRenderer.render(
        canvas: canvas,
        objectId: cellData.objectId ?? '',
        objectLabel: objectLabel,
        cellRect: ui.Rect.fromLTWH(0, 0, w, h),
        tileSize: min(w, h),
      );
      return;
    }

    // 2. Celda Confirmada (Máxima prioridad visual - Ficha de evidencia)
    if (cellData.confirmedSuspectId != null) {
      _renderConfirmed(canvas, w, h);
      return;
    }

    // 3. Auto-X (visual sutil, ayuda del sistema)
    if (cellData.isAutoEliminated) {
      _renderAutoX(canvas, w, h);
    }

    // 4. Marca X Manual (deducción del jugador)
    if (cellData.annotation == CellAnnotation.eliminated) {
      _renderEliminatedX(canvas, w, h);
    }

    // 5. Candidatos (Mini-cuadrícula de alta legibilidad)
    if (cellData.isFree && cellData.candidateSuspectIds.isNotEmpty) {
      _renderCandidates(canvas, w, h);
    }
  }

  /// Dibuja la ficha/medallón de evidencia detective con inicial y checkmark.
  void _renderConfirmed(ui.Canvas canvas, double w, double h) {
    final suspectId = cellData.confirmedSuspectId!;
    final suspect = allSuspects.firstWhere(
      (s) => s.id == suspectId,
      orElse: () => SuspectData(id: suspectId, name: '?'),
    );
    final initial = suspect.name.isNotEmpty ? suspect.name[0].toUpperCase() : '?';

    final center = ui.Offset(w / 2, h / 2);
    final radius = min(w, h) * 0.38;

    // Sombra suave proyectada del medallón
    canvas.drawCircle(
      center + const ui.Offset(0, 2.0),
      radius,
      ui.Paint()..color = const ui.Color(0x38000000),
    );

    // Fondo oscuro profundo del medallón
    canvas.drawCircle(
      center,
      radius,
      ui.Paint()..color = _colorConfirmedMedalBg,
    );

    // Borde exterior dorado noble
    canvas.drawCircle(
      center,
      radius,
      ui.Paint()
        ..color = _colorConfirmedOuterRim
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // Anillo interior fino dorado
    canvas.drawCircle(
      center,
      radius - 2.5,
      ui.Paint()
        ..color = _colorConfirmedInnerRim
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Letra inicial del sospechoso en el centro
    final fontSize = radius * 1.05;
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: fontSize),
    )
      ..pushStyle(ui.TextStyle(
        color: _colorConfirmedText,
        fontWeight: ui.FontWeight.bold,
        fontFamily: 'Roboto',
      ))
      ..addText(initial);

    final p = pb.build()..layout(ui.ParagraphConstraints(width: radius * 2));
    canvas.drawParagraph(p, ui.Offset(center.dx - radius, center.dy - (p.height / 2)));

    // Badge pequeño de verificación (checkmark ✓) en la esquina inferior derecha del medallón
    final badgeRadius = radius * 0.36;
    final badgeCenter = ui.Offset(
      center.dx + radius * 0.65,
      center.dy + radius * 0.65,
    );

    // Sombra del badge
    canvas.drawCircle(
      badgeCenter + const ui.Offset(0, 1.0),
      badgeRadius,
      ui.Paint()..color = const ui.Color(0x40000000),
    );
    // Fondo esmeralda/verde detective
    canvas.drawCircle(
      badgeCenter,
      badgeRadius,
      ui.Paint()..color = _colorConfirmedBadgeBg,
    );
    // Borde fino del badge
    canvas.drawCircle(
      badgeCenter,
      badgeRadius,
      ui.Paint()
        ..color = _colorConfirmedInnerRim
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Símbolo ✓
    final checkPb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: badgeRadius * 1.3),
    )
      ..pushStyle(ui.TextStyle(
        color: _colorConfirmedBadgeText,
        fontWeight: ui.FontWeight.bold,
      ))
      ..addText('✓');

    final checkP = checkPb.build()..layout(ui.ParagraphConstraints(width: badgeRadius * 2));
    canvas.drawParagraph(
      checkP,
      ui.Offset(badgeCenter.dx - badgeRadius, badgeCenter.dy - (checkP.height / 2)),
    );
  }

  /// Dibuja la X manual del jugador (rojo carmín nítido).
  void _renderEliminatedX(ui.Canvas canvas, double w, double h) {
    final paint = ui.Paint()
      ..color = _colorEliminatedX
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeWidth = 2.4;
    final padding = min(w, h) * 0.22;
    canvas.drawLine(ui.Offset(padding, padding), ui.Offset(w - padding, h - padding), paint);
    canvas.drawLine(ui.Offset(w - padding, padding), ui.Offset(padding, h - padding), paint);
  }

  /// Dibuja la Auto-X generada por el sistema (lápiz de grafito).
  void _renderAutoX(ui.Canvas canvas, double w, double h) {
    final paint = ui.Paint()
      ..color = _colorAutoX
      ..style = ui.PaintingStyle.stroke
      ..strokeCap = ui.StrokeCap.round
      ..strokeWidth = 1.4;
    final padding = min(w, h) * 0.28;
    canvas.drawLine(ui.Offset(padding, padding), ui.Offset(w - padding, h - padding), paint);
    canvas.drawLine(ui.Offset(w - padding, padding), ui.Offset(padding, h - padding), paint);
  }

  void _renderCandidates(ui.Canvas canvas, double w, double h) {
    final activeId = getActiveSuspectId();
    final count = allSuspects.length;
    if (count == 0) return;

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

      // Si es el sospechoso activo: cápsula azul detective de alta visibilidad
      if (isActive) {
        final boxSize = min(slotW, slotH) * 0.78;
        final boxRect = ui.Rect.fromCenter(
          center: ui.Offset(cx, cy),
          width: boxSize,
          height: boxSize,
        );
        final rrect = ui.RRect.fromRectAndRadius(boxRect, const ui.Radius.circular(3.5));

        // Sombra de la cápsula activa
        canvas.drawRRect(
          ui.RRect.fromRectAndRadius(boxRect.translate(0, 1), const ui.Radius.circular(3.5)),
          ui.Paint()..color = const ui.Color(0x33000000),
        );

        // Relleno azul detective
        canvas.drawRRect(
          rrect,
          ui.Paint()..color = _colorCandidateActiveBox,
        );

        // Borde fino de brillo
        canvas.drawRRect(
          rrect,
          ui.Paint()
            ..color = _colorCandidateActiveBorder
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }

      // Dibujar la inicial centrada en su slot
      _renderInitial(
        canvas: canvas,
        text: initial,
        cx: cx,
        cy: cy,
        color: isActive ? _colorCandidateActiveText : _colorCandidateText,
        weight: isActive ? ui.FontWeight.w700 : ui.FontWeight.w600,
        fontSize: min(slotW, slotH) * 0.52,
      );
    }
  }

  void _renderInitial({
    required ui.Canvas canvas,
    required String text,
    required double cx,
    required double cy,
    required ui.Color color,
    required ui.FontWeight weight,
    required double fontSize,
  }) {
    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(textAlign: ui.TextAlign.center, fontSize: fontSize),
    )
      ..pushStyle(ui.TextStyle(
        color: color,
        fontWeight: weight,
        fontFamily: 'Roboto',
      ))
      ..addText(text);

    final paragraph = pb.build()..layout(const ui.ParagraphConstraints(width: 40));
    canvas.drawParagraph(paragraph, ui.Offset(cx - 20, cy - (paragraph.height / 2)));
  }

  @override
  void onTapUp(TapUpEvent event) => onTapped(cellData.row, cellData.col);
}
