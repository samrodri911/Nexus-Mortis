import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

void main() {
  const spatialEvaluator = SpatialClueEvaluator();
  const clueEvaluator = ClueEvaluator(spatialEvaluator);

  group('SpatialClueEvaluator Unit Tests', () {
    test('Evalúa adyacencia ortogonal y no adyacencia', () {
      const posA = CellPosition(1, 1);
      const posB = CellPosition(1, 2);
      const posC = CellPosition(3, 3);

      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posB, relation: SpatialRelation.adjacentTo), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posC, relation: SpatialRelation.adjacentTo), isFalse);
      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posC, relation: SpatialRelation.notAdjacentTo), isTrue);
    });

    test('Evalúa relaciones cardinales relativas', () {
      const posA = CellPosition(1, 1);
      const posB = CellPosition(1, 3);
      const posC = CellPosition(3, 1);

      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posB, relation: SpatialRelation.leftOf), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posB, targetPosition: posA, relation: SpatialRelation.rightOf), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posC, relation: SpatialRelation.above), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posC, targetPosition: posA, relation: SpatialRelation.below), isTrue);
    });

    test('Evalúa co-localización de línea (sameRow, sameColumn)', () {
      const posA = CellPosition(2, 1);
      const posB = CellPosition(2, 4);
      const posC = CellPosition(0, 1);

      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posB, relation: SpatialRelation.sameRow), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posC, relation: SpatialRelation.sameColumn), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posB, relation: SpatialRelation.differentColumn), isTrue);
      expect(spatialEvaluator.evaluate(suspectPosition: posA, targetPosition: posC, relation: SpatialRelation.differentRow), isTrue);
    });
  });

  group('ClueEvaluator Unit Tests with Zones and Objects', () {
    test('Evalúa pertenencia y exclusión de zonas correctamente', () {
      final active = {'s1': const CellPosition(0, 1)};
      final zoneMap = {const CellPosition(0, 1): 'z_biblioteca', const CellPosition(2, 2): 'z_jardin'};

      const inClue = SpatialClueData(
        id: 'c1',
        text: 's1 en biblioteca',
        relation: SpatialRelation.inZone,
        suspectId: 's1',
        targetId: 'z_biblioteca',
      );

      const notInClue = SpatialClueData(
        id: 'c2',
        text: 's1 no en jardin',
        relation: SpatialRelation.notInZone,
        suspectId: 's1',
        targetId: 'z_jardin',
      );

      expect(clueEvaluator.evaluate(inClue, active, {}, zoneMap: zoneMap), equals(ClueEvaluationResult.satisfied));
      expect(clueEvaluator.evaluate(notInClue, active, {}, zoneMap: zoneMap), equals(ClueEvaluationResult.satisfied));
    });
  });
}
