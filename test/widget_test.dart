import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/main.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';

class MockProgressRepository implements ProgressRepository {
  @override
  Future<PlayerProgress> loadProgress() async => PlayerProgress.empty();
  
  @override
  Future<void> saveProgress(PlayerProgress progress) async {}
  
  @override
  Future<void> clearProgress() async {}
}

class MockActiveGameRepository implements ActiveGameRepository {
  @override
  Future<void> saveGame(ActiveGameState state) async {}

  @override
  Future<ActiveGameState?> loadGame() async => null;

  @override
  Future<void> clearGame() async {}
}

void main() {
  testWidgets('NexusMortisApp loads successfully and displays CaseSelectionPage', (WidgetTester tester) async {
    final mockProgressRepository = MockProgressRepository();
    final progressionService = ProgressionService(mockProgressRepository, initialProgress: PlayerProgress.empty());

    final mockActiveGameRepository = MockActiveGameRepository();
    final saveGameService = SaveGameService(mockActiveGameRepository);
    
    final hintService = HintService(clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));
    final economyService = HintEconomyService(progressionService: progressionService, hintService: hintService);

    await tester.pumpWidget(NexusMortisApp(
      progressionService: progressionService,
      saveGameService: saveGameService,
      economyService: economyService,
    ));

    // Verify that the CaseSelectionPage is present on screen.
    expect(find.byType(CaseSelectionPage), findsOneWidget);
  });
}
