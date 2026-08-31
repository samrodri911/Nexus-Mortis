import 'dart:math';

import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';

/// Selecciona y optimiza el conjunto de pistas utilizando simulación humana.
class ClueOptimizer {
  const ClueOptimizer(this._solver, [this._random]);

  final PuzzleSolver _solver;
  final Random? _random;

  ({List<SpatialClueData> optimizedClues, int solverCalls}) optimize({
    required CaseData initialCase,
  }) {
    int solverCalls = 0;

    // Primero, garantizar que el banco completo sí permite resolver (sanity check).
    solverCalls++;
    if (_solver.solve(initialCase, maxSolutions: 2).solutionCount != 1) {
      return (optimizedClues: initialCase.clues, solverCalls: solverCalls);
    }

    final simulator = const PuzzleSimulator();
    final rand = _random ?? Random();

    // Clasificamos pistas para dar prioridad a anclajes (zonas, adyacencias y cardinales inmediatas)
    final clues = List<SpatialClueData>.from(initialCase.clues)..shuffle(rand);
    clues.sort((a, b) => _scoreClueType(b).compareTo(_scoreClueType(a)));

    final currentClues = List<SpatialClueData>.from(clues);

    // Poda codiciosa con doble verificación: Unicidad técnica Y Solvabilidad humana con cero grados de libertad
    for (int i = currentClues.length - 1; i >= 0; i--) {
      final candidateClue = currentClues[i];
      currentClues.removeAt(i);

      final testCase = initialCase.copyWith(clues: currentClues);

      // Verificación rápida con el simulador humano primero
      final simResult = simulator.simulate(testCase, currentClues);
      if (!simResult.solved ||
          simResult.stuck ||
          simResult.requiresGuessing ||
          !simResult.killerDeductionUnique ||
          simResult.domainSizes.values.any((v) => v != 1)) {
        // Sin esta pista, el humano se atasca o queda con entidades ambiguas (>1 candidato)
        currentClues.insert(i, candidateClue);
        continue;
      }

      // Verificación de unicidad matemática global
      solverCalls++;
      final result = _solver.solve(testCase, maxSolutions: 2);
      if (result.solutionCount != 1) {
        // Era indispensable para la unicidad técnica
        currentClues.insert(i, candidateClue);
      }
    }

    return (optimizedClues: currentClues, solverCalls: solverCalls);
  }

  int _scoreClueType(SpatialClueData c) {
    if (c.type == ClueType.zone) return 50;
    if (c.type == ClueType.adjacency) return 40;

    if (c.type == ClueType.cardinal) {
      if (c.relation == SpatialRelation.immediatelyNorthOf ||
          c.relation == SpatialRelation.immediatelySouthOf ||
          c.relation == SpatialRelation.immediatelyEastOf ||
          c.relation == SpatialRelation.immediatelyWestOf) {
        return 35; // Fuertes anclajes direccionales
      }
      return 10; // Débiles (al norte de...)
    }
    return 20; // coLocation
  }
}
