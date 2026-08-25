import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';

/// Servicio de dominio para consultar y actualizar las estadísticas del jugador.
class StatisticsService {
  StatisticsService(
    this._repository, {
    PlayerStatistics? initialStatistics,
  }) {
    statisticsNotifier = ValueNotifier<PlayerStatistics>(
      initialStatistics ?? PlayerStatistics.empty(),
    );
  }

  final StatisticsRepository _repository;
  late final ValueNotifier<PlayerStatistics> statisticsNotifier;

  PlayerStatistics get statistics => statisticsNotifier.value;

  /// Registra el resultado de una partida y persiste las estadísticas acumuladas en una única escritura.
  Future<void> recordResult(GameResult result) async {
    if (!result.solved) return;

    final updated = statistics.copyWithResult(result);
    statisticsNotifier.value = updated;
    await _repository.saveStatistics(updated);
  }
}
