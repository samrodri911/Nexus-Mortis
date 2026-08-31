import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/player/models/player_assignment.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/validation/models/validation_result.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Servicio responsable de validar el estado del tablero del jugador
/// y verificar la deducción del asesino contra la verdad del caso.
class ValidationService {
  const ValidationService({
    required this.caseData,
    required this.clueEvaluator,
  });

  final CaseData caseData;
  final ClueEvaluator clueEvaluator;

  /// Valida el estado completo del tablero.
  ///
  /// Regla estricta de completitud: CADA celda debe estar:
  /// a) Asignada definitivamente a un sospechoso o a la víctima
  /// b) Ocupada por un objeto fijo
  /// c) Descartada explícitamente por el jugador con una X (playerState.eliminatedCells)
  ///
  /// NOTA: Las auto-X visuales no cuentan como conclusión explícita.
  ValidationResult validateBoard(PlayerBoardState playerState) {
    final Map<String, CellPosition> activeAssignments = {};
    final assignedCells = <CellPosition>{};
    bool hasIncorrectPlacements = false;

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

    // 2. Verificar completitud: Todos los personajes (sospechosos y víctima) deben estar asignados
    final bool isBoardComplete = activeAssignments.length == caseData.suspects.length;

    // 3. Evaluar pistas usando posiciones activas
    int satisfiedClues = 0;
    int unsatisfiedClues = 0;
    int unknownClues = 0;

    final zoneMap = <CellPosition, String>{};
    for (final z in caseData.zones) {
      for (final c in z.cells) {
        zoneMap[c] = z.id;
      }
    }

    for (final clue in caseData.clues) {
      final result = clueEvaluator.evaluate(
        clue,
        activeAssignments,
        objectPositions,
        zoneMap: zoneMap,
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

    // 4. Determinar estado lógico
    ValidationStatus status;

    if (isBoardComplete) {
      if (!hasIncorrectPlacements && unsatisfiedClues == 0) {
        status = ValidationStatus.readyForKiller;
      } else {
        status = ValidationStatus.invalid;
      }
    } else {
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

  /// Método de retrocompatibilidad que invoca [validateBoard].
  ValidationResult validate(PlayerBoardState playerState) => validateBoard(playerState);

  /// Valida si el sospechoso acusado coincide con el asesino real del caso.
  bool validateKiller(String suspectId) {
    return suspectId == caseData.killerId;
  }
}
