import 'dart:async';

import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/generated_case_metadata.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';
import 'package:nexus_mortis/game/puzzles/services/case_identity_factory.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_difficulty_policy.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';

/// Punto de entrada y orquestador unificado de casos de campaña y procedimentales.
class ProceduralCaseService {
  ProceduralCaseService({
    required this.progressionService,
    CaseCampaignService? caseCampaignService,
    StaticCaseSource? staticSource,
    GeneratedCaseSource? generatedSource,
    this.difficultyPolicy = const ProceduralDifficultyPolicy(),
    this.identityFactory = const CaseIdentityFactory(),
  }) : caseCampaignService = caseCampaignService ??
            CaseCampaignService(
              campaignCaseRepository: InMemoryCampaignCaseRepository(),
              staticSource: staticSource ?? const StaticCaseSource(),
              identityFactory: identityFactory,
            );

  final ProgressionService progressionService;
  final CaseCampaignService caseCampaignService;
  final ProceduralDifficultyPolicy difficultyPolicy;
  final CaseIdentityFactory identityFactory;

  /// Retorna todos los casos disponibles en la campaña continua.
  Future<List<CaseData>> getAvailableCases() async {
    await caseCampaignService.ensureBatchAvailable(progressionService.progress);
    return await caseCampaignService.getAvailableCases();
  }

  /// Retorna el siguiente caso a jugar en la campaña continua.
  Future<CaseData> getNextCase() async {
    final next = await caseCampaignService.getNextCase(progressionService.progress);
    if (next != null) {
      return next;
    }

    final cases = await caseCampaignService.getAvailableCases();
    return cases.firstWhere(
      (c) => !progressionService.isCaseCompleted(c.id),
      orElse: () => cases.first,
    );
  }

  /// Recupera un caso por su ID para Save, Resume o selección directa.
  Future<CaseData?> getCaseById(String id, {GeneratedCaseMetadata? metadata}) async {
    return await caseCampaignService.getCase(id);
  }
}
