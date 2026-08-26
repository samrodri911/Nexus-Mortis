import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  final solver = PuzzleSolver();

  // ─────────────────────────────────────────────────────────────────────────
  // Test 1 — DemoCase001 (puzzle válido y único)
  // ─────────────────────────────────────────────────────────────────────────
  group('PuzzleSolver — DemoCase001', () {
    test('Debe encontrar exactamente 1 solución', () {
      final result = solver.solve(demoCase001, maxSolutions: 2);

      expect(result.solutionCount, equals(1),
          reason: 'DemoCase001 debe tener solución única');
      expect(result.isUnique, isTrue);
      expect(result.isImpossible, isFalse);
      expect(result.isAmbiguous, isFalse);
    });

    test('La solución encontrada debe coincidir con la solución conocida', () {
      final result = solver.solve(demoCase001, maxSolutions: 2);

      expect(result.solutionCount, equals(1));
      final found = result.solutions.first.suspectPositions;

      for (final suspect in demoCase001.suspects) {
        expect(found[suspect.id], equals(demoCase001.solution.suspectPositions[suspect.id]));
      }
    });

    test('Debe visitar más de 0 nodos', () {
      final result = solver.solve(demoCase001);
      expect(result.visitedNodes, greaterThan(0));
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 2 — Puzzle sin pistas (ambiguo: múltiples soluciones)
  // ─────────────────────────────────────────────────────────────────────────
  group('PuzzleSolver — Caso sin pistas', () {
    final caseSinPistas = CaseData(
      id: 'case_no_clues',
      title: 'Sin Pistas',
      description: 'Tablero sin restricciones.',
      difficulty: PuzzleDifficulty.easy,
      boardRows: 3,
      boardColumns: 3,
      suspects: const [
        SuspectData(id: 'a', name: 'A'),
        SuspectData(id: 'b', name: 'B'),
      ],
      victimId: 'dummy1', killerId: 'dummy2', zones: const [], placedObjects: const [],
      clues: const [],
      solution: const SolutionData(suspectPositions: {}),
    );

    test('Debe encontrar más de 1 solución (ambiguo)', () {
      final result = solver.solve(caseSinPistas, maxSolutions: 2);

      expect(result.solutionCount, greaterThan(1),
          reason: 'Sin pistas, cualquier configuración es válida');
      expect(result.isAmbiguous, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 3 — Puzzle imposible (pistas contradictorias)
  // ─────────────────────────────────────────────────────────────────────────
  group('PuzzleSolver — Caso imposible', () {
    // Pistas: Juan debe estar arriba de la cama Y abajo de la cama
    // simultáneamente, lo que es imposible.
    final casoImposible = CaseData(
      id: 'case_impossible',
      title: 'Imposible',
      description: 'Pistas contradictorias.',
      difficulty: PuzzleDifficulty.easy,
      boardRows: 3,
      boardColumns: 3,
      suspects: const [
        SuspectData(id: 'juan', name: 'Juan'),
      ],
      victimId: 'dummy1', killerId: 'dummy2', zones: const [], placedObjects: const [
        PlacedObjectData(
          object: ObjectData(id: 'cama', name: 'Cama'),
          position: CellPosition(1, 1),
        ),
      ],
      clues: const [
        SpatialClueData(
          id: 'c1',
          text: 'Juan está arriba de la cama.',
          relation: SpatialRelation.above,
          suspectId: 'juan',
          targetId: 'cama',
        ),
        SpatialClueData(
          id: 'c2',
          text: 'Juan está abajo de la cama.',
          relation: SpatialRelation.below,
          suspectId: 'juan',
          targetId: 'cama',
        ),
      ],
      solution: const SolutionData(suspectPositions: {}),
    );

    test('Debe encontrar 0 soluciones (imposible)', () {
      final result = solver.solve(casoImposible, maxSolutions: 2);

      expect(result.solutionCount, equals(0),
          reason: 'Las pistas son contradictorias, no debe existir solución');
      expect(result.isImpossible, isTrue);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Test 4 — maxSolutions se respeta
  // ─────────────────────────────────────────────────────────────────────────
  group('PuzzleSolver — Control de maxSolutions', () {
    final casoAmbiguo = CaseData(
      id: 'case_ambiguous',
      title: 'Ambiguo',
      description: 'Tablero con pocas restricciones.',
      difficulty: PuzzleDifficulty.easy,
      boardRows: 2,
      boardColumns: 2,
      suspects: const [
        SuspectData(id: 'x', name: 'X'),
      ],
      victimId: 'dummy1', killerId: 'dummy2', zones: const [], placedObjects: const [],
      clues: const [],
      solution: const SolutionData(suspectPositions: {}),
    );

    test('No debe retornar más soluciones que maxSolutions', () {
      final result = solver.solve(casoAmbiguo, maxSolutions: 1);
      expect(result.solutions.length, lessThanOrEqualTo(1));
    });
  });
}
