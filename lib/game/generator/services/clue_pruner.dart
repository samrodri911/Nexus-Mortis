import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Poda el conjunto de pistas para reducirlo al mínimo necesario.
class CluePruner {
  const CluePruner(this._solver);

  final PuzzleSolver _solver;

  /// Poda pistas de forma iterativa garantizando que la solución siga siendo única.
  ({List<SpatialClueData> prunedClues, int solverCalls}) prune({
    required CaseData initialCase,
  }) {
    int solverCalls = 0;

    solverCalls++;
    if (_solver.solve(initialCase, maxSolutions: 2).solutionCount != 1) {
      return (prunedClues: initialCase.clues, solverCalls: solverCalls);
    }

    final currentClues = List<SpatialClueData>.from(initialCase.clues);
    bool anyRemoved = true;

    while (anyRemoved && currentClues.length > 1) {
      anyRemoved = false;

      for (int i = currentClues.length - 1; i >= 0; i--) {
        final clueToTest = currentClues[i];
        currentClues.removeAt(i);

        final testCase = CaseData(
          id: initialCase.id,
          title: initialCase.title,
          description: initialCase.description,
          difficulty: initialCase.difficulty,
          boardRows: initialCase.boardRows,
          boardColumns: initialCase.boardColumns,
          suspects: initialCase.suspects,
          placedObjects: initialCase.placedObjects,
          clues: currentClues,
          solution: initialCase.solution,
        );

        solverCalls++;
        final result = _solver.solve(testCase, maxSolutions: 2);

        if (result.solutionCount == 1) {
          anyRemoved = true; // Sigue siendo único sin esta pista
        } else {
          currentClues.insert(
            i,
            clueToTest,
          ); // La pista era necesaria, restaurar
        }
      }
    }

    return (prunedClues: currentClues, solverCalls: solverCalls);
  }
}
