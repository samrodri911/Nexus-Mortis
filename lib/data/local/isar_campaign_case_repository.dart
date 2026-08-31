import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/repositories/campaign_case_repository.dart';

class IsarCampaignCaseRepository implements CampaignCaseRepository {
  IsarCampaignCaseRepository(this._isar);

  final Isar _isar;

  @override
  Future<List<CampaignCaseEntity>> getAllCases() async {
    return await _isar.campaignCaseEntitys.where().sortByCaseIndex().findAll();
  }

  @override
  Future<void> saveCases(List<CampaignCaseEntity> cases) async {
    await _isar.writeTxn(() async {
      for (final c in cases) {
        final existing = await _isar.campaignCaseEntitys.filter().caseIdEqualTo(c.caseId).findFirst();
        if (existing != null) {
          c.id = existing.id;
        }
      }
      await _isar.campaignCaseEntitys.putAll(cases);
    });
  }

  @override
  Future<CampaignCaseEntity?> getCaseById(String caseId) async {
    return await _isar.campaignCaseEntitys.filter().caseIdEqualTo(caseId).findFirst();
  }

  @override
  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.campaignCaseEntitys.clear();
    });
  }
}
