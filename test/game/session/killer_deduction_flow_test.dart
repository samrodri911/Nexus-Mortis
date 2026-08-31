import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/models/reward_data.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
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
class FakeAchievementProgress extends Fake implements AchievementProgress {}

void main() {
  setUpAll(() {
    registerFallbackValue(PlayerProgress.empty());
    registerFallbackValue(const RewardData(coins: 0, stars: 0));
    registerFallbackValue(PlayerStatistics.empty());
    registerFallbackValue(<AchievementProgress>[]);
    registerFallbackValue(FakeAchievementProgress());
    registerFallbackValue(
      ActiveGameState(
        caseId: 'fallback',
        cells: const [],
        savedAt: DateTime.now(),
      ),
    );
  });

  group('Killer Deduction & Game Session Flow', () {
    late MockProgressRepository mockProgressRepo;
    late MockActiveGameRepository mockActiveGameRepo;
    late MockStatisticsRepository mockStatsRepo;
    late MockAchievementRepository mockAchRepo;

    late ProgressionService progressionService;
    late SaveGameService saveGameService;
    late StatisticsService statisticsService;
    late AchievementService achievementService;
    late GameSessionService sessionService;

    setUp(() {
      mockProgressRepo = MockProgressRepository();
      mockActiveGameRepo = MockActiveGameRepository();
      mockStatsRepo = MockStatisticsRepository();
      mockAchRepo = MockAchievementRepository();

      when(() => mockProgressRepo.saveProgress(any())).thenAnswer((_) async {});
      when(() => mockActiveGameRepo.clearGame()).thenAnswer((_) async {});
      when(() => mockActiveGameRepo.loadGame()).thenAnswer((_) async => null);
      when(() => mockStatsRepo.saveStatistics(any())).thenAnswer((_) async {});
      when(() => mockAchRepo.saveAll(any())).thenAnswer((_) async {});
      when(() => mockAchRepo.saveAchievement(any())).thenAnswer((_) async {});
      when(() => mockAchRepo.loadAchievements()).thenAnswer((_) async => {});

      progressionService = ProgressionService(mockProgressRepo);
      saveGameService = SaveGameService(mockActiveGameRepo);
      statisticsService = StatisticsService(mockStatsRepo);
      achievementService = AchievementService(mockAchRepo);
      sessionService = GameSessionService(
        progressionService: progressionService,
        saveGameService: saveGameService,
        statisticsService: statisticsService,
        achievementService: achievementService,
      );
    });

    test('setAwaitingKiller cambia el estado a awaitingKiller', () async {
      await sessionService.startNewGame(demoCase001);
      expect(sessionService.currentSession?.status, equals(GameSessionStatus.playing));

      sessionService.setAwaitingKiller();
      expect(sessionService.currentSession?.status, equals(GameSessionStatus.awaitingKiller));
      expect(sessionService.hasActiveSession, isTrue);
    });

    test('submitKillerDeduction con sospechoso INCORRECTO penaliza mistake y no completa', () async {
      await sessionService.startNewGame(demoCase001);
      sessionService.setAwaitingKiller();

      final result = await sessionService.submitKillerDeduction('suspect_juan');
      expect(result, isNull);
      expect(sessionService.mistakes, equals(1));
      expect(sessionService.currentSession?.status, equals(GameSessionStatus.awaitingKiller));
      expect(progressionService.isCaseCompleted(demoCase001.id), isFalse);
    });

    test('submitKillerDeduction con sospechoso CORRECTO completa el caso y otorga recompensas', () async {
      await sessionService.startNewGame(demoCase001);
      sessionService.setAwaitingKiller();

      final result = await sessionService.submitKillerDeduction(demoCase001.killerId);
      expect(result, isNotNull);
      expect(result!.solved, isTrue);
      expect(sessionService.currentSession?.status, equals(GameSessionStatus.solved));
      expect(progressionService.isCaseCompleted(demoCase001.id), isTrue);
      expect(progressionService.progress.coins, greaterThan(500));
    });

    test('submitKillerDeduction funciona correctamente incluso si la sesión estaba en estado paused', () async {
      await sessionService.startNewGame(demoCase001);
      await sessionService.pauseGame();
      expect(sessionService.currentSession?.status, equals(GameSessionStatus.paused));

      final result = await sessionService.submitKillerDeduction(demoCase001.killerId);
      expect(result, isNotNull);
      expect(result!.solved, isTrue);
      expect(sessionService.currentSession?.status, equals(GameSessionStatus.solved));
      expect(progressionService.isCaseCompleted(demoCase001.id), isTrue);
    });
  });
}
