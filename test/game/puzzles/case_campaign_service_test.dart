import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';

void main() {
  group('CaseCampaignService & Batch Generation', () {
    test('ensureBatchAvailable genera 10 casos adicionales persistidos (total 13)', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: repo);

      await campaignService.ensureBatchAvailable(PlayerProgress.empty());
      final allCases = await campaignService.getAvailableCases();

      expect(allCases.length, equals(13)); // 3 estáticos + 10 del primer lote
      expect(allCases[0].id, equals('case_001'));
      expect(allCases[1].id, equals('case_002'));
      expect(allCases[2].id, equals('case_003'));
      expect(allCases[3].id, equals('case_004'));
      expect(allCases[12].id, equals('case_013'));
    });

    test('Casos generados persisten y se reconstruyen de forma idéntica', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService1 = CaseCampaignService(campaignCaseRepository: repo);
      await campaignService1.ensureBatchAvailable(PlayerProgress.empty());

      final case4Run1 = await campaignService1.getCase('case_004');
      expect(case4Run1, isNotNull);

      final campaignService2 = CaseCampaignService(campaignCaseRepository: repo);
      final case4Run2 = await campaignService2.getCase('case_004');

      expect(case4Run2, isNotNull);
      expect(case4Run2!.title, equals(case4Run1!.title));
      expect(case4Run2.boardRows, equals(case4Run1.boardRows));
      expect(case4Run2.solution.suspectPositions, equals(case4Run1.solution.suspectPositions));
      expect(case4Run2.killerId, equals(case4Run1.killerId));
      expect(case4Run2.victimId, equals(case4Run1.victimId));
    });
  });
}
