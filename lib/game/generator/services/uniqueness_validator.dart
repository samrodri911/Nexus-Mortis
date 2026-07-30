import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Valida si un puzzle generado tiene solución única.
class UniquenessValidator {
  const UniquenessValidator(this._solver);

  final PuzzleSolver _solver;

  /// Retorna el número de nodos visitados si la solución es única, o -1 si no lo es.
  int validate(CaseData caseData) {
    final result = _solver.solve(caseData, maxSolutions: 2);
    if (result.solutionCount == 1) {
      return result.visitedNodes;
    }
    return -1;
  }
}
