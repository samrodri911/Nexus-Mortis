import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  group('Demo Cases Audit - Human Deductive Correctness', () {
    final validator = CaseIntegrityValidator(simulator: PuzzleSimulator(), solver: PuzzleSolver());
    final cases = [demoCase001, demoCase002, demoCase003];

    test('Test 1 - Semántica Cardinal Estricta', () {
      final evaluator = const SpatialClueEvaluator();
      
      // below -> same col, row >
      expect(evaluator.evaluate(suspectPosition: CellPosition(2, 1), targetPosition: CellPosition(1, 1), relation: SpatialRelation.below), isTrue);
      expect(evaluator.evaluate(suspectPosition: CellPosition(2, 2), targetPosition: CellPosition(1, 1), relation: SpatialRelation.below), isFalse, reason: 'Diferente columna debe fallar en below');
      
      // rightOf -> same row, col >
      expect(evaluator.evaluate(suspectPosition: CellPosition(2, 2), targetPosition: CellPosition(2, 1), relation: SpatialRelation.rightOf), isTrue);
      expect(evaluator.evaluate(suspectPosition: CellPosition(3, 2), targetPosition: CellPosition(2, 1), relation: SpatialRelation.rightOf), isFalse, reason: 'Diferente fila debe fallar en rightOf');
    });

    test('Test 2 a 9 - Integridad de los 3 Casos Demo', () {
      for (final caseData in cases) {
        final result = validator.validateDetailed(caseData);
        expect(result.isValid, isTrue, reason: 'Fallo en ${caseData.id}: ${result.errors.join(", ")}');
      }
    });

    test('Test 10 - Clausura Global Demo 003 No Artificial', () {
      final simulator = PuzzleSimulator();
      // Simulate Demo 003 WITHOUT global rules
      final baseCase = demoCase003.copyWith(globalRules: const []);
      final baseSim = simulator.simulate(baseCase, baseCase.clues);
      
      expect(baseSim.victimCandidateCells, greaterThan(1), reason: 'Debe haber ambigüedad antes de la Pista General');
      
      // Simulate WITH global rules
      final fullSim = simulator.simulate(demoCase003, demoCase003.clues);
      expect(fullSim.victimCandidateCells, equals(1), reason: 'La Pista General debe clausurar a 1 celda');
      expect(fullSim.victimCandidateRooms, equals(1), reason: 'La Pista General debe clausurar a 1 habitación');
    });
  });
}
