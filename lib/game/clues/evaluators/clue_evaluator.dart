import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Orquesta la evaluación de una tarjeta de pista conectándola con el motor matemático y espacial.
class ClueEvaluator {
  const ClueEvaluator(this.spatialEvaluator);

  final SpatialClueEvaluator spatialEvaluator;

  /// Evalúa una tarjeta de pista dadas las posiciones activas de sospechosos, objetos y zonas.
  ClueEvaluationResult evaluate(
    SpatialClueData clue,
    Map<String, CellPosition> activeAssignments,
    Map<String, CellPosition> objectPositions, {
    Map<CellPosition, String>? zoneMap,
    Map<String, List<CellPosition>>? zoneCells,
  }) {
    // La tarjeta canónica de la víctima no impone restricciones posicionales
    if (clue.isVictimCard) {
      return ClueEvaluationResult.satisfied;
    }

    // 1. Validar al sospechoso principal
    final suspectPos = activeAssignments[clue.suspectId];
    if (suspectPos == null) {
      return ClueEvaluationResult.unknown;
    }

    final constraints = clue.activeConstraints;
    if (constraints.isEmpty) {
      return ClueEvaluationResult.satisfied;
    }

    bool hasUnknown = false;

    // Todas las restricciones de la tarjeta deben cumplirse (Conjunción)
    for (final constraint in constraints) {
      final res = _evaluateSingleConstraint(
        constraint: constraint,
        suspectPos: suspectPos,
        activeAssignments: activeAssignments,
        objectPositions: objectPositions,
        zoneMap: zoneMap,
        zoneCells: zoneCells,
      );

      if (res == ClueEvaluationResult.unsatisfied) {
        return ClueEvaluationResult.unsatisfied;
      }
      if (res == ClueEvaluationResult.unknown) {
        hasUnknown = true;
      }
    }

    return hasUnknown ? ClueEvaluationResult.unknown : ClueEvaluationResult.satisfied;
  }

  ClueEvaluationResult _evaluateSingleConstraint({
    required SpatialConstraint constraint,
    required CellPosition suspectPos,
    required Map<String, CellPosition> activeAssignments,
    required Map<String, CellPosition> objectPositions,
    Map<CellPosition, String>? zoneMap,
    Map<String, List<CellPosition>>? zoneCells,
  }) {
    if (constraint.relation == SpatialRelation.inZone) {
      if (zoneMap != null) {
        final currentZone = zoneMap[suspectPos];
        return currentZone == constraint.targetId
            ? ClueEvaluationResult.satisfied
            : ClueEvaluationResult.unsatisfied;
      }
      if (zoneCells != null) {
        final cells = zoneCells[constraint.targetId];
        if (cells == null) return ClueEvaluationResult.unknown;
        return cells.contains(suspectPos)
            ? ClueEvaluationResult.satisfied
            : ClueEvaluationResult.unsatisfied;
      }
      return ClueEvaluationResult.unknown;
    }

    if (constraint.relation == SpatialRelation.notInZone) {
      if (zoneMap != null) {
        final currentZone = zoneMap[suspectPos];
        return currentZone != constraint.targetId
            ? ClueEvaluationResult.satisfied
            : ClueEvaluationResult.unsatisfied;
      }
      if (zoneCells != null) {
        final cells = zoneCells[constraint.targetId];
        if (cells == null) return ClueEvaluationResult.unknown;
        return !cells.contains(suspectPos)
            ? ClueEvaluationResult.satisfied
            : ClueEvaluationResult.unsatisfied;
      }
      return ClueEvaluationResult.unknown;
    }

    // Resolver objetivo (objeto o sospechoso)
    CellPosition? targetPos = objectPositions[constraint.targetId];
    targetPos ??= activeAssignments[constraint.targetId];

    if (targetPos == null) {
      return ClueEvaluationResult.unknown;
    }

    final isSatisfied = spatialEvaluator.evaluate(
      suspectPosition: suspectPos,
      targetPosition: targetPos,
      relation: constraint.relation,
    );

    return isSatisfied ? ClueEvaluationResult.satisfied : ClueEvaluationResult.unsatisfied;
  }
}
