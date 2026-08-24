import 'dart:async';

import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/generated_case_metadata.dart';
import 'package:nexus_mortis/game/puzzles/services/case_identity_factory.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_difficulty_policy.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';

/// Punto de entrada unificado para que el juego obtenga casos.
/// Orquesta la transición de casos estáticos a generados sin que la UI lo note.
class ProceduralCaseService {
  ProceduralCaseService({
    required this.progressionService,
    required this.staticSource,
    required this.generatedSource,
    this.difficultyPolicy = const ProceduralDifficultyPolicy(),
    this.identityFactory = const CaseIdentityFactory(),
  });

  final ProgressionService progressionService;
  final StaticCaseSource staticSource;
  final GeneratedCaseSource generatedSource;
  final ProceduralDifficultyPolicy difficultyPolicy;
  final CaseIdentityFactory identityFactory;

  /// Retorna el siguiente caso a jugar.
  FutureOr<CaseData> getNextCase() async {
    // 1. ¿Quedan casos de campaña?
    final nextCampaign = progressionService.getNextCampaignCase(staticSource.allCases);
    if (nextCampaign != null) {
      return nextCampaign;
    }

    // 2. Si no, generar uno procedimental.
    final config = difficultyPolicy.determineNextConfig(progressionService.progress);
    return generatedSource.generateNew(config, identityFactory);
  }

  /// Recupera un caso por su ID. Principalmente para Save & Resume.
  FutureOr<CaseData?> getCaseById(String id, {GeneratedCaseMetadata? metadata}) async {
    // Si tenemos metadata procedural explícita, delegamos a GeneratedCaseSource 
    // para su reconstrucción al vuelo (determinista).
    if (metadata != null) {
      return generatedSource.reconstructCase(id, metadata);
    }
    
    // De otra manera intentamos recuperarlo de fuentes estáticas.
    return (await staticSource.getCase(id)) ?? (await generatedSource.getCase(id));
  }
}
