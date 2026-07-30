import 'package:nexus_mortis/game/difficulty/models/difficulty_analysis.dart';
import 'package:nexus_mortis/game/generator/models/generation_statistics.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Resultado exitoso de la generación de un puzzle.
class GenerationResult {
  const GenerationResult({
    required this.caseData,
    required this.analysis,
    required this.statistics,
  });

  /// El caso generado, listo para ser jugado o guardado.
  final CaseData caseData;

  /// El análisis de dificultad del puzzle generado.
  final DifficultyAnalysis analysis;

  /// Métricas de performance y eficiencia de la generación.
  final GenerationStatistics statistics;
}
