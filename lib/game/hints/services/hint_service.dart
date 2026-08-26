import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/hints/models/hint_result.dart';
import 'package:nexus_mortis/game/hints/models/hint_type.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

/// Servicio determinista para la generación de pistas.
/// No modifica el estado del juego ni gasta monedas.
class HintService {
  HintService({
    required this.clueEvaluator,
  });

  final ClueEvaluator clueEvaluator;

  HintResult generateHint(HintType type, CaseData caseData, PlayerBoardState state, ValidationService validationService) {
    switch (type) {
      case HintType.soft:
        return _generateSoftHint(caseData, state, validationService);
      case HintType.medium:
        return _generateMediumHint(caseData, state, validationService);
      case HintType.reveal:
        return _generateRevealHint(caseData, state, validationService);
    }
  }

  /// Pista suave: Indica una pista que el jugador aún no ha utilizado o cumplido,
  /// pero sin decirle si está equivocado o no.
  HintResult _generateSoftHint(CaseData caseData, PlayerBoardState state, ValidationService validationService) {
    final activeAssignments = _extractActiveAssignments(state);
    
    // Extraer posiciones de objetos
    final objectPositions = <String, CellPosition>{};
    for (final obj in caseData.placedObjects) {
      objectPositions[obj.object.id] = obj.position;
    }

    // Buscar una pista que sea 'unknown' (aún no se puede evaluar porque faltan piezas)
    for (final clue in caseData.clues) {
      final result = clueEvaluator.evaluate(
        clue,
        activeAssignments,
        objectPositions,
      );

      if (result == ClueEvaluationResult.unknown) {
        return HintResult(
          type: HintType.soft,
          message: "Presta atención a esta pista: '${clue.text}'",
        );
      }
    }

    // Fallback si no hay pistas unknown
    return const HintResult(
      type: HintType.soft,
      message: "Repasa cuidadosamente las relaciones entre los sospechosos y los objetos.",
    );
  }

  /// Pista media: Evalúa si hay alguna pista que actualmente se está violando.
  HintResult _generateMediumHint(CaseData caseData, PlayerBoardState state, ValidationService validationService) {
    final activeAssignments = _extractActiveAssignments(state);
    
    final objectPositions = <String, CellPosition>{};
    for (final obj in caseData.placedObjects) {
      objectPositions[obj.object.id] = obj.position;
    }

    for (final clue in caseData.clues) {
      final result = clueEvaluator.evaluate(
        clue,
        activeAssignments,
        objectPositions,
      );

      if (result == ClueEvaluationResult.unsatisfied) {
        return HintResult(
          type: HintType.medium,
          message: "Hay una inconsistencia con esta pista: '${clue.text}'",
        );
      }
    }

    // Fallback si no hay errores actuales
    return const HintResult(
      type: HintType.medium,
      message: "Por ahora todo parece consistente con las pistas, ¡sigue así!",
    );
  }

  /// Pista Reveal: Revela una relación lógica verdadera basada en la solución,
  /// sin dar coordenadas directas.
  HintResult _generateRevealHint(CaseData caseData, PlayerBoardState state, ValidationService validationService) {
    final solution = caseData.solution;
    
    // Buscar un sospechoso que aún no esté correctamente ubicado por el jugador
    final activeAssignments = _extractActiveAssignments(state);
    String? targetSuspectId;
    CellPosition? targetPos;

    for (final suspectId in solution.suspectPositions.keys) {
      final currentPos = activeAssignments[suspectId];
      final correctPos = solution.suspectPositions[suspectId]!;
      
      if (currentPos != correctPos) {
        targetSuspectId = suspectId;
        targetPos = correctPos;
        break; // Tomar el primero que falle o falte
      }
    }

    if (targetSuspectId == null || targetPos == null) {
      return const HintResult(
        type: HintType.reveal,
        message: "¡Ya casi lo tienes! Solo necesitas confirmar tus deducciones.",
      );
    }

    // Construir una verdad lógica: ¿Está cerca de algún objeto?
    final suspectName = caseData.suspects.firstWhere((s) => s.id == targetSuspectId).name;
    
    for (final obj in caseData.placedObjects) {
      final dr = (obj.position.row - targetPos.row).abs();
      final dc = (obj.position.col - targetPos.col).abs();
      
      if (dr <= 1 && dc <= 1 && (dr != 0 || dc != 0)) {
        return HintResult(
          type: HintType.reveal,
          message: "$suspectName está adyacente a ${obj.object.name}.",
        );
      }
    }
    
    // Fallback relacional de fila o columna (sin decir número exacto si es posible)
    // Para simplificar, si no hay objetos adyacentes, lo relacionamos con otro sospechoso.
    for (final otherId in solution.suspectPositions.keys) {
      if (otherId == targetSuspectId) continue;
      final otherPos = solution.suspectPositions[otherId]!;
      if (otherPos.row == targetPos.row) {
        final otherName = caseData.suspects.firstWhere((s) => s.id == otherId).name;
        return HintResult(
          type: HintType.reveal,
          message: "$suspectName está en la misma fila que $otherName.",
        );
      }
    }

    return HintResult(
      type: HintType.reveal,
      message: "$suspectName es clave para resolver este caso.",
    );
  }

  Map<String, CellPosition> _extractActiveAssignments(PlayerBoardState state) {
    final Map<String, CellPosition> activeAssignments = {};
    for (final assignment in state.assignments) {
      if (assignment.candidates.length == 1) {
        activeAssignments[assignment.suspectId] = assignment.candidates.first;
      }
    }
    return activeAssignments;
  }
}
