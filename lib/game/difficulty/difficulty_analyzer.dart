import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_analysis.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Analiza un [CaseData] y determina su puntuación continua y nivel de dificultad objetivo.
class DifficultyAnalyzer {
  const DifficultyAnalyzer(this.solver);

  final PuzzleSolver solver;

  /// Ejecuta el análisis sobre [caseData], calculando su [difficultyScore] continuo (0..100)
  /// y derivando el [DifficultyLevel] correspondiente.
  DifficultyAnalysis analyze(CaseData caseData, {HumanDeductionReplayResult? simResult}) {
    final result = solver.solve(caseData, maxSolutions: 2);

    if (result.isImpossible) {
      throw StateError('El puzzle es imposible (0 soluciones).');
    }

    if (result.isAmbiguous) {
      throw StateError('El puzzle es ambiguo (>1 soluciones).');
    }

    final score = calculateScore(caseData, simResult: simResult);
    final level = _calculateLevelFromScore(score);

    return DifficultyAnalysis(
      level: level,
      difficultyScore: score,
      visitedNodes: result.visitedNodes,
      solutionCount: result.solutionCount,
      clueCount: caseData.clues.length,
      suspectCount: caseData.suspects.length,
    );
  }

  /// Calcula una puntuación continua de dificultad (15..100) donde la
  /// **complejidad deductiva real (HumanDeductionReplay)** tiene un peso predominante (~70-75%)
  /// sobre la complejidad estructural del tablero (~25-30%).
  int calculateScore(CaseData caseData, {HumanDeductionReplayResult? simResult}) {
    // 1. Complejidad Estructural (~25% del peso total, max ~27 puntos)
    final totalCells = caseData.boardRows * caseData.boardColumns;
    final boardScore = ((totalCells - 16) * 0.4).clamp(0.0, 8.0);
    final suspectScore = ((caseData.suspects.length - 3) * 2.5).clamp(0.0, 10.0);
    final objectScore = ((caseData.placedObjects.length - 2) * 1.5).clamp(0.0, 5.0);
    final zoneScore = ((caseData.zones.length - 2) * 1.0).clamp(0.0, 4.0);
    final structuralScore = boardScore + suspectScore + objectScore + zoneScore;

    // 2. Complejidad Deductiva Humana (~75% del peso total, max ~70 puntos)
    // a. Pasos en la cadena deductiva y profundidad de replay
    final steps = simResult?.steps ?? (caseData.suspects.length);
    final stepScore = ((steps - 1) * 3.5).clamp(0.0, 20.0);

    // b. Complejidad intrínseca de pistas y operadores espaciales
    double clueScore = 0;
    for (final clue in caseData.clues) {
      for (final constraint in clue.activeConstraints) {
        switch (constraint.relation) {
          case SpatialRelation.immediatelyNorthOf:
          case SpatialRelation.immediatelySouthOf:
          case SpatialRelation.immediatelyEastOf:
          case SpatialRelation.immediatelyWestOf:
            clueScore += 1.0;
            break;
          case SpatialRelation.inZone:
            clueScore += 1.5;
            break;
          case SpatialRelation.sameRow:
          case SpatialRelation.sameColumn:
            clueScore += 2.0;
            break;
          case SpatialRelation.adjacentTo:
            clueScore += 2.8;
            break;
          case SpatialRelation.above:
          case SpatialRelation.below:
          case SpatialRelation.leftOf:
          case SpatialRelation.rightOf:
            clueScore += 3.2;
            break;
          case SpatialRelation.notAdjacentTo:
          case SpatialRelation.differentRow:
          case SpatialRelation.differentColumn:
          case SpatialRelation.notInZone:
            clueScore += 4.0;
            break;
        }

        // Bono por dependencia deductiva (DAG) de otro sospechoso
        if (caseData.suspects.any((s) => s.id == constraint.targetId && s.id != caseData.victimId)) {
          clueScore += 2.0;
        }
      }
    }
    final normalizedClueScore = clueScore.clamp(0.0, 25.0);

    // c. Dificultad de clausura y meta-reglas globales
    double victimClosureScore = 0;
    if (simResult != null && simResult.victimSolvedByExhaustion) {
      victimClosureScore += 4.0;
    }

    double globalRuleScore = 0;
    if (simResult != null) {
      final globalSteps = simResult.trace.where((s) => s.sourceType == DeductionSourceType.globalRule).toList();
      for (final gStep in globalSteps) {
        // Reducción fina hacia 1 candidato tras cadena de deducciones
        if (gStep.candidateCountBefore <= 3 && gStep.candidateCountAfter == 1) {
          globalRuleScore += 3.5;
        } else if (gStep.candidateCountAfter == 1) {
          globalRuleScore += 2.5;
        } else {
          globalRuleScore += 1.5;
        }
        // Bono por profundidad en la cadena
        if (gStep.stepNumber > 4) {
          globalRuleScore += 1.0;
        }
      }
    } else if (caseData.globalRules.isNotEmpty) {
      globalRuleScore += caseData.globalRules.length * 3.0;
    }
    final normalizedGlobalScore = globalRuleScore.clamp(0.0, 8.0);

    // d. Esfuerzo de reducción de dominios (evaluando la traza real del Replay)
    double domainReductionEffort = 0;
    if (simResult != null) {
      for (final step in simResult.trace) {
        if (step.reductionAmount >= 3) {
          domainReductionEffort += 1.5;
        } else if (step.reductionAmount >= 2) {
          domainReductionEffort += 1.0;
        } else if (step.reductionRatio >= 0.5) {
          domainReductionEffort += 0.8;
        }
      }
    }
    final normalizedDomainScore = domainReductionEffort.clamp(0.0, 10.0);

    final baseScore = 5.0;
    final deductiveScore = stepScore + normalizedClueScore + victimClosureScore + normalizedGlobalScore + normalizedDomainScore;

    final totalScore = baseScore + structuralScore + deductiveScore;
    return totalScore.round().clamp(15, 100);
  }

  DifficultyLevel _calculateLevelFromScore(int score) {
    if (score <= 32) {
      return DifficultyLevel.easy;
    } else if (score <= 58) {
      return DifficultyLevel.medium;
    } else {
      return DifficultyLevel.hard;
    }
  }
}
