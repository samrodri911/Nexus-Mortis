import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/mappers/player_progress_mapper.dart';
import 'package:nexus_mortis/data/local/models/player_progress_entity.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';

/// Implementación de [ProgressRepository] que utiliza Isar para persistencia.
class IsarProgressRepository implements ProgressRepository {
  IsarProgressRepository(this._isar);

  final Isar _isar;

  @override
  Future<PlayerProgress> loadProgress() async {
    final entity = await _isar.playerProgressEntitys.get(0);
    
    if (entity == null) {
      return PlayerProgress.empty();
    }

    return PlayerProgressMapper.toDomain(entity);
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    final entity = PlayerProgressMapper.toEntity(progress);

    await _isar.writeTxn(() async {
      await _isar.playerProgressEntitys.put(entity);
    });
  }

  @override
  Future<void> clearProgress() async {
    await _isar.writeTxn(() async {
      await _isar.playerProgressEntitys.delete(0);
    });
  }
}
