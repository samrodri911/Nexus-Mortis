import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/player/models/player_assignment.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/validation/models/validation_result.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Servicio responsable de validar el estado del tablero del jugador
/// cruzando sus asignaciones con las pistas y la solución oculta.
class ValidationService {
  const ValidationService({
    required this.caseData,
    required this.clueEvaluator,
  });

  final CaseData caseData;

  /// Evaluador de pistas.
  final ClueEvaluator clueEvaluator;

  /// Valida el estado completo del tablero exigiendo descartes explícitos.
  ValidationResult validate(PlayerBoardState playerState) {
    // 1. Extraer posiciones activas (solo aquellos sospechosos con exactamente 1 candidato)
    final Map<String, CellPosition> activeAssignments = {};
    final assignedCells = <CellPosition>{};
    bool hasIncorrectPlacements = false;

    // Evaluamos también contra la solución
    for (final PlayerAssignment assignment in playerState.assignments) {
      if (assignment.candidates.length == 1) {
        final pos = assignment.candidates.first;
        activeAssignments[assignment.suspectId] = pos;
        assignedCells.add(pos);

        if (caseData.solution.suspectPositions[assignment.suspectId] != pos) {
          hasIncorrectPlacements = true;
        }
      }
    }

    // Identificar objetos fijos
    final objectPositions = <String, CellPosition>{};
    final blockedCells = <CellPosition>{};
    for (final obj in caseData.placedObjects) {
      objectPositions[obj.object.id] = obj.position;
      blockedCells.add(obj.position);
    }

    // 2. Verificar Completitud Estricta
    // Un tablero está completo si CADA celda es:
    // a) Asignada a un personaje
    // b) Ocupada por un objeto
    // c) Descartada explícitamente con X (playerState.eliminatedCells)
    bool isBoardComplete = true;
    for (int r = 0; r < caseData.boardRows; r++) {
      for (int c = 0; c < caseData.boardColumns; c++) {
        final pos = CellPosition(r, c);
        final isAssigned = assignedCells.contains(pos);
        final isBlocked = blockedCells.contains(pos);
        final isEliminated = playerState.eliminatedCells.contains(pos);

        if (!isAssigned && !isBlocked && !isEliminated) {
          isBoardComplete = false;
          break;
        }
      }
      if (!isBoardComplete) break;
    }

    // Verificar que TODOS los sospechosos y víctima estén asignados.
    if (activeAssignments.length != caseData.suspects.length) {
      isBoardComplete = false;
    }

    // 3. Evaluar pistas usando solo las posiciones activas
    int satisfiedClues = 0;
    int unsatisfiedClues = 0;
    int unknownClues = 0;

    for (final clue in caseData.clues) {
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

    // 4. Determinar el estado lógico
    ValidationStatus status;

    if (isBoardComplete) {
      // Todos los sospechosos ubicados y 100% celdas explicadas.
      if (!hasIncorrectPlacements && unsatisfiedClues == 0) {
        status = ValidationStatus.solved;
      } else {
        status = ValidationStatus.invalid;
      }
    } else {
      // Faltan acciones por parte del jugador
      if (satisfiedClues > 0 || unsatisfiedClues > 0) {
        status = ValidationStatus.partial;
      } else {
        status = ValidationStatus.incomplete;
      }
    }

    return ValidationResult(
      status: status,
      totalClues: caseData.clues.length,
      satisfiedClues: satisfiedClues,
      unsatisfiedClues: unsatisfiedClues,
      unknownClues: unknownClues,
    );
  }
}
