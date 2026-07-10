import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/models/reward_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Servicio encargado de gestionar el progreso del jugador.
///
/// Es independiente de la UI y del motor del juego. Expone el estado a través
/// de [progressNotifier] para que Flutter reaccione a los cambios.
class ProgressionService {
  ProgressionService({PlayerProgress? initialProgress}) {
    progressNotifier = ValueNotifier<PlayerProgress>(
      initialProgress ?? const PlayerProgress.empty(),
    );
  }

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

  /// Marca un caso como completado y otorga recompensas.
  ///
  /// Es idempotente: si el caso ya estaba completado, no duplica
  /// las recompensas de monedas ni estrellas.
  void completeCase(String caseId, RewardData reward) {
    if (isCaseCompleted(caseId)) {
      // Ya fue completado antes, no otorgamos recompensas de nuevo.
      // (Opcionalmente aquí podríamos implementar lógica para mejorar estrellas si
      // sacó 3 en vez de 1 en un reintento).
      return;
    }

    // Generar un nuevo estado inmutable y actualizar el notifier.
    progressNotifier.value = progress.copyWithCompletion(
      caseId: caseId,
      earnedCoins: reward.coins,
      earnedStars: reward.stars,
    );
  }
}
