import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_config.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Barra elegante de leyenda visual para las zonas del caso.
///
/// Permite al jugador identificar inequívocamente cada color y nombre de zona
/// de forma accesible, nítida y sin interferir con los elementos del tablero Flame.
class ZoneLegendWidget extends StatelessWidget {
  const ZoneLegendWidget({
    super.key,
    required this.zones,
  });

  final List<ZoneData> zones;

  @override
  Widget build(BuildContext context) {
    if (zones.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141419),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(15)),
          bottom: BorderSide(color: Colors.white.withAlpha(15)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(zones.length, (index) {
            final zone = zones[index];
            final color = ZoneVisualConfig.getColorForIndex(index);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: color.withAlpha(120),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withAlpha(100),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    zone.name ?? zone.id.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
