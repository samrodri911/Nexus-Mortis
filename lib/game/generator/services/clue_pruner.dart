import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/generator/services/clue_optimizer.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Poda el conjunto de pistas para reducirlo al mínimo deductivo necesario.
class CluePruner {
  CluePruner(PuzzleSolver solver) : _optimizer = ClueOptimizer(solver);

  final ClueOptimizer _optimizer;

  /// Poda pistas garantizando que la solución siga siendo única.
  ({List<SpatialClueData> prunedClues, int solverCalls}) prune({
    required CaseData initialCase,
  }) {
    final res = _optimizer.optimize(initialCase: initialCase);
    return (prunedClues: res.optimizedClues, solverCalls: res.solverCalls);
  }
}
