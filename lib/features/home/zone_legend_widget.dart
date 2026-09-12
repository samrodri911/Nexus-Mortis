import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Barra elegante de leyenda visual para las zonas del caso.
///
/// Permite al jugador identificar inequívocamente cada habitación
/// de forma accesible, combinando icono temático, nombre y acento de color.
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
        color: const Color(0xFF11131A),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(12)),
          bottom: BorderSide(color: Colors.white.withAlpha(12)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(zones.length, (index) {
            final zone = zones[index];
            final theme = ZoneVisualTheme.fromZoneName(zone.name, index);
            final accent = theme.accentColor;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: accent.withAlpha(90),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    theme.icon,
                    size: 13,
                    color: accent,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    zone.name ?? zone.id.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withAlpha(235),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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
