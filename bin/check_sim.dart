import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';

void main() {
  const simulator = PuzzleSimulator();

  final cases = [
    demoCase001,
    demoCase002,
    demoCase003,
  ];

  for (final c in cases) {
    print('Checking ${c.id}...');
    final result = simulator.simulate(c, c.clues);
    print('  Steps: ${result.steps}');
    print('  Victim candidates: ${result.victimCandidateCells}');
    for (final s in c.suspects) {
      final state = result.clueStates.values.firstWhere((st) => st.clue.suspectId == s.id);
      print('  ${s.id} candidates: ${state.candidateCells.length}');
    }
  }
}
