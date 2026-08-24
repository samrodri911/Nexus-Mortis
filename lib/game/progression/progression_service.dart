import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/models/reward_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Servicio encargado de gestionar el progreso del jugador.
///
/// Es independiente de la UI y del motor del juego. Expone el estado a través
/// de [progressNotifier] para que Flutter reaccione a los cambios.
class ProgressionService {
  ProgressionService(
    this._repository, {
    PlayerProgress? initialProgress,
  }) {
    progressNotifier = ValueNotifier<PlayerProgress>(
      initialProgress ?? PlayerProgress.empty(),
    );
  }

  final ProgressRepository _repository;
  late final ValueNotifier<PlayerProgress> progressNotifier;

  PlayerProgress get progress => progressNotifier.value;

  /// Determina si un caso está desbloqueado basándose en las dependencias
  /// del propio caso y el progreso actual.
  bool isCaseUnlocked(CaseData caseData) {
    if (caseData.requiredCaseId == null) {
      return true; // No requiere caso previo.
    }

    return progress.completedCases.containsKey(caseData.requiredCaseId);
  }

  /// Verifica si un caso ya fue completado.
  bool isCaseCompleted(String caseId) {
    return progress.completedCases.containsKey(caseId);
  }

  /// Devuelve el próximo caso de campaña desbloqueado y no completado.
  CaseData? getNextCampaignCase(List<CaseData> campaignCases) {
    for (final caseData in campaignCases) {
      if (isCaseUnlocked(caseData) && !isCaseCompleted(caseData.id)) {
        return caseData;
      }
    }
    return null;
  }

  /// Marca un caso como completado y otorga recompensas.
  ///
  /// Es idempotente: si el caso ya estaba completado, no duplica
  /// las recompensas de monedas ni estrellas.
  Future<void> completeCase(String caseId, RewardData reward) async {
    if (isCaseCompleted(caseId)) {
      // Ya fue completado antes, no otorgamos recompensas de nuevo.
      return;
    }

    // Generar un nuevo estado inmutable y actualizar el notifier.
    progressNotifier.value = progress.copyWithCompletion(
      caseId: caseId,
      earnedCoins: reward.coins,
      earnedStars: reward.stars,
    );

    await _persist();
  }

  /// Gasta monedas, retorna false si no hay fondos suficientes.
  bool spendCoins(int amount) {
    if (progress.coins < amount) return false;
    progressNotifier.value = progress.copyWithSpend(amount);
    _persist(); // No hacemos await para no bloquear la UI innecesariamente
    return true;
  }

  /// Añade monedas de forma genérica.
  void addCoins(int amount) {
    progressNotifier.value = progress.copyWithAdd(amount);
    _persist();
  }

  /// Guarda el progreso actual en el repositorio subyacente.
  Future<void> _persist() async {
    await _repository.saveProgress(progressNotifier.value);
  }
}
