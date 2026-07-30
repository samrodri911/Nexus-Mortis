/// Estadísticas sobre el proceso de generación de un puzzle.
class GenerationStatistics {
  const GenerationStatistics({
    required this.attemptsUsed,
    required this.solverCalls,
    required this.visitedNodes,
    required this.generationDurationMs,
    required this.generatedClues,
    required this.remainingClues,
  });

  /// Número de intentos requeridos para generar un puzzle válido.
  final int attemptsUsed;

  /// Cantidad de veces que se llamó al [PuzzleSolver] durante la generación (mayormente por el Pruner).
  final int solverCalls;

  /// Total de nodos visitados por el solver en todo el proceso.
  final int visitedNodes;

  /// Tiempo total de generación en milisegundos.
  final int generationDurationMs;

  /// Cantidad inicial de pistas generadas antes de la poda.
  final int generatedClues;

  /// Cantidad final de pistas tras la poda.
  final int remainingClues;
}
