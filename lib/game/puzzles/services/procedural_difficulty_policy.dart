import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';

/// Política responsable de decidir la dificultad del próximo caso procedimental.
/// Aísla esta lógica del orquestador, permitiendo en el futuro agregar
/// lógicas basadas en win streaks, tiempo, etc.
class ProceduralDifficultyPolicy {
  const ProceduralDifficultyPolicy();

  /// Determina la configuración del siguiente nivel basándose en el progreso actual.
  GeneratorConfig determineNextConfig(PlayerProgress progress) {
    final count = progress.completedCases.length;
    
    DifficultyLevel level;
    int rows = 3;
    int cols = 3;
    int suspects = 3;
    int objects = 2;

    if (count < 5) {
      level = DifficultyLevel.easy;
    } else if (count < 15) {
      level = DifficultyLevel.medium;
      rows = 4;
      cols = 3;
      suspects = 4;
      objects = 2;
    } else if (count < 30) {
      level = DifficultyLevel.hard;
      rows = 4;
      cols = 4;
      suspects = 5;
      objects = 3;
    } else {
      level = DifficultyLevel.expert;
      rows = 5;
      cols = 4;
      suspects = 6;
      objects = 4;
    }

    return GeneratorConfig(
      rows: rows,
      columns: cols,
      suspectCount: suspects,
      objectCount: objects,
      targetDifficulty: level,
    );
  }
}
