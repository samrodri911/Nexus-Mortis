import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  final solver = PuzzleSolver();
  final result = solver.solve(demoCase001, maxSolutions: 3);
  print('Solutions found: ');
  for (final s in result.solutions) {
    print(s.suspectPositions);
  }
}
