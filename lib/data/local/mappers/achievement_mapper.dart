import 'package:nexus_mortis/data/local/models/achievement_progress_embedded.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';

/// Mapeador entre [AchievementProgress] del dominio y [AchievementProgressEmbedded] de Isar.
class AchievementMapper {
  AchievementMapper._();

  static AchievementProgress toDomain(AchievementProgressEmbedded entity) {
    return AchievementProgress(
      achievementId: entity.achievementId,
      currentValue: entity.currentValue,
      isUnlocked: entity.isUnlocked,
      unlockedAt: entity.unlockedAt,
    );
  }

  static AchievementProgressEmbedded toEmbedded(AchievementProgress domain) {
    final embedded = AchievementProgressEmbedded()
      ..achievementId = domain.achievementId
      ..currentValue = domain.currentValue
      ..isUnlocked = domain.isUnlocked
      ..unlockedAt = domain.unlockedAt;

    return embedded;
  }
}
