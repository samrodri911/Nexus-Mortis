import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/mappers/active_game_mapper.dart';
import 'package:nexus_mortis/data/local/models/active_game_entity.dart';
import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';

/// Implementación de [ActiveGameRepository] que utiliza Isar.
class IsarActiveGameRepository implements ActiveGameRepository {
  IsarActiveGameRepository(this._isar);

  final Isar _isar;

  @override
  Future<ActiveGameState?> loadGame() async {
    final entity = await _isar.activeGameEntitys.get(0);
    
    if (entity == null) {
      return null;
    }

    return ActiveGameMapper.toDomain(entity);
  }

  @override
  Future<void> saveGame(ActiveGameState state) async {
    final entity = ActiveGameMapper.toEntity(state);

    await _isar.writeTxn(() async {
      await _isar.activeGameEntitys.put(entity);
    });
  }

  @override
  Future<void> clearGame() async {
    await _isar.writeTxn(() async {
      await _isar.activeGameEntitys.delete(0);
    });
  }
}
