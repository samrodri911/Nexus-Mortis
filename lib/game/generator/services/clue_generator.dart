import 'dart:math';

import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

/// Genera todas las pistas espaciales válidas para una solución dada.
class ClueGenerator {
  const ClueGenerator(this._random);

  final Random _random;

  List<SpatialClueData> generateAllPossibleClues({
    required SolutionData solution,
    required Map<String, CellPosition> objectPositions,
    required String clueIdPrefix,
  }) {
    final allEntities = <String, CellPosition>{
      ...solution.suspectPositions,
      ...objectPositions,
    };

    final entityIds = allEntities.keys.toList();
    final clues = <SpatialClueData>[];
    int clueIdCounter = 0;

    for (int i = 0; i < entityIds.length; i++) {
      for (int j = 0; j < entityIds.length; j++) {
        if (i == j) continue;

        final idA = entityIds[i];
        
        // Las pistas deben tener a un sospechoso como entidad primaria (según ClueEvaluator).
        if (!solution.suspectPositions.containsKey(idA)) continue;

        final idB = entityIds[j];
        final posA = allEntities[idA]!;
        final posB = allEntities[idB]!;

        if ((posA.row - posB.row).abs() + (posA.col - posB.col).abs() == 1) {
          clues.add(SpatialClueData(
            id: '${clueIdPrefix}_clue_${clueIdCounter++}',
            suspectId: idA,
            targetId: idB,
            relation: SpatialRelation.adjacentTo,
            text: 'Relación generada',
          ));
        }

        if (posA.row == posB.row && posA.col < posB.col) {
          clues.add(SpatialClueData(
            id: '${clueIdPrefix}_clue_${clueIdCounter++}',
            suspectId: idA,
            targetId: idB,
            relation: SpatialRelation.leftOf,
            text: 'Relación generada',
          ));
        }

        if (posA.row == posB.row && posA.col > posB.col) {
          clues.add(SpatialClueData(
            id: '${clueIdPrefix}_clue_${clueIdCounter++}',
            suspectId: idA,
            targetId: idB,
            relation: SpatialRelation.rightOf,
            text: 'Relación generada',
          ));
        }

        if (posA.col == posB.col && posA.row < posB.row) {
          clues.add(SpatialClueData(
            id: '${clueIdPrefix}_clue_${clueIdCounter++}',
            suspectId: idA,
            targetId: idB,
            relation: SpatialRelation.above,
            text: 'Relación generada',
          ));
        }

        if (posA.col == posB.col && posA.row > posB.row) {
          clues.add(SpatialClueData(
            id: '${clueIdPrefix}_clue_${clueIdCounter++}',
            suspectId: idA,
            targetId: idB,
            relation: SpatialRelation.below,
            text: 'Relación generada',
          ));
        }
      }
    }

    clues.shuffle(_random);
    return clues;
  }
}
