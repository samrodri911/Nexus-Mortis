import 'package:flutter/painting.dart';
import 'package:flame/components.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_config.dart';

/// Componente encargado de renderizar visualmente las zonas del caso con
/// un tinte sutil y bordes distintivos de contraste elegante (noir/detective).
class ZoneBorderComponent extends PositionComponent {
  ZoneBorderComponent({
    required this.controller,
    required super.size,
  });

  final BoardController controller;

  int? _getZoneIndex(int r, int c) {
    for (int i = 0; i < controller.zones.length; i++) {
      if (controller.zones[i].cells.any((pos) => pos.row == r && pos.col == c)) {
        return i;
      }
    }
    return null;
  }

  @override
  void render(Canvas canvas) {
    if (controller.cells.isEmpty || controller.cells[0].isEmpty) return;

    final rows = controller.cells.length;
    final cols = controller.cells[0].length;
    final cellW = size.x / cols;
    final cellH = size.y / rows;

    // 1. Renderizar tinte sutil de fondo por zona
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final zoneIdx = _getZoneIndex(r, c);
        if (zoneIdx == null) continue;

        final baseColor = ZoneVisualConfig.getColorForIndex(zoneIdx);
        final tintPaint = Paint()
          ..color = baseColor.withAlpha(24)
          ..style = PaintingStyle.fill;

        final x = c * cellW;
        final y = r * cellH;
        canvas.drawRect(Rect.fromLTWH(x + 1, y + 1, cellW - 2, cellH - 2), tintPaint);
      }
    }

    // 2. Renderizar bordes perimetrales nítidos de cada zona
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final currentZone = _getZoneIndex(r, c);
        if (currentZone == null) continue;

        final baseColor = ZoneVisualConfig.getColorForIndex(currentZone);
        final paint = Paint()
          ..color = baseColor.withAlpha(230)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;

        final x = c * cellW;
        final y = r * cellH;

        // Borde superior
        if (r == 0 || _getZoneIndex(r - 1, c) != currentZone) {
          canvas.drawLine(Offset(x, y), Offset(x + cellW, y), paint);
        }
        // Borde inferior
        if (r == rows - 1 || _getZoneIndex(r + 1, c) != currentZone) {
          canvas.drawLine(Offset(x, y + cellH), Offset(x + cellW, y + cellH), paint);
        }
        // Borde izquierdo
        if (c == 0 || _getZoneIndex(r, c - 1) != currentZone) {
          canvas.drawLine(Offset(x, y), Offset(x, y + cellH), paint);
        }
        // Borde derecho
        if (c == cols - 1 || _getZoneIndex(r, c + 1) != currentZone) {
          canvas.drawLine(Offset(x + cellW, y), Offset(x + cellW, y + cellH), paint);
        }
      }
    }
  }
}
