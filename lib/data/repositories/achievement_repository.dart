import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';

/// Define las operaciones de persistencia para el progreso de logros.
abstract class AchievementRepository {
  Future<Map<String, AchievementProgress>> loadAchievements();

  Future<void> saveAchievement(AchievementProgress progress);

  Future<void> saveAll(List<AchievementProgress> progresses);

  Future<void> clearAchievements();
}
