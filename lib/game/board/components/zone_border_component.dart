import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Canvas;
import 'dart:ui';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

class ZoneBorderComponent extends PositionComponent {
  ZoneBorderComponent({
    required this.controller,
    required super.size,
  });

  final BoardController controller;

  String? _getZoneId(int r, int c) {
    for (final zone in controller.zones) {
      if (zone.cells.any((pos) => pos.row == r && pos.col == c)) {
        return zone.id;
      }
    }
    return null;
  }

  @override
  void render(Canvas canvas) {
    final rows = controller.cells.length;
    final cols = controller.cells[0].length;
    final cellW = size.x / cols;
    final cellH = size.y / rows;

    final paint = Paint()
      ..color = const Color(0xFF6B45A8) // Color para el borde de zona (Púrpura misterioso)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final currentZone = _getZoneId(r, c);
        if (currentZone == null) continue;

        final x = c * cellW;
        final y = r * cellH;

        // Borde superior
        if (r == 0 || _getZoneId(r - 1, c) != currentZone) {
          canvas.drawLine(Offset(x, y), Offset(x + cellW, y), paint);
        }
        // Borde inferior
        if (r == rows - 1 || _getZoneId(r + 1, c) != currentZone) {
          canvas.drawLine(Offset(x, y + cellH), Offset(x + cellW, y + cellH), paint);
        }
        // Borde izquierdo
        if (c == 0 || _getZoneId(r, c - 1) != currentZone) {
          canvas.drawLine(Offset(x, y), Offset(x, y + cellH), paint);
        }
        // Borde derecho
        if (c == cols - 1 || _getZoneId(r, c + 1) != currentZone) {
          canvas.drawLine(Offset(x + cellW, y), Offset(x + cellW, y + cellH), paint);
        }
      }
    }
  }
}
