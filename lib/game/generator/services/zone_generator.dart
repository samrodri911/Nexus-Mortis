import 'dart:math';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

class ZoneGenerator {
  /// Genera zonas utilizando un enfoque de crecimiento aleatorio (Flood Fill).
  static List<ZoneData> generateZones(int rows, int cols, int targetZones, Random rand) {
    if (targetZones <= 1) {
      final cells = <CellPosition>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          cells.add(CellPosition(r, c));
        }
      }
      return [ZoneData(id: 'z0', name: 'Zona Unica', cells: cells)];
    }

    // Tablero vacio (null = sin zona)
    final grid = List.generate(rows, (_) => List<int?>.filled(cols, null));
    
    // Semillas
    final seeds = <CellPosition>[];
    while (seeds.length < targetZones) {
      final pos = CellPosition(rand.nextInt(rows), rand.nextInt(cols));
      if (!seeds.contains(pos)) {
        seeds.add(pos);
      }
    }

    for (int i = 0; i < seeds.length; i++) {
      grid[seeds[i].row][seeds[i].col] = i;
    }

    // Crecimiento
    bool changed = true;
    while (changed) {
      changed = false;
      final newAssignments = <CellPosition, int>{};

      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (grid[r][c] == null) {
            final neighbors = [
              if (r > 0) grid[r - 1][c],
              if (r < rows - 1) grid[r + 1][c],
              if (c > 0) grid[r][c - 1],
              if (c < cols - 1) grid[r][c + 1],
            ].whereType<int>().toList();

            if (neighbors.isNotEmpty) {
              newAssignments[CellPosition(r, c)] = neighbors[rand.nextInt(neighbors.length)];
              changed = true;
            }
          }
        }
      }

      for (final entry in newAssignments.entries) {
        grid[entry.key.row][entry.key.col] = entry.value;
      }
    }

    final zones = <ZoneData>[];
    for (int i = 0; i < targetZones; i++) {
      final cells = <CellPosition>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (grid[r][c] == i) {
            cells.add(CellPosition(r, c));
          }
        }
      }
      if (cells.isNotEmpty) {
        zones.add(ZoneData(id: 'z$i', name: 'Zona ${i + 1}', cells: cells));
      }
    }
    return zones;
  }
}
