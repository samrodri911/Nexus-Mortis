import 'package:nexus_mortis/game/difficulty/models/difficulty_analysis.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Analiza un [CaseData] y determina su nivel de dificultad objetivo.
///
/// Utiliza el [PuzzleSolver] para medir la complejidad del árbol de búsqueda.
/// Lanza excepciones si el puzzle no tiene solución única.
class DifficultyAnalyzer {
  const DifficultyAnalyzer(this.solver);

  final PuzzleSolver solver;

  // Umbrales de nodos visitados para cada nivel de dificultad.
  static const int _thresholdTrivial = 25;
  static const int _thresholdEasy = 100;
  static const int _thresholdMedium = 500;
  static const int _thresholdHard = 2000;

  /// Ejecuta el análisis sobre [caseData].
  ///
  /// Lanza [StateError] si el puzzle tiene 0 soluciones (imposible).
  /// Lanza [StateError] si el puzzle tiene >1 soluciones (ambiguo).
  DifficultyAnalysis analyze(CaseData caseData) {
    // maxSolutions: 2 es suficiente para detectar ambigüedad sin
    // recorrer todo el árbol innecesariamente.
    final result = solver.solve(caseData, maxSolutions: 2);

    if (result.isImpossible) {
      throw StateError('El puzzle es imposible (0 soluciones).');
    }

    if (result.isAmbiguous) {
      throw StateError('El puzzle es ambiguo (>1 soluciones).');
    }

    final level = _calculateLevel(result.visitedNodes);

    return DifficultyAnalysis(
      level: level,
      visitedNodes: result.visitedNodes,
      solutionCount: result.solutionCount,
      clueCount: caseData.clues.length,
      suspectCount: caseData.suspects.length,
    );
  }

  DifficultyLevel _calculateLevel(int visitedNodes) {
    if (visitedNodes <= _thresholdTrivial) return DifficultyLevel.trivial;
    if (visitedNodes <= _thresholdEasy) return DifficultyLevel.easy;
    if (visitedNodes <= _thresholdMedium) return DifficultyLevel.medium;
    if (visitedNodes <= _thresholdHard) return DifficultyLevel.hard;
    return DifficultyLevel.expert;
  }
}
