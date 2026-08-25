import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/models/achievement_progress_embedded.dart';

part 'achievements_entity.g.dart';

/// Entidad Isar principal para almacenar la colección de logros del jugador en un único registro (id = 0).
@collection
class AchievementsEntity {
  Id id = 0;

  List<AchievementProgressEmbedded> items = [];
}
