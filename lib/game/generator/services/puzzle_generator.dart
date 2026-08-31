import 'dart:math';

import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generation_result.dart';
import 'package:nexus_mortis/game/generator/models/generation_statistics.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/deduction_chain_generator.dart';
import 'package:nexus_mortis/game/generator/services/difficulty_calibrator.dart';
import 'package:nexus_mortis/game/generator/services/mystery_generator.dart';
import 'package:nexus_mortis/game/generator/services/object_placer.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_quality_evaluator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/generator/services/solution_generator.dart';
import 'package:nexus_mortis/game/generator/services/uniqueness_validator.dart';
import 'package:nexus_mortis/game/generator/services/zone_generator.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Orquestador principal que genera puzzles procedimentales completos con narrativa y pistas.
class PuzzleGenerator {
  PuzzleGenerator({
    PuzzleSolver? solver,
    DifficultyAnalyzer? analyzer,
    this.mysteryGenerator = const MysteryGenerator(),
  }) {
    _solver = solver ?? PuzzleSolver();
    _analyzer = analyzer ?? DifficultyAnalyzer(_solver);
  }

  late final PuzzleSolver _solver;
  late final DifficultyAnalyzer _analyzer;
  final MysteryGenerator mysteryGenerator;

  GenerationResult? generate(GeneratorConfig config) {
    final stopwatch = Stopwatch()..start();

    if (config.suspectCount + config.objectCount > config.rows * config.columns) {
      return null;
    }
    if (config.suspectCount < 2) return null;

    final rand = config.randomSeed != null ? Random(config.randomSeed) : Random();

    final objectPlacer = ObjectPlacer(rand);
    final solutionGenerator = SolutionGenerator(rand);
    const deductionChainGenerator = DeductionChainGenerator();
    final uniquenessValidator = UniquenessValidator(_solver);
    final difficultyCalibrator = DifficultyCalibrator(_analyzer);
    const simulator = PuzzleSimulator();
    const evaluator = PuzzleQualityEvaluator(simulator);

    int solverCalls = 0;
    int visitedNodes = 0;

    for (int attempt = 0; attempt < config.maxAttempts; attempt++) {
      final caseIdPrefix = config.randomSeed != null
          ? 'case_${config.randomSeed}_$attempt'
          : 'case_${DateTime.now().millisecondsSinceEpoch}_$attempt';

      final nonVictimCount = max(1, config.suspectCount - 1);
      final selectedSuspects = objectPlacer.selectSuspects(nonVictimCount);
      const victim = SuspectData(id: 'victim', name: 'Víctima');
      final suspects = [...selectedSuspects, victim];
      final objects = objectPlacer.selectObjects(config.objectCount);

      const victimId = 'victim';
      final killerCandidates = selectedSuspects.map((s) => s.id).toList()..shuffle(rand);
      final killerId = killerCandidates.first;

      // Zonas
      final targetZones = (config.rows * config.columns / 4).clamp(2, 5).toInt();
      final rawZones = ZoneGenerator.generateZones(config.rows, config.columns, targetZones, rand);

      // Generar contexto y nombres temáticos
      final mystery = mysteryGenerator.generate(
        config.randomSeed ?? (attempt * 31 + 7),
        rawZones.length,
      );

      final zones = <ZoneData>[];
      for (int zIdx = 0; zIdx < rawZones.length; zIdx++) {
        final rz = rawZones[zIdx];
        final name = zIdx < mystery.zoneNames.length ? mystery.zoneNames[zIdx] : rz.name;
        zones.add(ZoneData(id: rz.id, name: name, cells: rz.cells));
      }

      late final ({dynamic solution, dynamic objectPositions}) solutionResult;
      try {
        solutionResult = solutionGenerator.generateSolution(
          rows: config.rows,
          columns: config.columns,
          suspects: suspects,
          objects: objects,
          zones: zones,
          victimId: victimId,
          killerId: killerId,
        );
      } catch (_) {
        continue;
      }

      final solution = solutionResult.solution;
      final objectPositions = solutionResult.objectPositions;

      final placedObjects = objects.map((obj) {
        return PlacedObjectData(
          object: obj,
          position: objectPositions[obj.id]!,
        );
      }).toList();

      var tempCase = CaseData(
        id: caseIdPrefix,
        title: mystery.title,
        description: mystery.description,
        difficulty: _mapDifficulty(config.targetDifficulty ?? DifficultyLevel.medium),
        boardRows: config.rows,
        boardColumns: config.columns,
        zones: zones,
        suspects: suspects,
        victimId: victimId,
        killerId: killerId,
        placedObjects: placedObjects,
        clues: const [],
        globalRules: const [],
        solution: solution,
      );

      // =======================================================================
      // CONSTRUCCIÓN DE CADENA DEDUCTIVA HUMANA (1 PERSONAJE = 1 TARJETA)
      // =======================================================================
      final chainResult = deductionChainGenerator.generateChain(tempCase, random: rand);
      if (chainResult == null) {
        continue;
      }

      tempCase = tempCase.copyWith(
        clues: chainResult.clues,
        globalRules: chainResult.globalRules,
      );

      // Validar calidad deductiva y cero grados de libertad
      if (!evaluator.isAcceptable(tempCase, chainResult.clues)) {
        continue;
      }

      // Validar unicidad matemática con el solver
      final nodes = uniquenessValidator.validate(tempCase);
      solverCalls++;
      if (nodes == -1) continue;
      visitedNodes += nodes;

      final analysis = difficultyCalibrator.calibrate(
        tempCase,
        config.targetDifficulty,
        minScore: config.minDifficultyScore,
        maxScore: config.maxDifficultyScore,
      );
      if (analysis == null) continue;

      tempCase = CaseData(
        id: tempCase.id,
        title: tempCase.title,
        description: tempCase.description,
        difficulty: _mapDifficulty(analysis.level),
        boardRows: tempCase.boardRows,
        boardColumns: tempCase.boardColumns,
        zones: tempCase.zones,
        suspects: tempCase.suspects,
        victimId: tempCase.victimId,
        killerId: tempCase.killerId,
        placedObjects: tempCase.placedObjects,
        clues: tempCase.clues,
        globalRules: tempCase.globalRules,
        solution: tempCase.solution,
      );

      stopwatch.stop();

      return GenerationResult(
        caseData: tempCase,
        analysis: analysis,
        statistics: GenerationStatistics(
          attemptsUsed: attempt + 1,
          generationDurationMs: stopwatch.elapsedMilliseconds,
          solverCalls: solverCalls,
          visitedNodes: visitedNodes,
          generatedClues: tempCase.clues.length,
          remainingClues: tempCase.clues.length,
        ),
      );
    }

    return null;
  }

  PuzzleDifficulty _mapDifficulty(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.trivial:
      case DifficultyLevel.easy:
        return PuzzleDifficulty.easy;
      case DifficultyLevel.medium:
        return PuzzleDifficulty.medium;
      case DifficultyLevel.hard:
      case DifficultyLevel.expert:
        return PuzzleDifficulty.hard;
    }
  }
}
