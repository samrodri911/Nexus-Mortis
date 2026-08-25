import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';
import 'package:nexus_mortis/game/statistics/services/statistics_service.dart';
import 'package:nexus_mortis/main.dart';

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

class MockStatisticsRepository implements StatisticsRepository {
  @override
  Future<PlayerStatistics> loadStatistics() async => PlayerStatistics.empty();

  @override
  Future<void> saveStatistics(PlayerStatistics statistics) async {}

  @override
  Future<void> clearStatistics() async {}
}

class MockAchievementRepository implements AchievementRepository {
  @override
  Future<Map<String, AchievementProgress>> loadAchievements() async => {};

  @override
  Future<void> saveAchievement(AchievementProgress progress) async {}

  @override
  Future<void> saveAll(List<AchievementProgress> progresses) async {}

  @override
  Future<void> clearAchievements() async {}
}

void main() {
  testWidgets('NexusMortisApp loads successfully and displays CaseSelectionPage', (WidgetTester tester) async {
    final mockProgressRepository = MockProgressRepository();
    final progressionService = ProgressionService(mockProgressRepository, initialProgress: PlayerProgress.empty());

    final mockActiveGameRepository = MockActiveGameRepository();
    final saveGameService = SaveGameService(mockActiveGameRepository);

    final mockStatsRepository = MockStatisticsRepository();
    final statisticsService = StatisticsService(mockStatsRepository);

    final mockAchRepository = MockAchievementRepository();
    final achievementService = AchievementService(mockAchRepository);
    
    final hintService = HintService(clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));
    final economyService = HintEconomyService(progressionService: progressionService, hintService: hintService);

    final proceduralCaseService = ProceduralCaseService(
      progressionService: progressionService,
      staticSource: const StaticCaseSource(),
      generatedSource: GeneratedCaseSource(),
    );

    final gameSessionService = GameSessionService(
      progressionService: progressionService,
      saveGameService: saveGameService,
      statisticsService: statisticsService,
      achievementService: achievementService,
    );

    await tester.pumpWidget(NexusMortisApp(
      progressionService: progressionService,
      saveGameService: saveGameService,
      economyService: economyService,
      proceduralCaseService: proceduralCaseService,
      gameSessionService: gameSessionService,
    ));

    // Verify that the CaseSelectionPage is present on screen.
    expect(find.byType(CaseSelectionPage), findsOneWidget);
  });
}
