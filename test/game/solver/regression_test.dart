import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';

void main() {
  group('Mathematical Regression - Killer and Victim rules', () {
    late PuzzleSolver solver;

    setUp(() {
      solver = PuzzleSolver();
    });

    test('Asesino y víctima en ZONAS DISTINTAS genera 0 soluciones (Imposible)', () {
      final caseDataNoClues = CaseData(
        id: 'test_1',
        title: 'Test',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 2,
        boardColumns: 2,
        suspects: const [
          SuspectData(id: 'victim', name: 'Victim'),
          SuspectData(id: 'killer', name: 'Killer'),
        ],
        victimId: 'victim',
        killerId: 'killer',
        zones: const [
          ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0, 0)]),
          ZoneData(id: 'z2', name: 'Z2', cells: [CellPosition(0, 1)]),
          ZoneData(id: 'z3', name: 'Z3', cells: [CellPosition(1, 0)]),
          ZoneData(id: 'z4', name: 'Z4', cells: [CellPosition(1, 1)]),
        ],
        placedObjects: const [],
        clues: const [],
        solution: const SolutionData(suspectPositions: {}),
      );

      final result = solver.solve(caseDataNoClues);
      expect(result.solutions, isEmpty);
    });

    test('Inocentes NO pueden estar en la zona de la víctima (Unicidad)', () {
      final caseData = CaseData(
        id: 'test_2',
        title: 'Test',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        suspects: const [
          SuspectData(id: 'victim', name: 'Victim'),
          SuspectData(id: 'killer', name: 'Killer'),
          SuspectData(id: 'innocent', name: 'Innocent'),
        ],
        victimId: 'victim',
        killerId: 'killer',
        zones: const [
          // z1 tiene 4 celdas. Perfectas para Victim y Killer
          ZoneData(id: 'z1', name: 'Z1', cells: [
            CellPosition(0, 0), CellPosition(0, 1),
            CellPosition(1, 0), CellPosition(1, 1)
          ]),
          // z2 tiene 1 celda.
          ZoneData(id: 'z2', name: 'Z2', cells: [
            CellPosition(2, 2)
          ]),
          // z3 tiene el resto de las celdas, pero para forzar al inocente a ir a z2, podemos hacerlo.
          // Wait, no. Si Victim y Killer están en z1, Innocent NO puede estar en z1.
          // Inocente debe estar en otra zona.
          // El punto del test es comprobar que si el puzzle se resuelve, Inocente NUNCA está en Z1.
          ZoneData(id: 'z3', name: 'Z3', cells: [
            CellPosition(0, 2), CellPosition(1, 2),
            CellPosition(2, 0), CellPosition(2, 1)
          ]),
        ],
        placedObjects: const [],
        clues: const [],
        solution: const SolutionData(suspectPositions: {}),
      );

      final result = solver.solve(caseData);
      
      expect(result.solutions, isNotEmpty);
      
      for (final sol in result.solutions) {
        // En ninguna solucion válida puede el inocente estar en la zona 1
        final innocentPos = sol.suspectPositions['innocent']!;
        expect(
          caseData.zones[0].cells.contains(innocentPos), 
          isFalse, 
          reason: 'El inocente fue colocado en la zona del asesinato'
        );
      }
    });
  });
}
