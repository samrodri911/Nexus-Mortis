import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/mappers/achievement_mapper.dart';
import 'package:nexus_mortis/data/local/models/achievements_entity.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';

/// Implementación Isar de [AchievementRepository] usando un único registro (id = 0).
class IsarAchievementRepository implements AchievementRepository {
  IsarAchievementRepository(this._isar);

  final Isar _isar;

  @override
  Future<Map<String, AchievementProgress>> loadAchievements() async {
    final entity = await _isar.achievementsEntitys.get(0);
    if (entity == null) {
      return {};
    }
    final map = <String, AchievementProgress>{};
    for (final item in entity.items) {
      map[item.achievementId] = AchievementMapper.toDomain(item);
    }
    return map;
  }

  @override
  Future<void> saveAchievement(AchievementProgress progress) async {
    await saveAll([progress]);
  }

  @override
  Future<void> saveAll(List<AchievementProgress> progresses) async {
    final current = await loadAchievements();
    for (final p in progresses) {
      current[p.achievementId] = p;
    }

    final entity = AchievementsEntity()
      ..id = 0
      ..items = current.values.map(AchievementMapper.toEmbedded).toList();

    await _isar.writeTxn(() async {
      await _isar.achievementsEntitys.put(entity);
    });
  }

  @override
  Future<void> clearAchievements() async {
    await _isar.writeTxn(() async {
      await _isar.achievementsEntitys.delete(0);
    });
  }
}
