import 'dart:math';

import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

class SolutionGenerator {
  const SolutionGenerator(this._random);

  final Random _random;

  ({SolutionData solution, Map<String, CellPosition> objectPositions}) generateSolution({
    required int rows,
    required int columns,
    required List<SuspectData> suspects,
    required List<ObjectData> objects,
    required List<ZoneData> zones,
    required String victimId,
    required String killerId,
  }) {
    if (suspects.length > rows || suspects.length > columns) {
      throw ArgumentError('Too many suspects for the grid dimensions (Murdoku rule).');
    }

    final zoneMap = <CellPosition, ZoneData>{};
    for (final z in zones) {
      for (final c in z.cells) {
        zoneMap[c] = z;
      }
    }

    // Try a few times to find a valid assignment that satisfies all constraints
    for (int attempt = 0; attempt < 50; attempt++) {
      final suspectPositions = <String, CellPosition>{};
      final usedRows = <int>{};
      final usedCols = <int>{};
      final zoneCounts = <String, int>{for (final z in zones) z.id: 0};

      // Helper for placing an entity
      bool tryPlace(String id, bool Function(CellPosition) condition) {
        final available = <CellPosition>[];
        for (int r = 0; r < rows; r++) {
          if (usedRows.contains(r)) continue;
          for (int c = 0; c < columns; c++) {
            if (usedCols.contains(c)) continue;
            final pos = CellPosition(r, c);
            if (condition(pos)) {
              available.add(pos);
            }
          }
        }
        if (available.isEmpty) return false;

        // Balancear distribución entre las opciones disponibles
        available.sort((a, b) {
          final countA = zoneCounts[zoneMap[a]?.id ?? ''] ?? 0;
          final countB = zoneCounts[zoneMap[b]?.id ?? ''] ?? 0;
          return countA.compareTo(countB);
        });

        // Seleccionar de las que tienen menor ocupación
        final minCount = zoneCounts[zoneMap[available.first]?.id ?? ''] ?? 0;
        final bestCandidates = available.where(
          (p) => (zoneCounts[zoneMap[p]?.id ?? ''] ?? 0) <= minCount + 1,
        ).toList();

        final pos = bestCandidates[_random.nextInt(bestCandidates.length)];
        suspectPositions[id] = pos;
        usedRows.add(pos.row);
        usedCols.add(pos.col);
        final zId = zoneMap[pos]?.id;
        if (zId != null) {
          zoneCounts[zId] = (zoneCounts[zId] ?? 0) + 1;
        }
        return true;
      }

      // 1. Place Victim
      if (!tryPlace(victimId, (p) => true)) continue;
      final victimZone = zoneMap[suspectPositions[victimId]!];

      // 2. Place Killer (MUST be in victimZone)
      if (!tryPlace(killerId, (p) => zoneMap[p] == victimZone)) continue;

      // 3. Place other innocents (MUST NOT be in victimZone)
      bool allPlaced = true;
      for (final s in suspects) {
        if (s.id == victimId || s.id == killerId) continue;
        if (!tryPlace(s.id, (p) => zoneMap[p] != victimZone)) {
          allPlaced = false;
          break;
        }
      }

      if (!allPlaced) continue;

      // Found a valid combination
      final availableForObjects = <CellPosition>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < columns; c++) {
          final pos = CellPosition(r, c);
          if (!suspectPositions.values.contains(pos)) {
            availableForObjects.add(pos);
          }
        }
      }
      availableForObjects.shuffle(_random);

      final objectPositions = <String, CellPosition>{};
      for (int i = 0; i < objects.length; i++) {
        objectPositions[objects[i].id] = availableForObjects[i];
      }

      return (
        solution: SolutionData(suspectPositions: suspectPositions),
        objectPositions: objectPositions,
      );
    }

    throw Exception('Could not find a valid solution satisfying Murdoku and Zone rules.');
  }
}
