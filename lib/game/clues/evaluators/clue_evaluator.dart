import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Orquesta la evaluación de una pista conectándola con el motor matemático.
///
/// Es capaz de buscar automáticamente el objetivo (target) tanto en la lista
/// de objetos estáticos como en las asignaciones de sospechosos.
class ClueEvaluator {
  const ClueEvaluator(this.spatialEvaluator);

  final SpatialClueEvaluator spatialEvaluator;

  /// Evalúa una pista dadas las posiciones activas.
  ///
  /// Retorna [ClueEvaluationResult.unknown] si alguna de las dos entidades
  /// involucradas en la pista no tiene una posición definida en los mapas.
  ClueEvaluationResult evaluate(
    SpatialClueData clue,
    Map<String, CellPosition> activeAssignments,
    Map<String, CellPosition> objectPositions,
  ) {
    // 1. Validar al sospechoso principal
    final suspectPos = activeAssignments[clue.suspectId];
    if (suspectPos == null) {
      return ClueEvaluationResult.unknown;
    }

    // 2. Resolver el objetivo (puede ser un objeto fijo o un sospechoso)
    CellPosition? targetPos = objectPositions[clue.targetId];
    targetPos ??= activeAssignments[clue.targetId];

    if (targetPos == null) {
      return ClueEvaluationResult.unknown;
    }

    // 3. Evaluar matemáticamente
    final isSatisfied = spatialEvaluator.evaluate(
      suspectPosition: suspectPos,
      targetPosition: targetPos,
      relation: clue.relation,
    );

    return isSatisfied
        ? ClueEvaluationResult.satisfied
        : ClueEvaluationResult.unsatisfied;
  }
}
