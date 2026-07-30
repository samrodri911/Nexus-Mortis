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
    if (targetDifficulty != null && analysis.level != targetDifficulty) {
      return null;
    }
    return analysis;
  }
}
