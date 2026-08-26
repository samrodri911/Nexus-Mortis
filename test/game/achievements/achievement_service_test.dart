import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';

class MockAchievementRepository extends Mock implements AchievementRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<AchievementProgress>[]);
  });

  late MockAchievementRepository mockRepo;
  late AchievementService service;

  final dummyCampaignCases = [
    CaseData(
      id: 'demo_001',
      title: 'Caso 1',
      description: '',
      difficulty: PuzzleDifficulty.easy,
      boardRows: 3,
      boardColumns: 3,
      suspects: const [],
      victimId: 'dummy1', killerId: 'dummy2', zones: const [], placedObjects: const [],
      clues: const [],
      solution: const SolutionData(suspectPositions: {}),
      origin: CaseOrigin.campaign,
    ),
    CaseData(
      id: 'demo_002',
      title: 'Caso 2',
      description: '',
      difficulty: PuzzleDifficulty.medium,
      boardRows: 3,
      boardColumns: 3,
      suspects: const [],
      victimId: 'dummy1', killerId: 'dummy2', zones: const [], placedObjects: const [],
      clues: const [],
      solution: const SolutionData(suspectPositions: {}),
      origin: CaseOrigin.campaign,
    ),
  ];

  setUp(() {
    mockRepo = MockAchievementRepository();
    when(() => mockRepo.saveAll(any())).thenAnswer((_) async {});
    service = AchievementService(mockRepo);
  });

  group('AchievementService', () {
    test('Desbloquea primer caso y caso sin pistas al resolver impecable', () async {
      const result = GameResult(
        caseId: 'demo_001',
        caseOrigin: CaseOrigin.campaign,
        solved: true,
        stars: 3,
        coinsEarned: 100,
        hintsUsed: 0,
        mistakes: 0,
        duration: Duration(minutes: 1),
        difficulty: PuzzleDifficulty.easy,
      );

      final stats = PlayerStatistics.empty().copyWithResult(result);
      final progress = PlayerProgress(
        coins: 100,
        totalStars: 3,
        completedCases: {
          'demo_001': const CaseProgress(caseId: 'demo_001', completed: true, starsEarned: 3),
        },
      );

      final unlocked = await service.processResult(
        result: result,
        statistics: stats,
        playerProgress: progress,
        campaignCases: dummyCampaignCases,
      );

      final unlockedIds = unlocked.map((a) => a.id).toSet();
      expect(unlockedIds.contains('first_case'), isTrue);
      expect(unlockedIds.contains('first_3_stars'), isTrue);
      expect(unlockedIds.contains('no_hints'), isTrue);
      expect(service.isUnlocked('first_case'), isTrue);
      expect(service.isUnlocked('first_3_stars'), isTrue);
      expect(service.isUnlocked('no_hints'), isTrue);
      expect(service.isUnlocked('campaign_complete'), isFalse);
    });

    test('Desbloquea campaign_complete dinámicamente cuando todos los casos de campaña están completos', () async {
      const result = GameResult(
        caseId: 'demo_002',
        caseOrigin: CaseOrigin.campaign,
        solved: true,
        stars: 3,
        coinsEarned: 100,
        hintsUsed: 0,
        mistakes: 0,
        duration: Duration(minutes: 1),
        difficulty: PuzzleDifficulty.medium,
      );

      final stats = PlayerStatistics.empty()
          .copyWith(puzzlesSolved: 2, campaignCasesSolved: 2, totalStarsEarned: 6);
      final progress = PlayerProgress(
        coins: 200,
        totalStars: 6,
        completedCases: {
          'demo_001': const CaseProgress(caseId: 'demo_001', completed: true, starsEarned: 3),
          'demo_002': const CaseProgress(caseId: 'demo_002', completed: true, starsEarned: 3),
        },
      );

      final unlocked = await service.processResult(
        result: result,
        statistics: stats,
        playerProgress: progress,
        campaignCases: dummyCampaignCases,
      );

      final unlockedIds = unlocked.map((a) => a.id).toSet();
      expect(unlockedIds.contains('campaign_complete'), isTrue);
      expect(service.isUnlocked('campaign_complete'), isTrue);
    });

    test('Logros ya desbloqueados no se vuelven a desbloquear ni notificar', () async {
      const result = GameResult(
        caseId: 'demo_001',
        caseOrigin: CaseOrigin.campaign,
        solved: true,
        stars: 3,
        coinsEarned: 100,
        hintsUsed: 0,
        mistakes: 0,
        duration: Duration(minutes: 1),
        difficulty: PuzzleDifficulty.easy,
      );

      final stats = PlayerStatistics.empty().copyWithResult(result);
      final progress = PlayerProgress(
        coins: 100,
        totalStars: 3,
        completedCases: {
          'demo_001': const CaseProgress(caseId: 'demo_001', completed: true, starsEarned: 3),
        },
      );

      // Primer proceso
      await service.processResult(
        result: result,
        statistics: stats,
        playerProgress: progress,
        campaignCases: dummyCampaignCases,
      );

      // Segundo proceso
      final unlockedSecondTime = await service.processResult(
        result: result,
        statistics: stats,
        playerProgress: progress,
        campaignCases: dummyCampaignCases,
      );

      expect(unlockedSecondTime, isEmpty);
    });
  });
}
