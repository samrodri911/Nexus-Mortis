import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';

/// Define la política de configuración estructural y el rango de dificultad deductiva
/// objetivo para un nivel específico de la campaña.
class LevelPolicy {
  const LevelPolicy({
    required this.level,
    required this.rows,
    required this.columns,
    required this.suspectCount,
    required this.objectCount,
    required this.targetDifficultyScore,
    required this.scoreTolerance,
    required this.maxDeltaFromPrevious,
    required this.targetDifficulty,
  });

  /// Índice del nivel (0-indexado: 0, 1, 2, ... N).
  final int level;

  /// Filas de la cuadrícula.
  final int rows;

  /// Columnas de la cuadrícula.
  final int columns;

  /// Cantidad de sospechosos inocentes + asesino (la víctima es adicional).
  final int suspectCount;

  /// Cantidad de objetos fijos colocados en el escenario.
  final int objectCount;

  /// Puntuación continua de dificultad objetivo (15..100).
  final int targetDifficultyScore;

  /// Tolerancia permitida alrededor del objetivo (target ± tolerance).
  final int scoreTolerance;

  /// Salto máximo aceptable respecto al score del nivel inmediatamente anterior.
  final int maxDeltaFromPrevious;

  /// Nivel cualitativo de dificultad derivado.
  final DifficultyLevel targetDifficulty;

  /// Puntuación mínima aceptable para este nivel.
  int get minDifficultyScore =>
      (targetDifficultyScore - scoreTolerance).clamp(10, 100);

  /// Puntuación máxima aceptable para este nivel.
  int get maxDifficultyScore =>
      (targetDifficultyScore + scoreTolerance).clamp(15, 100);

  /// Genera determinísticamente la política para un índice de nivel de campaña.
  factory LevelPolicy.forLevel(int level) {
    final int rows;
    final int cols;
    final int suspects;
    final int objects;

    // 1. Bloques estables de tamaño de tablero y entidades (~10 niveles por bloque)
    if (level < 10) {
      // Bloque 0 (Niveles 0–9): Tablero compacto, introducción suave
      rows = 4;
      cols = 4;
      suspects = 3;
      objects = 2;
    } else if (level < 20) {
      // Bloque 1 (Niveles 10–19): Tablero 5x4, progresión inicial
      rows = 5;
      cols = 4;
      suspects = 4;
      objects = 3;
    } else if (level < 30) {
      // Bloque 2 (Niveles 20–29): Tablero 5x5, complejidad media
      rows = 5;
      cols = 5;
      suspects = 4;
      objects = 3;
    } else if (level < 40) {
      // Bloque 3 (Niveles 30–39): Tablero 6x5, cadenas más profundas
      rows = 6;
      cols = 5;
      suspects = 5;
      objects = 4;
    } else if (level < 50) {
      // Bloque 4 (Niveles 40–49): Tablero 6x6, alta deducción
      rows = 6;
      cols = 6;
      suspects = 5;
      objects = 4;
    } else {
      // Bloque 5+ (Niveles 50+): Tablero maestro 6x6
      rows = 6;
      cols = 6;
      suspects = level < 65 ? 5 : 6;
      objects = 4;
    }

    // 2. Curva continua de dificultad objetivo calibrada con la distribución real
    final double target;
    if (level < 10) {
      target = 33.0 + level * 0.7; // ~33 a ~39
    } else if (level < 20) {
      target = 41.0 + (level - 10) * 0.7; // ~41 a ~47
    } else if (level < 30) {
      target = 48.0 + (level - 20) * 0.7; // ~48 a ~54
    } else if (level < 40) {
      target = 55.0 + (level - 30) * 0.7; // ~55 a ~61
    } else if (level < 50) {
      target = 62.0 + (level - 40) * 0.7; // ~62 a ~68
    } else {
      target = (70.0 + (level - 50) * 0.5).clamp(70.0, 95.0);
    }

    final int targetScore = target.round().clamp(20, 95);

    // Tolerancias estrechas para evitar saltos bruscos
    final int tolerance = level < 20 ? 9 : (level < 40 ? 10 : 11);
    final int maxDelta = (level % 10 == 0) ? 12 : (level < 20 ? 8 : 10);

    final DifficultyLevel diffLevel;
    if (targetScore <= 40) {
      diffLevel = DifficultyLevel.easy;
    } else if (targetScore <= 65) {
      diffLevel = DifficultyLevel.medium;
    } else {
      diffLevel = DifficultyLevel.hard;
    }

    return LevelPolicy(
      level: level,
      rows: rows,
      columns: cols,
      suspectCount: suspects,
      objectCount: objects,
      targetDifficultyScore: targetScore,
      scoreTolerance: tolerance,
      maxDeltaFromPrevious: maxDelta,
      targetDifficulty: diffLevel,
    );
  }
}
