import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/repositories/campaign_case_repository.dart';

/// Implementación en memoria de [CampaignCaseRepository] para testing y fallbacks.
class InMemoryCampaignCaseRepository implements CampaignCaseRepository {
  final List<CampaignCaseEntity> _cases = [];

  @override
  Future<List<CampaignCaseEntity>> getAllCases() async {
    return List.unmodifiable(_cases..sort((a, b) => a.caseIndex.compareTo(b.caseIndex)));
  }

  @override
  Future<void> saveCases(List<CampaignCaseEntity> cases) async {
    for (final c in cases) {
      _cases.removeWhere((existing) => existing.caseId == c.caseId);
      _cases.add(c);
    }
  }

  @override
  Future<CampaignCaseEntity?> getCaseById(String caseId) async {
    for (final c in _cases) {
      if (c.caseId == caseId) return c;
    }
    return null;
  }

  @override
  Future<void> clear() async {
    _cases.clear();
  }
}
