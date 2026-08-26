import 'dart:math';

import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generation_result.dart';
import 'package:nexus_mortis/game/generator/models/generation_statistics.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/clue_generator.dart';
import 'package:nexus_mortis/game/generator/services/clue_pruner.dart';
import 'package:nexus_mortis/game/generator/services/difficulty_calibrator.dart';
import 'package:nexus_mortis/game/generator/services/object_placer.dart';
import 'package:nexus_mortis/game/generator/services/solution_generator.dart';
import 'package:nexus_mortis/game/generator/services/uniqueness_validator.dart';
import 'package:nexus_mortis/game/generator/services/zone_generator.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Orquestador principal que genera puzzles procedimentales.
class PuzzleGenerator {
  PuzzleGenerator({
    PuzzleSolver? solver,
    DifficultyAnalyzer? analyzer,
  }) {
    _solver = solver ?? PuzzleSolver();
    _analyzer = analyzer ?? DifficultyAnalyzer(_solver);
  }

  late final PuzzleSolver _solver;
  late final DifficultyAnalyzer _analyzer;

  GenerationResult? generate(GeneratorConfig config) {
    final stopwatch = Stopwatch()..start();
    
    if (config.suspectCount + config.objectCount > config.rows * config.columns) {
      return null;
    }
    // Need at least 2 suspects (1 victim, 1 killer)
    if (config.suspectCount < 2) return null;

    final rand = config.randomSeed != null ? Random(config.randomSeed) : Random();
    
    final objectPlacer = ObjectPlacer(rand);
    final solutionGenerator = SolutionGenerator(rand);
    final clueGenerator = ClueGenerator(rand);
    final uniquenessValidator = UniquenessValidator(_solver);
    final cluePruner = CluePruner(_solver);
    final difficultyCalibrator = DifficultyCalibrator(_analyzer);

    int solverCalls = 0;
    int visitedNodes = 0;

    for (int attempt = 0; attempt < config.maxAttempts; attempt++) {
      final caseIdPrefix = config.randomSeed != null 
          ? 'case_${config.randomSeed}_$attempt'
          : 'case_${DateTime.now().millisecondsSinceEpoch}_$attempt';

      final suspects = objectPlacer.selectSuspects(config.suspectCount);
      final objects = objectPlacer.selectObjects(config.objectCount);

      // Designate victim and killer randomly
      final shuffledSuspects = List.of(suspects)..shuffle(rand);
      final victimId = shuffledSuspects[0].id;
      final killerId = shuffledSuspects[1].id;

      // Target zones: roughly grid size / 3, min 2, max 5.
      final targetZones = (config.rows * config.columns / 4).clamp(2, 5).toInt();
      final zones = ZoneGenerator.generateZones(config.rows, config.columns, targetZones, rand);

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
        // Solution generation might fail if zones are drawn poorly making it impossible to satisfy Murdoku+Zone constraints.
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

      final allClues = clueGenerator.generateAllPossibleClues(
        solution: solution,
        objectPositions: objectPositions,
        clueIdPrefix: caseIdPrefix,
      );

      var tempCase = CaseData(
        id: caseIdPrefix,
        title: 'Caso Aleatorio',
        description: 'Un misterio generado procedimentalmente.',
        difficulty: _mapDifficulty(config.targetDifficulty ?? DifficultyLevel.medium),
        boardRows: config.rows,
        boardColumns: config.columns,
        zones: zones,
        suspects: suspects,
        victimId: victimId,
        killerId: killerId,
        placedObjects: placedObjects,
        clues: allClues,
        solution: solution,
      );

      final pruneResult = cluePruner.prune(initialCase: tempCase);
      solverCalls += pruneResult.solverCalls;
      
      final finalClues = pruneResult.prunedClues;

      if (config.minClues != null && finalClues.length < config.minClues!) continue;
      if (config.maxClues != null && finalClues.length > config.maxClues!) continue;

      tempCase = CaseData(
        id: tempCase.id,
        title: tempCase.title,
        description: tempCase.description,
        difficulty: tempCase.difficulty,
        boardRows: tempCase.boardRows,
        boardColumns: tempCase.boardColumns,
        zones: tempCase.zones,
        suspects: tempCase.suspects,
        victimId: tempCase.victimId,
        killerId: tempCase.killerId,
        placedObjects: tempCase.placedObjects,
        clues: finalClues,
        solution: tempCase.solution,
      );

      final nodes = uniquenessValidator.validate(tempCase);
      solverCalls++;
      if (nodes == -1) continue;
      visitedNodes += nodes;

      final analysis = difficultyCalibrator.calibrate(tempCase, config.targetDifficulty);
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
        solution: tempCase.solution,
      );

      stopwatch.stop();

      return GenerationResult(
        caseData: tempCase,
        analysis: analysis,
        statistics: GenerationStatistics(
          attemptsUsed: attempt + 1,
          solverCalls: solverCalls,
          visitedNodes: visitedNodes,
          generationDurationMs: stopwatch.elapsedMilliseconds,
          generatedClues: allClues.length,
          remainingClues: finalClues.length,
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
