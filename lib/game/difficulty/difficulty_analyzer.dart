import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_analysis.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Analiza un [CaseData] y determina su puntuación continua y nivel de dificultad objetivo.
class DifficultyAnalyzer {
  const DifficultyAnalyzer(this.solver);

  final PuzzleSolver solver;

  /// Ejecuta el análisis sobre [caseData], calculando su [difficultyScore] continuo (0..100)
  /// y derivando el [DifficultyLevel] correspondiente.
  DifficultyAnalysis analyze(CaseData caseData, {PuzzleSimulationResult? simResult}) {
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

  /// Calcula una puntuación continua de dificultad (10..100) basada en la complejidad
  /// estructural, relacional, deductiva y de clausura del caso.
  int calculateScore(CaseData caseData, {PuzzleSimulationResult? simResult}) {
    // 1. Complejidad del tablero (0 a 20)
    final totalCells = caseData.boardRows * caseData.boardColumns;
    final boardScore = ((totalCells - 16) * 1.0).clamp(0.0, 20.0);

    // 2. Cantidad de sospechosos (0 a 20)
    final suspectScore = ((caseData.suspects.length - 3) * 5.0).clamp(0.0, 20.0);

    // 3. Cantidad de objetos fijos (0 a 10)
    final objectScore = ((caseData.placedObjects.length - 2) * 3.0).clamp(0.0, 10.0);

    // 4. Complejidad de pistas y restricciones (0 a 25)
    double clueScore = 0;
    for (final clue in caseData.clues) {
      for (final constraint in clue.activeConstraints) {
        switch (constraint.relation) {
          case SpatialRelation.immediatelyNorthOf:
          case SpatialRelation.immediatelySouthOf:
          case SpatialRelation.immediatelyEastOf:
          case SpatialRelation.immediatelyWestOf:
            clueScore += 1.2;
            break;
          case SpatialRelation.inZone:
            clueScore += 1.8;
            break;
          case SpatialRelation.sameRow:
          case SpatialRelation.sameColumn:
            clueScore += 2.2;
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
            clueScore += 3.8;
            break;
        }
        // Bono por dependencia DAG de otro sospechoso
        if (caseData.suspects.any((s) => s.id == constraint.targetId && s.id != caseData.victimId)) {
          clueScore += 1.5;
        }
      }
    }
    final normalizedClueScore = clueScore.clamp(0.0, 25.0);

    // 5. Pasos deductivos requeridos (0 a 15)
    final steps = simResult?.steps ?? caseData.suspects.length;
    final stepScore = ((steps - 2) * 2.2).clamp(0.0, 15.0);

    // 6. Bono por necesidad de regla global (0 o 10)
    final globalRuleScore = caseData.globalRules.isNotEmpty ? 10.0 : 0.0;

    final totalScore = 12.0 + boardScore + suspectScore + objectScore + normalizedClueScore + stepScore + globalRuleScore;
    return totalScore.round().clamp(10, 100);
  }

  DifficultyLevel _calculateLevelFromScore(int score) {
    if (score <= 32) {
      return DifficultyLevel.easy;
    } else if (score <= 60) {
      return DifficultyLevel.medium;
    } else {
      return DifficultyLevel.hard;
    }
  }
}
