import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/models/game_session_status.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';
import 'package:nexus_mortis/game/statistics/services/statistics_service.dart';

// â”€â”€â”€ Mocks simples â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FakeProgressRepo implements ProgressRepository {
  PlayerProgress _current = PlayerProgress.empty();

  @override
  Future<PlayerProgress> loadProgress() async => _current;

  @override
  Future<void> saveProgress(PlayerProgress p) async => _current = p;

  @override
  Future<void> clearProgress() async => _current = PlayerProgress.empty();
}

class _FakeActiveGameRepo implements ActiveGameRepository {
  ActiveGameState? _saved;

  @override
  Future<void> saveGame(ActiveGameState state) async => _saved = state;

  @override
  Future<ActiveGameState?> loadGame() async => _saved;

  @override
  Future<void> clearGame() async => _saved = null;
}

class _FakeStatsRepo implements StatisticsRepository {
  @override
  Future<PlayerStatistics> loadStatistics() async => PlayerStatistics.empty();

  @override
  Future<void> saveStatistics(PlayerStatistics s) async {}

  @override
  Future<void> clearStatistics() async {}
}

class _FakeAchRepo implements AchievementRepository {
  @override
  Future<Map<String, AchievementProgress>> loadAchievements() async => {};

  @override
  Future<void> saveAchievement(AchievementProgress p) async {}

  @override
  Future<void> saveAll(List<AchievementProgress> progresses) async {}

  @override
  Future<void> clearAchievements() async {}
}

// â”€â”€â”€ Factory â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Builds a [CaseSelectionPage] inside a [MaterialApp] wrapping context.
Future<Widget> _buildPage({
  PlayerProgress? progress,
  GameSessionService? sessionServiceOverride,
}) async {
  final progressRepo = _FakeProgressRepo();
  final progressionService = ProgressionService(
    progressRepo,
    initialProgress: progress ?? PlayerProgress.empty(),
  );

  final activeGameRepo = _FakeActiveGameRepo();
  final saveGameService = SaveGameService(activeGameRepo);

  final statsRepo = _FakeStatsRepo();
  final statisticsService = StatisticsService(statsRepo);

  final achRepo = _FakeAchRepo();
  final achievementService = AchievementService(achRepo);

  final hintService = HintService(
    clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()),
  );
  final economyService = HintEconomyService(
    progressionService: progressionService,
    hintService: hintService,
  );

  final campaignRepo = InMemoryCampaignCaseRepository();
  final campaignService = CaseCampaignService(campaignCaseRepository: campaignRepo);
  await campaignService.ensureBatchAvailable(progressionService.progress);

  final proceduralCaseService = ProceduralCaseService(
    progressionService: progressionService,
    caseCampaignService: campaignService,
  );

  final sessionService = sessionServiceOverride ??
      GameSessionService(
        progressionService: progressionService,
        saveGameService: saveGameService,
        statisticsService: statisticsService,
        achievementService: achievementService,
      );

  return MaterialApp(
    home: CaseSelectionPage(
      progressionService: progressionService,
      saveGameService: saveGameService,
      economyService: economyService,
      proceduralCaseService: proceduralCaseService,
      sessionService: sessionService,
    ),
  );
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('CaseSelectionPage — Renderizado de casos', () {
    testWidgets('muestra la lista de casos de campaña procedurales', (tester) async {
      final widget = await _buildPage();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('EXPEDIENTES DE INVESTIGACIÓN'), findsOneWidget);
      expect(find.textContaining('Expediente #01'), findsOneWidget);
      expect(find.textContaining('Expediente #02'), findsOneWidget);
    });

    testWidgets('primer caso de campaña aparece desbloqueado (sin requiredCaseId)', (tester) async {
      final widget = await _buildPage();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.textContaining('Expediente #01'), findsOneWidget);
    });

    testWidgets('muestra el header con monedas iniciales', (tester) async {
      final widget = await _buildPage();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      // PlayerProgress.empty() tiene 500 monedas
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('NO muestra banner de sesión pausada cuando no hay sesión activa', (tester) async {
      final widget = await _buildPage();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Tienes una investigación en curso'), findsNothing);
    });
  });

  group('CaseSelectionPage — Estado de progreso', () {
    testWidgets('muestra estrellas del caso completado', (tester) async {
      final progressWithCase = const PlayerProgress(
        coins: 600,
        totalStars: 3,
        completedCases: {
          'case_001': CaseProgress(
            caseId: 'case_001',
            completed: true,
            starsEarned: 3,
          ),
        },
      );

      final widget = await _buildPage(progress: progressWithCase);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });

  group('CaseSelectionPage — Banner de sesión pausada', () {
    testWidgets('muestra banner de continuar cuando hay sesión pausada en memoria', (tester) async {
      const pausedCase = CaseData(
        id: 'case_001',
        title: 'Expediente #01: Caso de Prueba',
        description: '',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        suspects: [],
        victimId: 'dummy1',
        killerId: 'dummy2',
        zones: [],
        placedObjects: [],
        clues: [],
        solution: SolutionData(suspectPositions: {}),
        origin: CaseOrigin.campaign,
      );

      final progressRepo = _FakeProgressRepo();
      final progressionService = ProgressionService(progressRepo);

      final activeGameRepo = _FakeActiveGameRepo();
      final saveGameService = SaveGameService(activeGameRepo);

      final sessionService = GameSessionService(
        progressionService: progressionService,
        saveGameService: SaveGameService(_FakeActiveGameRepo()),
        statisticsService: StatisticsService(_FakeStatsRepo()),
        achievementService: AchievementService(_FakeAchRepo()),
      );

      // Iniciar sesión para que quede en estado playing
      await sessionService.startNewGame(pausedCase);
      // Pausar sin controlador (no guarda en disco, pero cambia el status)
      await sessionService.pauseGame();

      expect(sessionService.currentSession?.status, GameSessionStatus.paused,
          reason: 'La sesión debe estar pausada para que aparezca el banner');

      final hintService = HintService(
        clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()),
      );
      final economyService = HintEconomyService(
        progressionService: progressionService,
        hintService: hintService,
      );
      final campaignRepo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: campaignRepo);
      await campaignService.ensureBatchAvailable(progressionService.progress);

      final proceduralCaseService = ProceduralCaseService(
        progressionService: progressionService,
        caseCampaignService: campaignService,
      );

      await tester.pumpWidget(MaterialApp(
        home: CaseSelectionPage(
          progressionService: progressionService,
          saveGameService: saveGameService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tienes una investigación en curso'), findsOneWidget);
      expect(find.text('CONTINUAR'), findsOneWidget);
    });
  });
}

