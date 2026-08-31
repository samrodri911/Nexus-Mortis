import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';

/// Configuración inmutable para una solicitud de generación de puzzle.
class GeneratorConfig {
  const GeneratorConfig({
    required this.rows,
    required this.columns,
    required this.suspectCount,
    required this.objectCount,
    this.targetDifficulty,
    this.minDifficultyScore,
    this.maxDifficultyScore,
    this.randomSeed,
    this.maxAttempts = 50,
    this.minClues,
    this.maxClues,
  });

  /// Puntuación mínima de dificultad continua permitida (10..100).
  final int? minDifficultyScore;

  /// Puntuación máxima de dificultad continua permitida (10..100).
  final int? maxDifficultyScore;

  /// Número de filas del tablero.
  final int rows;

  /// Número de columnas del tablero.
  final int columns;

  /// Cantidad de sospechosos a incluir.
  final int suspectCount;

  /// Cantidad de objetos a incluir.
  final int objectCount;

  /// Dificultad deseada. Si es null, se acepta cualquier puzzle válido.
  final DifficultyLevel? targetDifficulty;

  /// Semilla para la generación. Asegura reproducibilidad.
  final int? randomSeed;

  /// Número máximo de intentos antes de fallar (en caso de configuraciones difíciles de satisfacer).
  final int maxAttempts;

  /// Mínimo de pistas permitidas en el resultado final.
  final int? minClues;

  /// Máximo de pistas permitidas en el resultado final.
  final int? maxClues;
}
