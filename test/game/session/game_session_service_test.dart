import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/models/reward_data.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/results/services/star_calculator.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/models/game_session_status.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';
import 'package:nexus_mortis/game/statistics/services/statistics_service.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

class MockActiveGameRepository extends Mock implements ActiveGameRepository {}

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

class MockAchievementRepository extends Mock implements AchievementRepository {}

class MockBoardController extends Mock implements BoardController {}

void main() {
  setUpAll(() {
    registerFallbackValue(PlayerProgress.empty());
    registerFallbackValue(const RewardData(coins: 0, stars: 0));
    registerFallbackValue(PlayerStatistics.empty());
    registerFallbackValue(<AchievementProgress>[]);
    registerFallbackValue(
      ActiveGameState(
        caseId: 'fallback',
        cells: const [],
        savedAt: DateTime.now(),
      ),
    );
  });

  late MockProgressRepository mockProgressRepo;
  late MockActiveGameRepository mockActiveGameRepo;
  late MockStatisticsRepository mockStatsRepo;
  late MockAchievementRepository mockAchRepo;

  late ProgressionService progressionService;
  late SaveGameService saveGameService;
  late StatisticsService statisticsService;
  late AchievementService achievementService;
  late GameSessionService sessionService;

  final testCase = CaseData(
    id: 'case_001',
    title: 'Caso de Prueba',
    description: 'Descripción',
    difficulty: PuzzleDifficulty.easy,
    boardRows: 3,
    boardColumns: 3,
    suspects: const [],
    placedObjects: const [],
    clues: const [],
    solution: const SolutionData(suspectPositions: {}),
    origin: CaseOrigin.campaign,
  );

  final testCaseProcedural = CaseData(
    id: 'procedural_123',
    title: 'Caso Procedural',
    description: 'Descripción',
    difficulty: PuzzleDifficulty.hard,
    boardRows: 4,
    boardColumns: 4,
    suspects: const [],
    placedObjects: const [],
    clues: const [],
    solution: const SolutionData(suspectPositions: {}),
    origin: CaseOrigin.procedural,
  );

  setUp(() {
    mockProgressRepo = MockProgressRepository();
    mockActiveGameRepo = MockActiveGameRepository();
    mockStatsRepo = MockStatisticsRepository();
    mockAchRepo = MockAchievementRepository();

    when(() => mockProgressRepo.loadProgress())
        .thenAnswer((_) async => PlayerProgress.empty());
    when(() => mockProgressRepo.saveProgress(any()))
        .thenAnswer((_) async {});
    when(() => mockActiveGameRepo.saveGame(any()))
        .thenAnswer((_) async {});
    when(() => mockActiveGameRepo.loadGame())
        .thenAnswer((_) async => null);
    when(() => mockActiveGameRepo.clearGame())
        .thenAnswer((_) async {});
    when(() => mockStatsRepo.saveStatistics(any()))
        .thenAnswer((_) async {});
    when(() => mockAchRepo.saveAll(any()))
        .thenAnswer((_) async {});

    progressionService = ProgressionService(mockProgressRepo);
    saveGameService = SaveGameService(mockActiveGameRepo);
    statisticsService = StatisticsService(mockStatsRepo);
    achievementService = AchievementService(mockAchRepo);

    sessionService = GameSessionService(
      progressionService: progressionService,
      saveGameService: saveGameService,
      statisticsService: statisticsService,
      achievementService: achievementService,
      starCalculator: const StarCalculator(),
    );
  });

  group('GameSessionService - Start', () {
    test('startNewGame crea sesión con estado playing (Campaña)', () async {
      final session = await sessionService.startNewGame(testCase);

      expect(session.caseId, 'case_001');
      expect(session.origin, CaseOrigin.campaign);
      expect(session.status, GameSessionStatus.playing);
      expect(session.startedAt, isNotNull);
      expect(sessionService.hasActiveSession, isTrue);
      expect(sessionService.currentCase, testCase);
    });

    test('startNewGame crea sesión para caso procedural', () async {
      final session = await sessionService.startNewGame(testCaseProcedural);

      expect(session.caseId, 'procedural_123');
      expect(session.origin, CaseOrigin.procedural);
      expect(session.status, GameSessionStatus.playing);
    });

    test('startNewGame es idempotente si se invoca para el mismo caso activo', () async {
      final session1 = await sessionService.startNewGame(testCase);
      final session2 = await sessionService.startNewGame(testCase);

      expect(session1, equals(session2));
    });

    test('startNewGame lanza StateError si ya hay otra sesión activa diferente', () async {
      await sessionService.startNewGame(testCase);

      expect(
        () => sessionService.startNewGame(testCaseProcedural),
        throwsA(isA<StateError>()),
      );
    });

    test('startNewGame lanza StateError si hay una partida guardada en disco de otro caso', () async {
      when(() => mockActiveGameRepo.loadGame()).thenAnswer(
        (_) async => ActiveGameState(
          caseId: 'other_case',
          cells: const [],
          savedAt: DateTime.now(),
        ),
      );

      expect(
        () => sessionService.startNewGame(testCase),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('GameSessionService - Resume', () {
    test('resumeGame reanuda la partida y restaura metadatos', () async {
      final savedTime = DateTime(2026, 1, 1);
      final activeState = ActiveGameState(
        caseId: testCase.id,
        cells: const [],
        savedAt: savedTime,
      );

      final session = await sessionService.resumeGame(activeState, testCase);

      expect(session.caseId, testCase.id);
      expect(session.status, GameSessionStatus.playing);
      expect(session.startedAt, savedTime);
      expect(session.lastResumedAt, isNotNull);
      expect(sessionService.activeState, activeState);
      expect(sessionService.currentCase, testCase);
    });

    test('resumeGame lanza StateError si ya hay otra sesión activa', () async {
      await sessionService.startNewGame(testCaseProcedural);

      final activeState = ActiveGameState(
        caseId: testCase.id,
        cells: const [],
        savedAt: DateTime.now(),
      );

      expect(
        () => sessionService.resumeGame(activeState, testCase),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('GameSessionService - Pause & Multiple Paused events', () {
    test('pauseGame guarda el estado del tablero y cambia a paused', () async {
      await sessionService.startNewGame(testCase);

      final mockController = MockBoardController();
      when(() => mockController.exportGameState(any())).thenReturn(
        ActiveGameState(
          caseId: testCase.id,
          cells: const [],
          savedAt: DateTime.now(),
        ),
      );

      sessionService.registerController(mockController);
      await sessionService.pauseGame();

      expect(sessionService.currentSession?.status, GameSessionStatus.paused);
      expect(sessionService.currentSession?.pausedAt, isNotNull);
      verify(() => mockActiveGameRepo.saveGame(any())).called(1);
    });

    test('múltiples llamadas a pauseGame son idempotentes', () async {
      await sessionService.startNewGame(testCase);

      final mockController = MockBoardController();
      when(() => mockController.exportGameState(any())).thenReturn(
        ActiveGameState(
          caseId: testCase.id,
          cells: const [],
          savedAt: DateTime.now(),
        ),
      );

      sessionService.registerController(mockController);
      await sessionService.pauseGame();
      await sessionService.pauseGame();
      await sessionService.pauseGame();

      expect(sessionService.currentSession?.status, GameSessionStatus.paused);
      verify(() => mockActiveGameRepo.saveGame(any())).called(1);
    });
  });

  group('GameSessionService - Abandon', () {
    test('abandonGame limpia partida en disco y finaliza sesión sin otorgar recompensas', () async {
      await sessionService.startNewGame(testCase);
      await sessionService.abandonGame();

      verify(() => mockActiveGameRepo.clearGame()).called(1);
      expect(sessionService.currentSession, isNull);
      expect(progressionService.isCaseCompleted(testCase.id), isFalse);
    });

    test('abandonGame sin haber reanudado limpia partida guardada', () async {
      await sessionService.abandonGame();

      verify(() => mockActiveGameRepo.clearGame()).called(1);
      expect(sessionService.currentSession, isNull);
    });
  });

  group('GameSessionService - Complete, Results, Stats & Achievements', () {
    test('completeGame completa el caso, calcula resultado, actualiza progreso, estadísticas y logros', () async {
      await sessionService.startNewGame(testCase);

      // Partida resuelta de manera perfecta (0 pistas, 0 errores)
      final result = await sessionService.completeGame();

      expect(result.solved, isTrue);
      expect(result.stars, 3);
      // Easy (50) + 3 stars bonus (50) = 100 coins
      expect(result.coinsEarned, 100);
      expect(result.hintsUsed, 0);
      expect(result.mistakes, 0);

      // Progreso
      expect(progressionService.isCaseCompleted(testCase.id), isTrue);
      expect(progressionService.progress.coins, 500 + 100);
      expect(progressionService.progress.totalStars, 3);

      // Estadísticas
      expect(statisticsService.statistics.puzzlesSolved, 1);
      expect(statisticsService.statistics.campaignCasesSolved, 1);
      expect(statisticsService.statistics.totalCoinsEarned, 100);
      expect(statisticsService.statistics.totalStarsEarned, 3);

      // Logros
      expect(achievementService.isUnlocked('first_case'), isTrue);
      expect(achievementService.isUnlocked('first_3_stars'), isTrue);
      expect(achievementService.isUnlocked('no_hints'), isTrue);

      verify(() => mockActiveGameRepo.clearGame()).called(1);
      verify(() => mockStatsRepo.saveStatistics(any())).called(1);
    });

    test('completeGame penaliza estrellas si se usaron pistas o hubo errores', () async {
      await sessionService.startNewGame(testCase);

      sessionService.recordHintUsed();
      sessionService.recordHintUsed(); // 2 pistas -> 1 estrella

      final result = await sessionService.completeGame();

      expect(result.stars, 1);
      // Easy base = 50, 1 star bonus = 0 -> 50 coins
      expect(result.coinsEarned, 50);
      expect(result.hintsUsed, 2);
    });

    test('doble completeGame es idempotente y no duplica recompensas, estadísticas ni logros', () async {
      await sessionService.startNewGame(testCase);

      final res1 = await sessionService.completeGame();
      final res2 = await sessionService.completeGame();

      expect(res1, equals(res2));
      expect(progressionService.progress.coins, 500 + 100);
      expect(progressionService.progress.totalStars, 3);
      expect(statisticsService.statistics.puzzlesSolved, 1);
      verify(() => mockStatsRepo.saveStatistics(any())).called(1);
    });

    test('pauseGame después de solved no guarda ni altera el estado a paused', () async {
      await sessionService.startNewGame(testCase);

      final mockController = MockBoardController();
      sessionService.registerController(mockController);

      await sessionService.completeGame();
      expect(sessionService.currentSession?.status, GameSessionStatus.solved);

      await sessionService.pauseGame();

      expect(sessionService.currentSession?.status, GameSessionStatus.solved);
      verifyNever(() => mockActiveGameRepo.saveGame(any()));
    });
  });
}
