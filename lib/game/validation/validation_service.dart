import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/player/models/player_assignment.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/validation/models/validation_result.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Servicio responsable de validar el estado del tablero del jugador
/// cruzando sus asignaciones con las pistas y la solución oculta.
class ValidationService {
  const ValidationService({
    required this.solution,
    required this.clues,
    required this.objectPositions,
    required this.clueEvaluator,
  });

  /// Solución definitiva oculta del puzzle.
  final SolutionData solution;

  /// Lista de pistas para evaluar el progreso en tiempo real.
  final List<SpatialClueData> clues;

  /// Mapa de objetos fijos (ID -> Posición).
  final Map<String, CellPosition> objectPositions;

  /// Evaluador de pistas.
  final ClueEvaluator clueEvaluator;

  /// Valida el estado completo del tablero sin mutar datos.
  ValidationResult validate(PlayerBoardState playerState) {
    // 1. Extraer posiciones activas (solo aquellos sospechosos con exactamente 1 candidato)
    final Map<String, CellPosition> activeAssignments = {};
    bool hasIncompleteAssignments = false;
    bool hasIncorrectPlacements = false;

    // Evaluamos también contra la solución, pero esto solo
    // se usará para dictaminar el estado 'solved' o 'invalid'.
    for (final PlayerAssignment assignment in playerState.assignments) {
      if (assignment.candidates.length != 1) {
        hasIncompleteAssignments = true;
      } else {
        final pos = assignment.candidates.first;
        activeAssignments[assignment.suspectId] = pos;

        if (solution.suspectPositions[assignment.suspectId] != pos) {
          hasIncorrectPlacements = true;
        }
      }
    }

    // 2. Evaluar pistas usando solo las posiciones activas
    int satisfiedClues = 0;
    int unsatisfiedClues = 0;
    int unknownClues = 0;

    for (final clue in clues) {
      final result = clueEvaluator.evaluate(
        clue,
        activeAssignments,
        objectPositions,
      );

      switch (result) {
        case ClueEvaluationResult.satisfied:
          satisfiedClues++;
          break;
        case ClueEvaluationResult.unsatisfied:
          unsatisfiedClues++;
          break;
        case ClueEvaluationResult.unknown:
          unknownClues++;
          break;
      }
    }

    // 3. Determinar el estado lógico
    ValidationStatus status;

    if (!hasIncompleteAssignments) {
      // Todos los sospechosos han sido ubicados.
      if (!hasIncorrectPlacements && unsatisfiedClues == 0) {
        status = ValidationStatus.solved;
      } else {
        status = ValidationStatus.invalid;
      }
    } else {
      // Faltan sospechosos por ubicar.
      // Si existe al menos una pista evaluada (sea correcta o incorrecta), 
      // el jugador ya empezó a generar información útil: Partial.
      if (satisfiedClues > 0 || unsatisfiedClues > 0) {
        status = ValidationStatus.partial;
      } else {
        // Todo es desconocido
        status = ValidationStatus.incomplete;
      }
    }

    return ValidationResult(
      status: status,
      totalClues: clues.length,
      satisfiedClues: satisfiedClues,
      unsatisfiedClues: unsatisfiedClues,
      unknownClues: unknownClues,
    );
  }
}
