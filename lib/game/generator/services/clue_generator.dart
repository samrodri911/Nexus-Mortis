import 'dart:math';

import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/generator/services/clue_text_formatter.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Genera un banco exhaustivo de pistas verdaderas y formateadas en lenguaje natural.
class ClueGenerator {
  const ClueGenerator(
    this._random, {
    this.formatter = const ClueTextFormatter(),
  });

  final Random _random;
  final ClueTextFormatter formatter;

  List<SpatialClueData> generateAllPossibleClues({
    required SolutionData solution,
    required Map<String, CellPosition> objectPositions,
    required List<ZoneData> zones,
    required Map<String, String> suspectNames,
    required Map<String, String> objectNames,
    required String victimId,
    required String clueIdPrefix,
  }) {
    final allEntities = <String, CellPosition>{
      ...solution.suspectPositions,
      ...objectPositions,
    };

    final zoneNames = <String, String>{
      for (final z in zones) z.id: z.name ?? z.id,
    };

    final zoneCellMap = <CellPosition, String>{};
    for (final z in zones) {
      for (final c in z.cells) {
        zoneCellMap[c] = z.id;
      }
    }

    const evaluator = SpatialClueEvaluator();

    final entityIds = allEntities.keys.toList();
    final clues = <SpatialClueData>[];
    int counter = 0;

    void addClue({
      required String subjectId,
      required String targetId,
      required SpatialRelation relation,
      required ClueType type,
    }) {
      final rawClue = SpatialClueData(
        id: '${clueIdPrefix}_c_${counter++}',
        text: '',
        relation: relation,
        suspectId: subjectId,
        targetId: targetId,
        type: type,
      );

      final text = formatter.format(
        clue: rawClue,
        suspectNames: suspectNames,
        objectNames: objectNames,
        zoneNames: zoneNames,
        victimId: victimId,
      );

      clues.add(rawClue.copyWith(text: text));
    }

    // 1. Pistas de Pertenencia y Exclusión de Zonas
    for (final entry in solution.suspectPositions.entries) {
      final suspectId = entry.key;
      final pos = entry.value;
      final actualZoneId = zoneCellMap[pos];

      if (actualZoneId != null) {
        addClue(
          subjectId: suspectId,
          targetId: actualZoneId,
          relation: SpatialRelation.inZone,
          type: ClueType.zone,
        );

        // Exclusión de otras zonas
        for (final z in zones) {
          if (z.id != actualZoneId) {
            addClue(
              subjectId: suspectId,
              targetId: z.id,
              relation: SpatialRelation.notInZone,
              type: ClueType.zone,
            );
          }
        }
      }
    }

    // 2. Pistas de Relaciones Espaciales y Co-localización
    for (int i = 0; i < entityIds.length; i++) {
      for (int j = 0; j < entityIds.length; j++) {
        if (i == j) continue;

        final idA = entityIds[i];
        if (!solution.suspectPositions.containsKey(idA)) continue;

        final idB = entityIds[j];
        final posA = allEntities[idA]!;
        final posB = allEntities[idB]!;

        // Relaciones Espaciales
        for (final relation in SpatialRelation.values) {
          if (relation == SpatialRelation.inZone || relation == SpatialRelation.notInZone) {
            continue;
          }

          // Adyacencia negativa solo con objetos
          if (relation == SpatialRelation.notAdjacentTo && !objectPositions.containsKey(idB)) {
            continue;
          }

          if (evaluator.evaluate(suspectPosition: posA, targetPosition: posB, relation: relation)) {
            addClue(
              subjectId: idA,
              targetId: idB,
              relation: relation,
              type: _getTypeForRelation(relation),
            );
          }
        }
      }
    }

    clues.shuffle(_random);
    return clues;
  }

  ClueType _getTypeForRelation(SpatialRelation r) {
    switch (r) {
      case SpatialRelation.adjacentTo:
      case SpatialRelation.notAdjacentTo:
        return ClueType.adjacency;
      case SpatialRelation.sameRow:
      case SpatialRelation.sameColumn:
      case SpatialRelation.differentRow:
      case SpatialRelation.differentColumn:
        return ClueType.coLocation;
      case SpatialRelation.above:
      case SpatialRelation.below:
      case SpatialRelation.leftOf:
      case SpatialRelation.rightOf:
      case SpatialRelation.immediatelyNorthOf:
      case SpatialRelation.immediatelySouthOf:
      case SpatialRelation.immediatelyEastOf:
      case SpatialRelation.immediatelyWestOf:
        return ClueType.cardinal;
      case SpatialRelation.inZone:
      case SpatialRelation.notInZone:
        return ClueType.zone;
    }
  }
}
