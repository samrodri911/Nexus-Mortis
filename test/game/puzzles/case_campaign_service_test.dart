import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';

void main() {
  group('CaseCampaignService & Batch Generation', () {
    test('ensureBatchAvailable genera 10 casos procedurales persistidos (Niveles 0..9)', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: repo);

      await campaignService.ensureBatchAvailable(PlayerProgress.empty());
      final allCases = await campaignService.getAvailableCases();

      expect(allCases.length, equals(10)); // Lote inicial 100% procedural
      expect(allCases[0].id, equals('case_001'));
      expect(allCases[1].id, equals('case_002'));
      expect(allCases[2].id, equals('case_003'));
      expect(allCases[3].id, equals('case_004'));
      expect(allCases[9].id, equals('case_010'));
    });

    test('Casos generados persisten y se reconstruyen de forma idéntica', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService1 = CaseCampaignService(campaignCaseRepository: repo);
      await campaignService1.ensureBatchAvailable(PlayerProgress.empty());

      final case1Run1 = await campaignService1.getCase('case_001');
      expect(case1Run1, isNotNull);

      final campaignService2 = CaseCampaignService(campaignCaseRepository: repo);
      final case1Run2 = await campaignService2.getCase('case_001');

      expect(case1Run2, isNotNull);
      expect(case1Run2!.title, equals(case1Run1!.title));
      expect(case1Run2.boardRows, equals(case1Run1.boardRows));
      expect(case1Run2.solution.suspectPositions, equals(case1Run1.solution.suspectPositions));
      expect(case1Run2.killerId, equals(case1Run1.killerId));
      expect(case1Run2.victimId, equals(case1Run1.victimId));
    });
    test('Sanea automáticamente base de datos legacy con casos que empezaban en case_004', () async {
      final repo = InMemoryCampaignCaseRepository();
      // Simular base de datos legacy con case_004 como primer registro
      final legacyEntity = CampaignCaseEntity()
        ..caseId = 'case_004'
        ..caseIndex = 4
        ..title = 'Expediente Legacy'
        ..description = ''
        ..difficulty = 'easy'
        ..seed = 123456
        ..rows = 4
        ..columns = 4
        ..suspects = 3
        ..objects = 2
        ..requiredCaseId = 'case_003';
      await repo.saveCases([legacyEntity]);

      final campaignService = CaseCampaignService(campaignCaseRepository: repo);
      final allCases = await campaignService.getAvailableCases();

      // Debe haber limpiado los casos legacy y regenerado desde case_001
      expect(allCases.isNotEmpty, isTrue);
      expect(allCases.first.id, equals('case_001'));
      expect(allCases.first.requiredCaseId, isNull);
    });
  });
}
