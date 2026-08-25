import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/mappers/statistics_mapper.dart';
import 'package:nexus_mortis/data/local/models/statistics_entity.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';

/// Implementación Isar de [StatisticsRepository].
class IsarStatisticsRepository implements StatisticsRepository {
  IsarStatisticsRepository(this._isar);

  final Isar _isar;

  @override
  Future<PlayerStatistics> loadStatistics() async {
    final entity = await _isar.statisticsEntitys.get(0);
    if (entity == null) {
      return PlayerStatistics.empty();
    }
    return StatisticsMapper.toDomain(entity);
  }

  @override
  Future<void> saveStatistics(PlayerStatistics statistics) async {
    final entity = StatisticsMapper.toEntity(statistics);
    await _isar.writeTxn(() async {
      await _isar.statisticsEntitys.put(entity);
    });
  }

  @override
  Future<void> clearStatistics() async {
    await _isar.writeTxn(() async {
      await _isar.statisticsEntitys.delete(0);
    });
  }
}
