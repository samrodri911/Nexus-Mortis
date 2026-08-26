import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  final solver = PuzzleSolver();
  final analyzer = DifficultyAnalyzer(solver);

  group('DifficultyAnalyzer', () {
    test('Debe analizar correctamente DemoCase001', () {
      final analysis = analyzer.analyze(demoCase001);

      expect(analysis.solutionCount, equals(1));
      expect(analysis.clueCount, equals(7));
      expect(analysis.suspectCount, equals(4));
      // DemoCase001 es muy simple, debería ser trivial o easy.
      expect(
        analysis.level == DifficultyLevel.trivial ||
            analysis.level == DifficultyLevel.easy,
        isTrue,
      );
    });

    test('Debe lanzar error con puzzle ambiguo', () {
      final caseAmbiguo = CaseData(
        id: 'case_ambiguous',
        title: 'Ambiguo',
        description: 'Tablero sin pistas.',
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

      expect(
        () => analyzer.analyze(caseAmbiguo),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message', contains('ambiguo (>1 soluciones)'))),
      );
    });

    test('Debe lanzar error con puzzle imposible', () {
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

      expect(
        () => analyzer.analyze(casoImposible),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message', contains('imposible (0 soluciones)'))),
      );
    });
  });
}
