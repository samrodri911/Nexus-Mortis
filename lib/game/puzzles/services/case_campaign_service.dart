import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:nexus_mortis/data/local/mappers/case_data_mapper.dart';
import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/repositories/campaign_case_repository.dart';
import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/services/case_identity_factory.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Define la política de configuración estructural y rango de dificultad objetivo
/// para un nivel específico de la campaña.
class LevelPolicy {
  const LevelPolicy({
    required this.rows,
    required this.cols,
    required this.suspects,
    required this.objects,
    required this.targetDifficulty,
    required this.minDifficultyScore,
    required this.maxDifficultyScore,
  });

  final int rows;
  final int cols;
  final int suspects;
  final int objects;
  final DifficultyLevel targetDifficulty;
  final int minDifficultyScore;
  final int maxDifficultyScore;
}

/// Servicio de gestión de la Campaña Continua de Nexus Mortis con progresión suave de dificultad.
class CaseCampaignService {
  CaseCampaignService({
    required this.campaignCaseRepository,
    this.staticSource = const StaticCaseSource(),
    PuzzleGenerator? puzzleGenerator,
    CaseIntegrityValidator? validator,
    DifficultyAnalyzer? analyzer,
    this.identityFactory = const CaseIdentityFactory(),
  })  : _puzzleGenerator = puzzleGenerator ?? PuzzleGenerator(),
        _validator = validator ?? CaseIntegrityValidator(),
        _analyzer = analyzer ?? DifficultyAnalyzer(PuzzleSolver());

  final CampaignCaseRepository campaignCaseRepository;
  final StaticCaseSource staticSource;
  final PuzzleGenerator _puzzleGenerator;
  final CaseIntegrityValidator _validator;
  final DifficultyAnalyzer _analyzer;
  final CaseIdentityFactory identityFactory;

  List<CaseData>? _cachedCases;

  /// Retorna la lista ordenada completa de todos los casos disponibles en la campaña.
  Future<List<CaseData>> getAvailableCases() async {
    if (_cachedCases != null) {
      return _cachedCases!;
    }

    final staticCases = staticSource.allCases;
    final entities = await campaignCaseRepository.getAllCases();

    final proceduralCases = <CaseData>[];
    for (final entity in entities) {
      final caseData = _reconstructFromEntity(entity);
      if (caseData != null) {
        proceduralCases.add(caseData);
      }
    }

    _cachedCases = [...staticCases, ...proceduralCases];
    return _cachedCases!;
  }

  /// Busca un caso por su identificador único (ej: 'case_001', 'case_004').
  Future<CaseData?> getCase(String id) async {
    final allCases = await getAvailableCases();
    for (final c in allCases) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Asegura que exista un lote inicial (mínimo 13 casos en total: 3 estáticos + 10 procedurales)
  /// o genera un nuevo lote de 10 casos si el jugador se aproxima al final de la lista.
  Future<void> ensureBatchAvailable(PlayerProgress progress) async {
    final cases = await getAvailableCases();

    // 1. Si no se ha generado el primer lote (total < 13), generarlo inmediatamente (04..13)
    if (cases.length < 13) {
      await _generateNextBatch(currentTotal: cases.length);
      return;
    }

    // 2. Proactividad de campaña: Si el jugador ha completado casos hasta quedar cerca del final
    // (o completó el último caso disponible), generamos 10 casos adicionales inmediatamente.
    final completedCount = cases.where((c) => progress.completedCases.containsKey(c.id)).length;
    final remainingUncompleted = cases.length - completedCount;
    if (remainingUncompleted < 4 || (cases.isNotEmpty && progress.completedCases.containsKey(cases.last.id))) {
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
      final isUnlocked = c.requiredCaseId == null ||
          progress.completedCases.containsKey(c.requiredCaseId) ||
          (i > 0 && progress.completedCases.containsKey(cases[i - 1].id));

      if (isUnlocked && !isCompleted) {
        return c;
      }
    }

    return null;
  }

  /// Calcula la política estructural y el rango de score objetivo para un índice de nivel.
  LevelPolicy _levelPolicy(int levelIndex) {
    // 1. Bloques de tamaño de cuadrícula (aproximadamente cada 10 niveles)
    final int rows;
    final int cols;
    final int suspects;
    final int objects;

    if (levelIndex <= 10) {
      rows = 4;
      cols = 4;
      suspects = 3;
      objects = 2;
    } else if (levelIndex <= 20) {
      rows = 5;
      cols = 5;
      suspects = 4;
      objects = 3;
    } else if (levelIndex <= 30) {
      rows = 5;
      cols = 5;
      suspects = levelIndex <= 25 ? 4 : 5;
      objects = 3;
    } else if (levelIndex <= 40) {
      rows = 6;
      cols = 5;
      suspects = 5;
      objects = levelIndex <= 35 ? 3 : 4;
    } else {
      rows = 6;
      cols = 6;
      suspects = levelIndex <= 60 ? 5 : 6;
      objects = 4;
    }

    // 2. Curva continua y progresiva de dificultad objetivo
    final double target = 22.0 + (levelIndex - 1) * 0.70;
    final int targetScore = target.round().clamp(20, 95);

    // Tolerancia controlada (±12 puntos de dificultad) para permitir variabilidad natural sin saltos bruscos
    final int minScore = (targetScore - 12).clamp(10, 95);
    final int maxScore = (targetScore + 12).clamp(20, 100);

    final DifficultyLevel diffLevel;
    if (targetScore <= 35) {
      diffLevel = DifficultyLevel.easy;
    } else if (targetScore <= 65) {
      diffLevel = DifficultyLevel.medium;
    } else {
      diffLevel = DifficultyLevel.hard;
    }

    return LevelPolicy(
      rows: rows,
      cols: cols,
      suspects: suspects,
      objects: objects,
      targetDifficulty: diffLevel,
      minDifficultyScore: minScore,
      maxDifficultyScore: maxScore,
    );
  }

  /// Genera y persiste un lote de exactamente 10 casos procedurales con dificultad progresiva.
  Future<void> _generateNextBatch({required int currentTotal}) async {
    final newEntities = <CampaignCaseEntity>[];
    final random = Random();

    int nextIndex = currentTotal + 1;
    String lastCaseId = currentTotal > 0 ? (await getAvailableCases()).last.id : 'case_003';

    for (int i = 0; i < 10; i++) {
      final caseIndex = nextIndex + i;
      final caseId = 'case_${caseIndex.toString().padLeft(3, '0')}';
      final seed = random.nextInt(9000000) + 1000000;

      final policy = _levelPolicy(caseIndex);

      CaseData? validCase;
      int winningSeed = seed;
      int winningScore = 0;

      for (int attempt = 0; attempt < 120; attempt++) {
        final currentSeed = seed + attempt * 17;
        final attemptConfig = GeneratorConfig(
          rows: policy.rows,
          columns: policy.cols,
          suspectCount: policy.suspects,
          objectCount: policy.objects,
          targetDifficulty: policy.targetDifficulty,
          minDifficultyScore: policy.minDifficultyScore,
          maxDifficultyScore: policy.maxDifficultyScore,
          randomSeed: currentSeed,
          maxAttempts: 3,
        );

        final result = _puzzleGenerator.generate(attemptConfig);
        if (result != null) {
          final candidate = CaseData(
            id: caseId,
            title: 'Expediente #${caseIndex.toString().padLeft(2, '0')}: ${result.caseData.title}',
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

          final valResult = _validator.validateDetailed(candidate);
          if (valResult.isValid) {
            final analysis = _analyzer.analyze(candidate);
            if (analysis.difficultyScore >= policy.minDifficultyScore &&
                analysis.difficultyScore <= policy.maxDifficultyScore) {
              validCase = candidate;
              winningSeed = currentSeed;
              winningScore = analysis.difficultyScore;
              break;
            }
          }
        }
      }

      // Si ningún caso cumplió el rango estricto tras 120 intentos, aceptar el mejor generado que sea válido
      if (validCase == null) {
        for (int fallbackAttempt = 0; fallbackAttempt < 30; fallbackAttempt++) {
          final fallbackSeed = seed + 5000 + fallbackAttempt * 19;
          final fallbackConfig = GeneratorConfig(
            rows: policy.rows,
            columns: policy.cols,
            suspectCount: policy.suspects,
            objectCount: policy.objects,
            randomSeed: fallbackSeed,
            maxAttempts: 3,
          );
          final result = _puzzleGenerator.generate(fallbackConfig);
          if (result != null) {
            final candidate = CaseData(
              id: caseId,
              title: 'Expediente #${caseIndex.toString().padLeft(2, '0')}: ${result.caseData.title}',
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
            if (_validator.validate(candidate)) {
              validCase = candidate;
              winningSeed = fallbackSeed;
              winningScore = _analyzer.analyze(candidate).difficultyScore;
              break;
            }
          }
        }
      }

      if (validCase != null) {
        final entity = CampaignCaseEntity()
          ..caseId = caseId
          ..caseIndex = caseIndex
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

        newEntities.add(entity);
        lastCaseId = caseId;
      }
    }

    if (newEntities.isNotEmpty) {
      await campaignCaseRepository.saveCases(newEntities);
      _cachedCases = null; // Invalidar caché
      await getAvailableCases(); // Recargar
    }
  }

  CaseData? _reconstructFromEntity(CampaignCaseEntity entity) {
    if (entity.caseJson != null && entity.caseJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(entity.caseJson!) as Map<String, dynamic>;
        return CaseDataMapper.fromJson(decoded);
      } catch (_) {
        // Fallback a reconstrucción por generador si el JSON estuviera corrupto
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
