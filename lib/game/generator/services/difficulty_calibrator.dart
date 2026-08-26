import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_analysis.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Calibra y verifica la dificultad de un puzzle generado.
class DifficultyCalibrator {
  const DifficultyCalibrator(this._analyzer);

  final DifficultyAnalyzer _analyzer;

  /// Analiza la dificultad. Si [targetDifficulty] no es nulo y la dificultad
  /// analizada difiere, retorna null (indicando que la calibración falló).
  DifficultyAnalysis? calibrate(
    CaseData caseData,
    DifficultyLevel? targetDifficulty,
  ) {
    final analysis = _analyzer.analyze(caseData);
    if (targetDifficulty != null) {
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
