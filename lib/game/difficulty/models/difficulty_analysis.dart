import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';

/// Resultado del análisis de dificultad de un puzzle.
///
/// Incluye tanto la clasificación final como las métricas crudas que
/// permitieron calcularla, para facilitar depuración y ajuste de umbrales.
class DifficultyAnalysis {
  const DifficultyAnalysis({
    required this.level,
    required this.visitedNodes,
    required this.solutionCount,
    required this.clueCount,
    required this.suspectCount,
    this.difficultyScore = 0,
  });

  /// Clasificación de dificultad calculada.
  final DifficultyLevel level;

  /// Puntuación continua de dificultad (0 a 100).
  final int difficultyScore;

  /// Número de nodos explorados por el solver (proxy de complejidad).
  final int visitedNodes;

  /// Número de soluciones encontradas (1 = válido, 0 = imposible, >1 = ambiguo).
  final int solutionCount;

  /// Número de pistas del caso.
  final int clueCount;

  /// Número de sospechosos del caso.
  final int suspectCount;

  @override
  String toString() {
    return 'DifficultyAnalysis('
        'level: ${level.name}, '
        'nodes: $visitedNodes, '
        'solutions: $solutionCount, '
        'clues: $clueCount, '
        'suspects: $suspectCount'
        ')';
  }
}
