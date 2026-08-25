import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/game/hints/models/hint_cost.dart';
import 'package:nexus_mortis/game/hints/models/hint_result.dart';
import 'package:nexus_mortis/game/hints/models/hint_type.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

/// Orquesta la compra de pistas verificando los fondos del jugador.
class HintEconomyService {
  HintEconomyService({
    required this.progressionService,
    required this.hintService,
    this.costs = HintCost.defaults,
    this.onHintPurchased,
  });

  final ProgressionService progressionService;
  final HintService hintService;
  final HintCost costs;
  VoidCallback? onHintPurchased;

  /// Intenta comprar una pista.
  /// Si no hay fondos suficientes, retorna null.
  /// Si hay fondos, descuenta las monedas, invoca [onHintPurchased] y retorna la pista generada.
  HintResult? buyHint(
    HintType type,
    CaseData caseData,
    PlayerBoardState state,
    ValidationService validationService,
  ) {
    final cost = _getCost(type);

    if (progressionService.spendCoins(cost)) {
      final hint = hintService.generateHint(type, caseData, state, validationService);
      onHintPurchased?.call();
      return hint;
    }

    return null;
  }

  int _getCost(HintType type) {
    switch (type) {
      case HintType.soft:
        return costs.soft;
      case HintType.medium:
        return costs.medium;
      case HintType.reveal:
        return costs.reveal;
    }
  }
}
