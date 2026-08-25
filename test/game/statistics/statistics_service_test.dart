import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_mortis/data/repositories/statistics_repository.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';
import 'package:nexus_mortis/game/statistics/services/statistics_service.dart';

class MockStatisticsRepository extends Mock implements StatisticsRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(PlayerStatistics.empty());
  });

  late MockStatisticsRepository mockRepo;
  late StatisticsService service;

  setUp(() {
    mockRepo = MockStatisticsRepository();
    when(() => mockRepo.saveStatistics(any())).thenAnswer((_) async {});
    service = StatisticsService(mockRepo);
  });

  group('StatisticsService', () {
    test('Ignora resultados no resueltos', () async {
      const result = GameResult(
        caseId: 'c1',
        caseOrigin: CaseOrigin.campaign,
        solved: false,
        stars: 0,
        coinsEarned: 0,
        hintsUsed: 1,
        mistakes: 2,
        duration: Duration(minutes: 1),
        difficulty: PuzzleDifficulty.easy,
      );

      await service.recordResult(result);

      expect(service.statistics.puzzlesSolved, 0);
      verifyNever(() => mockRepo.saveStatistics(any()));
    });

    test('Acumula estadísticas de casos de campaña y procedimentales correctamente', () async {
      const resCampaign = GameResult(
        caseId: 'demo_001',
        caseOrigin: CaseOrigin.campaign,
        solved: true,
        stars: 3,
        coinsEarned: 100,
        hintsUsed: 0,
        mistakes: 0,
        duration: Duration(seconds: 90),
        difficulty: PuzzleDifficulty.easy,
      );

      await service.recordResult(resCampaign);

      expect(service.statistics.puzzlesSolved, 1);
      expect(service.statistics.campaignCasesSolved, 1);
      expect(service.statistics.proceduralCasesSolved, 0);
      expect(service.statistics.totalPlayTime.inSeconds, 90);
      expect(service.statistics.totalCoinsEarned, 100);
      expect(service.statistics.totalStarsEarned, 3);
      expect(service.statistics.bestStarsPerCase['demo_001'], 3);

      const resProcedural = GameResult(
        caseId: 'procedural_456',
        caseOrigin: CaseOrigin.procedural,
        solved: true,
        stars: 2,
        coinsEarned: 75,
        hintsUsed: 1,
        mistakes: 1,
        duration: Duration(seconds: 120),
        difficulty: PuzzleDifficulty.medium,
      );

      await service.recordResult(resProcedural);

      expect(service.statistics.puzzlesSolved, 2);
      expect(service.statistics.campaignCasesSolved, 1);
      expect(service.statistics.proceduralCasesSolved, 1);
      expect(service.statistics.totalPlayTime.inSeconds, 210);
      expect(service.statistics.totalHintsUsed, 1);
      expect(service.statistics.totalCoinsEarned, 175);
      expect(service.statistics.totalStarsEarned, 5);
      expect(service.statistics.bestStarsPerCase['procedural_456'], 2);

      verify(() => mockRepo.saveStatistics(any())).called(2);
    });
  });
}
