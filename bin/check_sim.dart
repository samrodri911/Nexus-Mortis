import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';

void main() {
  const simulator = HumanDeductionReplay();

  final cases = [
    demoCase001,
    demoCase002,
    demoCase003,
  ];

  for (final c in cases) {
    print('Checking ${c.id}...');
    final result = simulator.simulate(c, c.clues);
    print('  Steps: ${result.steps}');
    print('  Victim candidate cells: ${result.victimCandidateCells}');
    print('  Solved: ${result.solved}');
  }
}
