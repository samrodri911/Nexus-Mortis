import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  final validator = CaseIntegrityValidator(
    solver: PuzzleSolver(),
    simulator: const PuzzleSimulator(),
  );

  final cases = [
    demoCase001,
    demoCase002,
    demoCase003,
  ];

  for (final c in cases) {
    print('Checking ${c.id}...');
    final result = validator.validateDetailed(c);
    print('  Valid: ${result.isValid}');
    if (!result.isValid) {
      print('  Reason: ${result.rejectionReason?.name}');
      print('  Details: ${result.details}');
    }
  }
}
