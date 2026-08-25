import 'package:flutter/material.dart';
import 'package:nexus_mortis/data/local/isar_achievement_repository.dart';
import 'package:nexus_mortis/data/local/isar_active_game_repository.dart';
import 'package:nexus_mortis/data/local/isar_database.dart';
import 'package:nexus_mortis/data/local/isar_progress_repository.dart';
import 'package:nexus_mortis/data/local/isar_statistics_repository.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/features/case_selection/resume_game_page.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/statistics/services/statistics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar la persistencia (Isar)
  final isar = await IsarDatabase.open();

  // Inicializar repositorios
  final progressRepository = IsarProgressRepository(isar);
  final activeGameRepository = IsarActiveGameRepository(isar);
  final statisticsRepository = IsarStatisticsRepository(isar);
  final achievementRepository = IsarAchievementRepository(isar);

  // Inicializar servicios
  final initialProgress = await progressRepository.loadProgress();
  final progressionService = ProgressionService(
    progressRepository,
    initialProgress: initialProgress,
  );

  final initialStatistics = await statisticsRepository.loadStatistics();
  final statisticsService = StatisticsService(
    statisticsRepository,
    initialStatistics: initialStatistics,
  );

  final initialAchievements = await achievementRepository.loadAchievements();
  final achievementService = AchievementService(
    achievementRepository,
    initialProgress: initialAchievements,
  );

  final saveGameService = SaveGameService(activeGameRepository);
  final activeGameState = await saveGameService.loadGame();

  final hintService = HintService(clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));
  final economyService = HintEconomyService(
    progressionService: progressionService,
    hintService: hintService,
  );

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

  // Conectar el registro de pistas usadas exclusivamente desde HintEconomyService
  economyService.onHintPurchased = gameSessionService.recordHintUsed;

  runApp(NexusMortisApp(
    progressionService: progressionService,
    saveGameService: saveGameService,
    economyService: economyService,
    proceduralCaseService: proceduralCaseService,
    gameSessionService: gameSessionService,
    activeGameState: activeGameState,
  ));
}

/// The root widget of the Nexus Mortis application.
class NexusMortisApp extends StatelessWidget {
  const NexusMortisApp({
    super.key,
    required this.progressionService,
    required this.saveGameService,
    required this.economyService,
    required this.proceduralCaseService,
    required this.gameSessionService,
    this.activeGameState,
  });

  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;
  final ProceduralCaseService proceduralCaseService;
  final GameSessionService gameSessionService;
  final ActiveGameState? activeGameState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Mortis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121214),
      ),
      home: activeGameState != null
          ? ResumeGamePage(
              saveState: activeGameState!,
              progressionService: progressionService,
              saveGameService: saveGameService,
              economyService: economyService,
              proceduralCaseService: proceduralCaseService,
              sessionService: gameSessionService,
            )
          : CaseSelectionPage(
              progressionService: progressionService,
              saveGameService: saveGameService,
              economyService: economyService,
              proceduralCaseService: proceduralCaseService,
              sessionService: gameSessionService,
            ),
    );
  }
}
