import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';
import 'package:nexus_mortis/game/visual/models/visual_map_plan.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';
import 'package:nexus_mortis/game/visual/services/visual_map_builder.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';

/// Pestaña de previsualización procedural del tablero.
///
/// Muestra un tablero de muestra generado con [VisualMapBuilder]
/// para verificar la coherencia entre arquetipos, suelos, alfombras y sprites.
class BoardVisualPreviewTab extends StatelessWidget {
  const BoardVisualPreviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    const zones = [
      ZoneData(
        id: 'z0',
        name: 'Biblioteca',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1),
          CellPosition(1, 0), CellPosition(1, 1),
        ],
      ),
      ZoneData(
        id: 'z1',
        name: 'Cocina',
        cells: [
          CellPosition(0, 2), CellPosition(0, 3),
          CellPosition(1, 2), CellPosition(1, 3),
        ],
      ),
      ZoneData(
        id: 'z2',
        name: 'Salón Principal',
        cells: [
          CellPosition(2, 0), CellPosition(2, 1),
          CellPosition(3, 0), CellPosition(3, 1),
        ],
      ),
      ZoneData(
        id: 'z3',
        name: 'Dormitorio',
        cells: [
          CellPosition(2, 2), CellPosition(2, 3),
          CellPosition(3, 2), CellPosition(3, 3),
        ],
      ),
    ];

    final plan = VisualMapBuilder.build(
      zones: zones,
      blockedCells: {const CellPosition(1, 2)},
      caseSeed: 42,
      theme: ZoneTheme.classicMansion,
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0EBE1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4A453E), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: CustomPaint(
                painter: _MiniBoardPainter(
                  zones: zones,
                  plan: plan,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBoardPainter extends CustomPainter {
  _MiniBoardPainter({
    required this.zones,
    required this.plan,
  });

  final List<ZoneData> zones;
  final VisualMapPlan plan;

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 4;
    const cols = 4;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // 1. Dibujar habitaciones y suelos
    final zoneColors = {
      'z0': const Color(0xFFEFE6DC), // Roble claro cálido
      'z1': const Color(0xFFF5F3EE), // Baldosa suave
      'z2': const Color(0xFFECE6DE), // Salón
      'z3': const Color(0xFFF3ECE6), // Marfil cálido
    };

    for (final zone in zones) {
      final color = zoneColors[zone.id] ?? const Color(0xFFEAEAEA);
      final paint = Paint()..color = color;

      for (final cell in zone.cells) {
        final rect = Rect.fromLTWH(cell.col * cellW, cell.row * cellH, cellW, cellH);
        canvas.drawRect(rect, paint);
      }

      // Nombre de zona en el centro de la habitación
      final visualPlan = plan.forZone(zone.id);
      if (visualPlan != null) {
        final centerCell = zone.cells.first;
        final tp = TextPainter(
          text: TextSpan(
            text: zone.name ?? '',
            style: const TextStyle(
              color: Color(0x77000000),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(centerCell.col * cellW + 6, centerCell.row * cellH + 6),
        );
      }
    }

    // 2. Muros interiores (negro arquitectónico)
    final wallPaint = Paint()
      ..color = const Color(0xFF262422)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    // Líneas divisorias de zonas 2x2
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), wallPaint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), wallPaint);

    // 3. Dibujar sprites con sombras de contacto si están disponibles (ej. mesa y silla)
    final tableSprite = AtlasManager.instance.getSprite(
      FurnitureCatalog.kitchenAtlasId,
      'table_01',
    );
    final chairSprite = AtlasManager.instance.getSprite(
      FurnitureCatalog.kitchenAtlasId,
      'chair_01',
    );

    final shadowPaint = Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    if (tableSprite != null) {
      final cellRect = Rect.fromLTWH(0 * cellW, 0 * cellH, cellW, cellH);
      final dest = SpriteLayoutHelper.calculateDestRect(
        cellRect: cellRect,
        srcWidth: tableSprite.srcSize.x,
        srcHeight: tableSprite.srcSize.y,
        fillRatio: 0.75,
      );
      final shadow = SpriteLayoutHelper.calculateContactShadowRect(
        destRect: dest,
        cellRect: cellRect,
      );
      canvas.drawOval(shadow, shadowPaint);
      tableSprite.renderRect(canvas, dest);
    }

    if (chairSprite != null) {
      final cellRect = Rect.fromLTWH(2 * cellW, 1 * cellH, cellW, cellH);
      final dest = SpriteLayoutHelper.calculateDestRect(
        cellRect: cellRect,
        srcWidth: chairSprite.srcSize.x,
        srcHeight: chairSprite.srcSize.y,
        fillRatio: 0.70,
      );
      final shadow = SpriteLayoutHelper.calculateContactShadowRect(
        destRect: dest,
        cellRect: cellRect,
      );
      canvas.drawOval(shadow, shadowPaint);
      chairSprite.renderRect(canvas, dest);
    }
  }

  @override
  bool shouldRepaint(_MiniBoardPainter oldDelegate) => false;
}
