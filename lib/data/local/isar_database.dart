import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nexus_mortis/data/local/models/achievements_entity.dart';
import 'package:nexus_mortis/data/local/models/active_game_entity.dart';
import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/local/models/player_progress_entity.dart';
import 'package:nexus_mortis/data/local/models/statistics_entity.dart';

/// Gestiona la conexión y configuración inicial de Isar.
class IsarDatabase {
  IsarDatabase._();

  /// Inicializa la base de datos Isar y retorna su instancia.
  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [
        PlayerProgressEntitySchema,
        ActiveGameEntitySchema,
        StatisticsEntitySchema,
        AchievementsEntitySchema,
        CampaignCaseEntitySchema,
      ],
      directory: dir.path,
    );
  }
}
