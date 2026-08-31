import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_analysis.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Calibra y verifica la dificultad de un puzzle generado.
class DifficultyCalibrator {
  const DifficultyCalibrator(this._analyzer);

  final DifficultyAnalyzer _analyzer;

  /// Analiza la dificultad y verifica tanto el [targetDifficulty] como los rangos numéricos
  /// de [minScore] y [maxScore]. Retorna null si la calibración no cumple los requisitos.
  DifficultyAnalysis? calibrate(
    CaseData caseData,
    DifficultyLevel? targetDifficulty, {
    int? minScore,
    int? maxScore,
  }) {
    final analysis = _analyzer.analyze(caseData);

    if (minScore != null && analysis.difficultyScore < minScore) {
      return null;
    }
    if (maxScore != null && analysis.difficultyScore > maxScore) {
      return null;
    }

    // Si no se especificaron rangos numéricos pero sí targetDifficulty, verificar la etiqueta
    if (minScore == null && maxScore == null && targetDifficulty != null) {
      bool isAcceptable = analysis.level == targetDifficulty;
      
      // Permitir flexibilidades mapeadas a la misma PuzzleDifficulty visual
      if (targetDifficulty == DifficultyLevel.easy && analysis.level == DifficultyLevel.trivial) {
        isAcceptable = true;
      }
      if (targetDifficulty == DifficultyLevel.hard && analysis.level == DifficultyLevel.expert) {
        isAcceptable = true;
      }
      
      if (!isAcceptable) return null;
    }
    return analysis;
  }
}
