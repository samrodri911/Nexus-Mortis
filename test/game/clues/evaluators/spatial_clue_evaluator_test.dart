import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

void main() {
  const evaluator = SpatialClueEvaluator();

  group('SpatialClueEvaluator - adjacentTo (Von Neumann)', () {
    const center = CellPosition(2, 2);

    test('Arriba es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(1, 2),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isTrue,
      );
    });

    test('Abajo es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(3, 2),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isTrue,
      );
    });

    test('Izquierda es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(2, 1),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isTrue,
      );
    });

    test('Derecha es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(2, 3),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isTrue,
      );
    });

    test('Diagonal superior izquierda NO es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(1, 1),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isFalse,
      );
    });

    test('Diagonal inferior derecha NO es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(3, 3),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isFalse,
      );
    });

    test('La misma celda NO es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: center,
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isFalse,
      );
    });

    test('A 2 pasos de distancia NO es adyacente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(2, 4),
          targetPosition: center,
          relation: SpatialRelation.adjacentTo,
        ),
        isFalse,
      );
    });
  });

  group('SpatialClueEvaluator - Relaciones Cardinales Globales', () {
    const target = CellPosition(2, 2);

    test('leftOf funciona correctamente', () {
      // Izquierda absoluta (misma fila o distinta fila)
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(0, 1),
          targetPosition: target,
          relation: SpatialRelation.leftOf,
        ),
        isTrue,
      );
      
      // Derecha
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(2, 3),
          targetPosition: target,
          relation: SpatialRelation.leftOf,
        ),
        isFalse,
      );
    });

    test('rightOf funciona correctamente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(2, 5),
          targetPosition: target,
          relation: SpatialRelation.rightOf,
        ),
        isTrue,
      );
      
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(2, 1),
          targetPosition: target,
          relation: SpatialRelation.rightOf,
        ),
        isFalse,
      );
    });

    test('above funciona correctamente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(0, 2),
          targetPosition: target,
          relation: SpatialRelation.above,
        ),
        isTrue,
      );
      
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(4, 2),
          targetPosition: target,
          relation: SpatialRelation.above,
        ),
        isFalse,
      );
    });

    test('below funciona correctamente', () {
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(4, 0),
          targetPosition: target,
          relation: SpatialRelation.below,
        ),
        isTrue,
      );
      
      expect(
        evaluator.evaluate(
          suspectPosition: const CellPosition(1, 2),
          targetPosition: target,
          relation: SpatialRelation.below,
        ),
        isFalse,
      );
    });
  });
}
