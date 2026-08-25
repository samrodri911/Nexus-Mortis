import 'dart:async';

import 'package:nexus_mortis/game/generator/models/generation_result.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/case_source.dart';
import 'package:nexus_mortis/game/puzzles/models/generated_case_metadata.dart';
import 'package:nexus_mortis/game/puzzles/services/case_identity_factory.dart';

/// Fuente de casos generados procedimentalmente.
/// Aísla la complejidad del PuzzleGenerator del resto del motor.
class GeneratedCaseSource implements CaseSource {
  GeneratedCaseSource({
    PuzzleGenerator? puzzleGenerator,
  }) : _puzzleGenerator = puzzleGenerator ?? PuzzleGenerator();

  final PuzzleGenerator _puzzleGenerator;

  /// Genera un nuevo caso al vuelo.
  CaseData generateNew(GeneratorConfig config, CaseIdentityFactory identityFactory) {
    final baseSeed = config.randomSeed ?? DateTime.now().millisecondsSinceEpoch;
    int currentSeed = baseSeed;
    GenerationResult? result;

    // Intentar generar con la semilla provista o iterar semillas consecutivas si fue aleatoria
    for (int attempt = 0; attempt < 5; attempt++) {
      final attemptConfig = GeneratorConfig(
        rows: config.rows,
        columns: config.columns,
        suspectCount: config.suspectCount,
        objectCount: config.objectCount,
        targetDifficulty: config.targetDifficulty,
        minClues: config.minClues,
        maxClues: config.maxClues,
        maxAttempts: config.maxAttempts,
        randomSeed: currentSeed,
      );

      result = _puzzleGenerator.generate(attemptConfig);
      if (result != null) break;
      if (config.randomSeed != null) break; // Si se especificó una semilla fija, no cambiarla
      currentSeed++;
    }

    if (result == null) {
      throw StateError('No se pudo generar un puzzle con la configuración provista.');
    }

    final id = identityFactory.createProceduralId(currentSeed);
    return _copyWithIdentity(result.caseData, id, CaseOrigin.procedural);
  }

  /// Reconstruye un caso procedimental de manera determinista utilizando su metadata.
  FutureOr<CaseData?> reconstructCase(String id, GeneratedCaseMetadata metadata) {
    final config = GeneratorConfig(
      rows: metadata.rows,
      columns: metadata.columns,
      suspectCount: metadata.suspects,
      objectCount: metadata.objects,
      targetDifficulty: metadata.difficulty,
      randomSeed: metadata.seed,
    );

    final result = _puzzleGenerator.generate(config);
    if (result == null) return null;

    return _copyWithIdentity(result.caseData, id, CaseOrigin.procedural);
  }

  @override
  FutureOr<CaseData?> getCase(String id) {
    // La fuente generada requiere metadata explícita para reconstruir.
    // Esta implementación base sin metadata retorna nulo.
    return null;
  }

  CaseData _copyWithIdentity(CaseData data, String newId, CaseOrigin origin) {
    return CaseData(
      id: newId,
      title: data.title,
      description: data.description,
      difficulty: data.difficulty,
      boardRows: data.boardRows,
      boardColumns: data.boardColumns,
      suspects: data.suspects,
      placedObjects: data.placedObjects,
      clues: data.clues,
      solution: data.solution,
      requiredCaseId: data.requiredCaseId,
      origin: origin,
    );
  }
}
