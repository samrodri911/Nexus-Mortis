import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';

class MockProgressRepo extends Mock implements ProgressRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(PlayerProgress.empty());
  });

  group('ProceduralCaseService & Continuous Campaign', () {
    late MockProgressRepo mockRepo;

    setUp(() {
      mockRepo = MockProgressRepo();
      when(() => mockRepo.saveProgress(any())).thenAnswer((_) async {});
    });

    test('getNextCase devuelve casos de campaña en orden inicial (case_001)', () async {
      final progressionService = ProgressionService(mockRepo);
      final campaignRepo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: campaignRepo);
      final service = ProceduralCaseService(
        progressionService: progressionService,
        caseCampaignService: campaignService,
      );

      final nextCase = await service.getNextCase();
      expect(nextCase.id, 'case_001');
    });

    test('getNextCase genera un lote de 10 casos procedurales (case_004..case_013) al completar los estáticos', () async {
      final pCompleted = PlayerProgress(
        coins: 100,
        totalStars: 9,
        completedCases: {
          'case_001': const CaseProgress(caseId: 'case_001', completed: true, starsEarned: 3),
          'case_002': const CaseProgress(caseId: 'case_002', completed: true, starsEarned: 3),
          'case_003': const CaseProgress(caseId: 'case_003', completed: true, starsEarned: 3),
        },
      );

      final progressionService = ProgressionService(mockRepo, initialProgress: pCompleted);
      final campaignRepo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: campaignRepo);
      final service = ProceduralCaseService(
        progressionService: progressionService,
        caseCampaignService: campaignService,
      );

      final nextCase = await service.getNextCase();
      expect(nextCase.id, 'case_004');
      
      final availableCases = await service.getAvailableCases();
      expect(availableCases.length, greaterThanOrEqualTo(13));
    });
  });
}
