import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';

abstract class CampaignCaseRepository {
  /// Obtiene todos los casos generados de la campaña persistidos en orden.
  Future<List<CampaignCaseEntity>> getAllCases();

  /// Guarda una lista de casos generados de forma atómica.
  Future<void> saveCases(List<CampaignCaseEntity> cases);

  /// Obtiene un caso por su caseId lógico.
  Future<CampaignCaseEntity?> getCaseById(String caseId);

  /// Limpia la colección de casos (para testing).
  Future<void> clear();
}
