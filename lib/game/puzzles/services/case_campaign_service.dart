import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:nexus_mortis/data/local/mappers/case_data_mapper.dart';
import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/repositories/campaign_case_repository.dart';
import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/level_policy.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/services/case_identity_factory.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Registro de diagnóstico detallado para un intento fallido de generación.
class GenerationRejectionDiagnostic {
  const GenerationRejectionDiagnostic({
    required this.attempt,
    required this.seed,
    required this.reason,
    this.details,
  });

  final int attempt;
  final int seed;
  final String reason;
  final String? details;

  @override
  String toString() => 'Intento $attempt (seed: $seed): $reason ${details != null ? "[$details]" : ""}';
}

/// Servicio de gestión de la Campaña Continua de Nexus Mortis 100% procedural.
///
/// La campaña no utiliza ningún caso estático o demo; todos los niveles (0..N)
/// son generados proceduralmente, validados bajo doble verificación (Solver + HumanReplay),
/// calibrados según su [LevelPolicy] y persistidos en el repositorio local.
class CaseCampaignService {
  CaseCampaignService({
    required this.campaignCaseRepository,
    PuzzleGenerator? puzzleGenerator,
    CaseIntegrityValidator? validator,
    DifficultyAnalyzer? analyzer,
    HumanDeductionReplay? replay,
    this.identityFactory = const CaseIdentityFactory(),
  })  : _puzzleGenerator = puzzleGenerator ?? PuzzleGenerator(),
        _validator = validator ?? CaseIntegrityValidator(),
        _analyzer = analyzer ?? DifficultyAnalyzer(PuzzleSolver()),
        _replay = replay ?? const HumanDeductionReplay();

  final CampaignCaseRepository campaignCaseRepository;
  final PuzzleGenerator _puzzleGenerator;
  final CaseIntegrityValidator _validator;
  final DifficultyAnalyzer _analyzer;
  final HumanDeductionReplay _replay;
  final CaseIdentityFactory identityFactory;

  List<CaseData>? _cachedCases;

  /// Retorna la lista ordenada completa de todos los casos generados y persistidos en la campaña.
  Future<List<CaseData>> getAvailableCases() async {
    if (_cachedCases != null) {
      return _cachedCases!;
    }

    final entities = await campaignCaseRepository.getAllCases();

    // Detección automática y saneamiento de datos legacy (cuando la persistencia previa empezaba en case_004 o carecía de reglas globales en algún caso)
    final hasLegacyOrMissingRules = entities.isNotEmpty &&
        (!entities.any((e) => e.caseId == 'case_001') ||
            entities.first.caseIndex != 0 ||
            !entities.every((e) => e.caseJson != null && e.caseJson!.contains('"globalRules":[{')));

    if (hasLegacyOrMissingRules) {
      await campaignCaseRepository.clear();
      _cachedCases = null;
      await _generateNextBatch(currentTotal: 0);
      return _cachedCases!;
    }

    final proceduralCases = <CaseData>[];
    for (final entity in entities) {
      final caseData = _reconstructFromEntity(entity);
      if (caseData != null) {
        proceduralCases.add(caseData);
      }
    }

    _cachedCases = proceduralCases;
    return _cachedCases!;
  }

  /// Busca un caso por su identificador único (ej: 'case_001', 'case_010').
  Future<CaseData?> getCase(String id) async {
    final allCases = await getAvailableCases();
    for (final c in allCases) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Asegura que exista un lote inicial de al menos 10 casos procedurales (Niveles 0..9)
  /// o genera un nuevo lote de 10 niveles si el jugador se aproxima al final de la lista.
  Future<void> ensureBatchAvailable(PlayerProgress progress) async {
    final cases = await getAvailableCases();

    // 1. Si no se ha generado el primer lote (0 casos), generarlo inmediatamente (0..9)
    if (cases.isEmpty) {
      await _generateNextBatch(currentTotal: 0);
      return;
    }

    // 2. Proactividad de campaña: Si quedan menos de 4 casos sin completar o se completó el último
    final completedCount = cases.where((c) => progress.completedCases.containsKey(c.id)).length;
    final remainingUncompleted = cases.length - completedCount;
    if (remainingUncompleted < 4 || progress.completedCases.containsKey(cases.last.id)) {
      await _generateNextBatch(currentTotal: cases.length);
    }
  }

  /// Devuelve el próximo caso a jugar (el primer caso desbloqueado y no completado).
  Future<CaseData?> getNextCase(PlayerProgress progress) async {
    await ensureBatchAvailable(progress);
    final cases = await getAvailableCases();

    for (int i = 0; i < cases.length; i++) {
      final c = cases[i];
      final isCompleted = progress.completedCases.containsKey(c.id);
      final isUnlocked = i == 0 ||
          c.requiredCaseId == null ||
          progress.completedCases.containsKey(c.requiredCaseId) ||
          (i > 0 && progress.completedCases.containsKey(cases[i - 1].id));

      if (isUnlocked && !isCompleted) {
        return c;
      }
    }

    return null;
  }

  /// Genera y persiste un lote de 10 casos procedurales de forma independiente y transaccional.
  Future<void> _generateNextBatch({required int currentTotal}) async {
    final random = Random();
    int? lastScore;

    if (currentTotal > 0) {
      final existing = await getAvailableCases();
      if (existing.isNotEmpty) {
        final lastCase = existing.last;
        final lastSim = _replay.simulate(lastCase, lastCase.clues);
        lastScore = _analyzer.calculateScore(lastCase, simResult: lastSim);
      }
    }

    String? lastCaseId = currentTotal > 0 ? (await getAvailableCases()).last.id : null;

    for (int i = 0; i < 10; i++) {
      final levelIndex = currentTotal + i;
      final caseNumber = levelIndex + 1;
      final caseId = 'case_${caseNumber.toString().padLeft(3, '0')}';
      final baseSeed = random.nextInt(9000000) + 1000000;

      final policy = LevelPolicy.forLevel(levelIndex);
      final diagnostics = <GenerationRejectionDiagnostic>[];

      CaseData? validCase;
      int winningSeed = baseSeed;
      int winningScore = 0;

      for (int attempt = 0; attempt < 150; attempt++) {
        final currentSeed = baseSeed + attempt * 17;
        final attemptConfig = GeneratorConfig(
          rows: policy.rows,
          columns: policy.columns,
          suspectCount: policy.suspectCount,
          objectCount: policy.objectCount,
          targetDifficulty: policy.targetDifficulty,
          minDifficultyScore: policy.minDifficultyScore,
          maxDifficultyScore: policy.maxDifficultyScore,
          randomSeed: currentSeed,
          maxAttempts: 10,
        );

        final result = _puzzleGenerator.generate(attemptConfig);
        if (result == null) {
          diagnostics.add(GenerationRejectionDiagnostic(
            attempt: attempt + 1,
            seed: currentSeed,
            reason: 'puzzle_generator_null_result',
          ));
          continue;
        }

        final candidate = CaseData(
          id: caseId,
          title: 'Expediente #${caseNumber.toString().padLeft(2, '0')}: ${result.caseData.title}',
          description: result.caseData.description,
          difficulty: result.caseData.difficulty,
          boardRows: result.caseData.boardRows,
          boardColumns: result.caseData.boardColumns,
          zones: result.caseData.zones,
          suspects: result.caseData.suspects,
          victimId: result.caseData.victimId,
          killerId: result.caseData.killerId,
          placedObjects: result.caseData.placedObjects,
          clues: result.caseData.clues,
          globalRules: result.caseData.globalRules,
          solution: result.caseData.solution,
          requiredCaseId: lastCaseId,
          origin: CaseOrigin.campaign,
        );

        // 1. Regla obligatoria de campaña: Cada caso generado debe tener exactamente 1 regla global activa
        if (candidate.globalRules.length != 1) {
          diagnostics.add(GenerationRejectionDiagnostic(
            attempt: attempt + 1,
            seed: currentSeed,
            reason: 'campaign_case_requires_exact_one_global_rule',
          ));
          continue;
        }

        // 2. Doble Validación de Integridad (Solver + HumanReplay == GroundTruth)
        final valResult = _validator.validateDetailed(candidate);
        if (!valResult.isValid) {
          diagnostics.add(GenerationRejectionDiagnostic(
            attempt: attempt + 1,
            seed: currentSeed,
            reason: 'integrity_validator_rejected: ${valResult.rejectionReason?.name}',
            details: valResult.details,
          ));
          continue;
        }

        // 2. Simulación Humana para cálculo de Dificultad Deductiva Real
        final simResult = _replay.simulate(candidate, candidate.clues);
        final score = _analyzer.calculateScore(candidate, simResult: simResult);

        // 3. Verificación de Rango de Política
        if (score < policy.minDifficultyScore || score > policy.maxDifficultyScore) {
          diagnostics.add(GenerationRejectionDiagnostic(
            attempt: attempt + 1,
            seed: currentSeed,
            reason: 'difficulty_score_out_of_range',
            details: 'score: $score, expected: [${policy.minDifficultyScore}..${policy.maxDifficultyScore}]',
          ));
          continue;
        }

        // 4. Verificación de Continuidad con el Nivel Anterior (evitar picos)
        if (lastScore != null && (score - lastScore).abs() > policy.maxDeltaFromPrevious) {
          diagnostics.add(GenerationRejectionDiagnostic(
            attempt: attempt + 1,
            seed: currentSeed,
            reason: 'progression_jump_too_large',
            details: 'delta: ${(score - lastScore).abs()}, maxAllowed: ${policy.maxDeltaFromPrevious}',
          ));
          continue;
        }

        // ¡Caso 100% Válido y Calibrado!
        validCase = candidate;
        winningSeed = currentSeed;
        winningScore = score;
        break;
      }

      if (validCase == null) {
        throw StateError(
          'Error crítico de generación en Nivel $levelIndex ($caseId): '
          'No se pudo generar un caso válido tras 150 intentos.\n'
          'Política: ${policy.rows}x${policy.columns}, ${policy.suspectCount} sospechosos, '
          'score objetivo: ${policy.targetDifficultyScore} (tolerancia: ±${policy.scoreTolerance}).\n'
          'Últimos diagnósticos:\n${diagnostics.reversed.take(5).join("\n")}',
        );
      }

      // Persistir de forma transaccional independiente cada nivel
      final entity = CampaignCaseEntity()
        ..caseId = caseId
        ..caseIndex = levelIndex
        ..title = validCase.title
        ..description = validCase.description
        ..difficulty = validCase.difficulty.name
        ..difficultyScore = winningScore
        ..seed = winningSeed
        ..rows = validCase.boardRows
        ..columns = validCase.boardColumns
        ..suspects = validCase.suspects.length
        ..objects = validCase.placedObjects.length
        ..caseJson = jsonEncode(CaseDataMapper.toJson(validCase))
        ..requiredCaseId = lastCaseId;

      await campaignCaseRepository.saveCases([entity]);
      lastCaseId = caseId;
      lastScore = winningScore;
    }

    _cachedCases = null; // Invalidar caché
    await getAvailableCases(); // Recargar casos actualizados
  }

  CaseData? _reconstructFromEntity(CampaignCaseEntity entity) {
    if (entity.caseJson != null && entity.caseJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(entity.caseJson!) as Map<String, dynamic>;
        return CaseDataMapper.fromJson(decoded);
      } catch (_) {
        // Fallback a reconstrucción por generador determinista si el JSON estuviera corrupto
      }
    }

    final config = GeneratorConfig(
      rows: entity.rows,
      columns: entity.columns,
      suspectCount: entity.suspects,
      objectCount: entity.objects,
      randomSeed: entity.seed,
    );

    final result = _puzzleGenerator.generate(config);
    if (result == null) return null;

    final puzzleDiff = PuzzleDifficulty.values.firstWhere(
      (e) => e.name == entity.difficulty,
      orElse: () => PuzzleDifficulty.medium,
    );

    return CaseData(
      id: entity.caseId,
      title: entity.title,
      description: entity.description,
      difficulty: puzzleDiff,
      boardRows: result.caseData.boardRows,
      boardColumns: result.caseData.boardColumns,
      zones: result.caseData.zones,
      suspects: result.caseData.suspects,
      victimId: result.caseData.victimId,
      killerId: result.caseData.killerId,
      placedObjects: result.caseData.placedObjects,
      clues: result.caseData.clues,
      globalRules: result.caseData.globalRules,
      solution: result.caseData.solution,
      requiredCaseId: entity.requiredCaseId,
      origin: CaseOrigin.campaign,
    );
  }
}
