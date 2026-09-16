import 'dart:math';
import 'dart:ui' as ui;

import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

/// Evaluador de presentación geométrica para la colocación estricta de alfombras.
///
/// Reglas inmutables de diseño (V3.4):
/// 1. Geometría rectangular simple obligatoria (w >= 2, h >= 2, sin formas L, T ni pasillos).
/// 2. Bloque contiguo de al menos 2x2 celdas libres de muebles dentro de la habitación.
/// 3. Padding visual limpio y medido respecto a muros negros (adaptado a tileSize).
/// 4. Frecuencia controlada: máximo 1 alfombra en mapas normales (< 25 celdas) y 2 en grandes (>= 25).
/// 5. 0 alfombras es un resultado completamente válido si ninguna habitación cumple los requisitos.
class RugPlacementEvaluator {
  const RugPlacementEvaluator();

  /// Evalúa las zonas del tablero y retorna un mapa de `zoneId -> Rect` para las alfombras admitidas.
  Map<String, ui.Rect> evaluate({
    required int rows,
    required int columns,
    required double cellWidth,
    required double cellHeight,
    required List<ZoneData> zones,
    required Set<CellPosition> blockedCells,
    ZoneTheme? theme,
  }) {
    if (rows <= 0 || columns <= 0 || cellWidth <= 0 || cellHeight <= 0) {
      return const {};
    }

    final totalCells = rows * columns;
    final maxRugs = totalCells >= 25 ? 2 : 1;

    final candidateZones = <_RugCandidate>[];

    for (final zone in zones) {
      if (zone.cells.length < 4) continue;

      // 1. Verificación de Rectángulo Simple
      int minR = zone.cells.first.row;
      int maxR = zone.cells.first.row;
      int minC = zone.cells.first.col;
      int maxC = zone.cells.first.col;

      for (final c in zone.cells) {
        if (c.row < minR) minR = c.row;
        if (c.row > maxR) maxR = c.row;
        if (c.col < minC) minC = c.col;
        if (c.col > maxC) maxC = c.col;
      }

      final wCells = maxC - minC + 1;
      final hCells = maxR - minR + 1;

      // Rechazar pasillos estrechos o habitaciones de 1 celda de ancho/alto
      if (wCells < 2 || hCells < 2) continue;

      // Rechazar formas en L, T o geometrías irregulares
      if (zone.cells.length != wCells * hCells) continue;

      // 2. Búsqueda de Bloques 2x2 Contiguos Libres de Muebles
      final free2x2Blocks = <({int r, int c})>[];
      for (int r = minR; r < maxR; r++) {
        for (int c = minC; c < maxC; c++) {
          final c00 = CellPosition(r, c);
          final c01 = CellPosition(r, c + 1);
          final c10 = CellPosition(r + 1, c);
          final c11 = CellPosition(r + 1, c + 1);

          final isFree = !blockedCells.contains(c00) &&
              !blockedCells.contains(c01) &&
              !blockedCells.contains(c10) &&
              !blockedCells.contains(c11);

          if (isFree) {
            free2x2Blocks.add((r: r, c: c));
          }
        }
      }

      if (free2x2Blocks.isEmpty) continue;

      // Seleccionar el bloque 2x2 más cercano al centroide de la habitación
      final zoneCenterR = (minR + maxR) / 2.0;
      final zoneCenterC = (minC + maxC) / 2.0;

      free2x2Blocks.sort((a, b) {
        final distA = pow((a.r + 0.5) - zoneCenterR, 2) + pow((a.c + 0.5) - zoneCenterC, 2);
        final distB = pow((b.r + 0.5) - zoneCenterR, 2) + pow((b.c + 0.5) - zoneCenterC, 2);
        return distA.compareTo(distB);
      });

      final bestBlock = free2x2Blocks.first;

      // 3. Cálculo del Rectángulo de Alfombra con Padding Adaptativo
      // Padding visual medido: ~10% del ancho de celda (entre 5.0 y 10.0 px)
      final padX = (cellWidth * 0.10).clamp(5.0, 10.0);
      final padY = (cellHeight * 0.10).clamp(5.0, 10.0);

      final blockRect = ui.Rect.fromLTRB(
        bestBlock.c * cellWidth,
        bestBlock.r * cellHeight,
        (bestBlock.c + 2) * cellWidth,
        (bestBlock.r + 2) * cellHeight,
      );

      final rugRect = ui.Rect.fromLTRB(
        blockRect.left + padX,
        blockRect.top + padY,
        blockRect.right - padX,
        blockRect.bottom - padY,
      );

      // 4. Puntuación de Prioridad Noble
      final lowerName = (zone.name ?? '').toLowerCase();
      final isNobleName = (theme != null && zone.name != null && theme.nobleZoneNames.contains(zone.name)) ||
          lowerName.contains('salón') ||
          lowerName.contains('salon') ||
          lowerName.contains('biblio') ||
          lowerName.contains('dormitorio') ||
          lowerName.contains('escenario') ||
          lowerName.contains('palco') ||
          lowerName.contains('rosaleda') ||
          lowerName.contains('galer') ||
          lowerName.contains('bóveda') ||
          lowerName.contains('boveda');

      // Ponderación: nobleza (+100), tamaño de habitación (+10/celda), distancia al centro del mapa
      final mapCenterDist = sqrt(
        pow((zoneCenterC + 0.5) - (columns / 2), 2) +
        pow((zoneCenterR + 0.5) - (rows / 2), 2),
      );

      final priorityScore = (isNobleName ? 100.0 : 0.0) +
          (zone.cells.length * 10.0) -
          (mapCenterDist * 2.0);

      candidateZones.add(_RugCandidate(
        zoneId: zone.id,
        rect: rugRect,
        priorityScore: priorityScore,
      ));
    }

    if (candidateZones.isEmpty) {
      return const {};
    }

    // Ordenar por prioridad descendente
    candidateZones.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));

    final result = <String, ui.Rect>{};
    for (final candidate in candidateZones.take(maxRugs)) {
      result[candidate.zoneId] = candidate.rect;
    }

    return result;
  }
}

class _RugCandidate {
  const _RugCandidate({
    required this.zoneId,
    required this.rect,
    required this.priorityScore,
  });

  final String zoneId;
  final ui.Rect rect;
  final double priorityScore;
}
