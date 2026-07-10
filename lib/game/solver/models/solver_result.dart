import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

/// Resultado devuelto por [PuzzleSolver] tras completar la búsqueda.
class SolverResult {
  const SolverResult({
    required this.solutionCount,
    required this.solutions,
    required this.visitedNodes,
  });

  /// Número total de soluciones encontradas (hasta [maxSolutions]).
  final int solutionCount;

  /// Lista de soluciones encontradas.
  /// Puede ser vacía (puzzle sin solución) o contener hasta [maxSolutions].
  final List<SolutionData> solutions;

  /// Número de nodos visitados durante la búsqueda.
  /// Útil para medir el rendimiento del algoritmo.
  final int visitedNodes;

  /// Conveniencia: retorna true si el puzzle tiene exactamente una solución.
  bool get isUnique => solutionCount == 1;

  /// Conveniencia: retorna true si el puzzle no tiene solución.
  bool get isImpossible => solutionCount == 0;

  /// Conveniencia: retorna true si el puzzle tiene más de una solución.
  bool get isAmbiguous => solutionCount > 1;

  @override
  String toString() {
    return 'SolverResult(solutions: $solutionCount, nodes: $visitedNodes)';
  }
}
