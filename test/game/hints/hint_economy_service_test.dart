import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/hints/models/hint_type.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';

class MockProgressRepository implements ProgressRepository {
  PlayerProgress _progress = PlayerProgress.empty();
  
  @override
  Future<PlayerProgress> loadProgress() async => _progress;

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    _progress = progress;
  }

  @override
  Future<void> clearProgress() async {
    _progress = PlayerProgress.empty();
  }
}

void main() {
  group('HintEconomyService', () {
    late ProgressionService progressionService;
    late HintEconomyService economyService;
    late ValidationService validationService;
    final dummyCase = demoCase001;

    setUp(() async {
      progressionService = ProgressionService(MockProgressRepository(), initialProgress: PlayerProgress.empty());
      final hintService = HintService(clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));
      economyService = HintEconomyService(
        progressionService: progressionService,
        hintService: hintService,
      );
      validationService = ValidationService(caseData: dummyCase, clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));
    });

    test('buyHint reduce monedas si hay suficientes', () {
      const state = PlayerBoardState(assignments: [], eliminatedCells: {});
      final initialCoins = progressionService.progress.coins;

      final result = economyService.buyHint(HintType.soft, dummyCase, state, validationService);

      expect(result, isNotNull);
      expect(progressionService.progress.coins, initialCoins - 25);
    });

    test('buyHint retorna null si no hay monedas', () {
      progressionService.spendCoins(500); // 500 iniciales, gastamos todas
      expect(progressionService.progress.coins, 0);

      const state = PlayerBoardState(assignments: [], eliminatedCells: {});
      final result = economyService.buyHint(HintType.soft, dummyCase, state, validationService);

      expect(result, isNull);
    });
  });
}
