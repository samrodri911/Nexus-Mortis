import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';

/// Define las operaciones de persistencia para las estadísticas del jugador.
abstract class StatisticsRepository {
  Future<PlayerStatistics> loadStatistics();

  Future<void> saveStatistics(PlayerStatistics statistics);

  Future<void> clearStatistics();
}
