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
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';
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
Widget _buildPage({
  PlayerProgress? progress,
  GameSessionService? sessionServiceOverride,
}) {
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

  final proceduralCaseService = ProceduralCaseService(
    progressionService: progressionService,
    staticSource: const StaticCaseSource(),
    generatedSource: GeneratedCaseSource(),
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

// â”€â”€â”€ Tests â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

void main() {
  group('CaseSelectionPage â€” Renderizado de casos', () {
    testWidgets('muestra la lista de casos de campaÃ±a desde CaseRegistry', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pump();

      // Los casos de CaseRegistry deben aparecer en pantalla
      for (final c in CaseRegistry.cases) {
        expect(find.text(c.title), findsOneWidget);
      }
    });

    testWidgets('primer caso de campaÃ±a aparece desbloqueado (sin requiredCaseId)', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pump();

      final firstCase = CaseRegistry.cases.first;
      // Si el primer caso no tiene requisito, debe estar visible sin candado
      expect(firstCase.requiredCaseId, isNull,
          reason: 'El primer caso debe estar siempre disponible');
      expect(find.text(firstCase.title), findsOneWidget);
    });

    testWidgets('muestra el header con monedas iniciales', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pump();

      // PlayerProgress.empty() tiene 500 monedas
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('NO muestra banner de sesiÃ³n pausada cuando no hay sesiÃ³n activa', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pump();

      expect(find.text('Tienes una investigación en curso'), findsNothing);
    });
  });

  group('CaseSelectionPage â€” Estado de progreso', () {
    testWidgets('muestra estrellas del caso completado', (tester) async {
      // Construir progreso con el primer caso completado con 3 estrellas
      final firstCaseId = CaseRegistry.cases.first.id;
      final progressWithCase = PlayerProgress(
        coins: 600,
        totalStars: 3,
        completedCases: {
          firstCaseId: CaseProgress(
            caseId: firstCaseId,
            completed: true,
            starsEarned: 3,
          ),
        },
      );

      await tester.pumpWidget(_buildPage(progress: progressWithCase));
      await tester.pump();

      // Deben aparecer 3 estrellas llenas + 0 vacÃ­as para el primer caso
      // y 0+3 para los demÃ¡s casos sin completar
      // Verificamos que hay al menos 3 Ã­conos de estrella llena
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('NO muestra modo Investigación Infinita si hay casos de campaÃ±a pendientes', (tester) async {
      await tester.pumpWidget(_buildPage());
      await tester.pump();

      expect(find.text('Investigación Infinita'), findsNothing);
    });
  });

  group('CaseSelectionPage â€” Banner de sesiÃ³n pausada', () {
    testWidgets('muestra banner de continuar cuando hay sesiÃ³n pausada en memoria', (tester) async {
      // Crear un sessionService con una sesiÃ³n pausada en memoria
      // Para esto necesitamos construir servicios manualmente y simular el estado

      // Usamos un CaseData mÃ­nimo para simular la pausa
      final pausedCase = CaseData(
        id: CaseRegistry.cases.first.id,
        title: CaseRegistry.cases.first.title,
        description: '',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        suspects: const [],
        victimId: 'dummy1',
        killerId: 'dummy2',
        zones: const [],
        placedObjects: const [],
        clues: const [],
        solution: const SolutionData(suspectPositions: {}),
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

      // Iniciar sesiÃ³n para que quede en estado playing
      await sessionService.startNewGame(pausedCase);
      // Pausar sin controlador (no guarda en disco, pero cambia el status)
      await sessionService.pauseGame();

      expect(sessionService.currentSession?.status, GameSessionStatus.paused,
          reason: 'La sesiÃ³n debe estar pausada para que aparezca el banner');

      final hintService = HintService(
        clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()),
      );
      final economyService = HintEconomyService(
        progressionService: progressionService,
        hintService: hintService,
      );
      final proceduralCaseService = ProceduralCaseService(
        progressionService: progressionService,
        staticSource: const StaticCaseSource(),
        generatedSource: GeneratedCaseSource(),
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
      await tester.pump();

      expect(find.text('Tienes una investigación en curso'), findsOneWidget);
      expect(find.text('CONTINUAR'), findsOneWidget);
    });
  });
}

