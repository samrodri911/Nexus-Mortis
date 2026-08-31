import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';

import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';

import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';

import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';

import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';


import 'package:nexus_mortis/game/solver/heuristics/variable_ordering.dart';

import 'package:nexus_mortis/game/solver/models/assignment_state.dart';

import 'package:nexus_mortis/game/solver/models/solver_result.dart';



/// Motor de resolución CSP (Constraint Satisfaction Problem) para Nexus Mortis.

class PuzzleSolver {

  PuzzleSolver({

    ClueEvaluator? clueEvaluator,

    VariableOrdering? ordering,

  })  : _clueEvaluator =

            clueEvaluator ?? const ClueEvaluator(SpatialClueEvaluator()),

        _ordering = ordering ?? const VariableOrdering();



  final ClueEvaluator _clueEvaluator;

  final VariableOrdering _ordering;



  SolverResult solve(CaseData caseData, {int maxSolutions = 2}) {

    final suspectIds = caseData.suspects.map((s) => s.id).toList();

    final clues = caseData.clues;



    final objectPositions = <String, CellPosition>{};

    for (final obj in caseData.placedObjects) {

      objectPositions[obj.object.id] = obj.position;

    }



    final blockedCells = objectPositions.values.toSet();



    // Crear mapa de CellPosition a Zone ID para evaluación rápida.

    final zoneMap = <CellPosition, String>{};

    for (final zone in caseData.zones) {

      for (final cell in zone.cells) {

        zoneMap[cell] = zone.id;

      }

    }



    final allFreeCells = <CellPosition>[];

    for (int r = 0; r < caseData.boardRows; r++) {

      for (int c = 0; c < caseData.boardColumns; c++) {

        final pos = CellPosition(r, c);

        if (!blockedCells.contains(pos)) {

          allFreeCells.add(pos);

        }

      }

    }



    final initialDomains = <String, List<CellPosition>>{

      for (final id in suspectIds) id: List.of(allFreeCells),

    };



    final solutions = <SolutionData>[];

    var visitedNodes = 0;



    _backtrack(

      state: const AssignmentState({}),

      unassigned: suspectIds,

      domains: initialDomains,

      clues: clues,

      objectPositions: objectPositions,

      solutions: solutions,

      visitedNodes: (count) => visitedNodes = count,

      visitedNodesMutable: _MutableInt(0),

      maxSolutions: maxSolutions,

      zoneMap: zoneMap,

      victimId: caseData.victimId,

      killerId: caseData.killerId,

      globalRules: caseData.globalRules,

    );



    return SolverResult(

      solutionCount: solutions.length,

      solutions: solutions,

      visitedNodes: visitedNodes,

    );

  }



  bool _backtrack({

    required AssignmentState state,

    required List<String> unassigned,

    required Map<String, List<CellPosition>> domains,

    required List<SpatialClueData> clues,

    required Map<String, CellPosition> objectPositions,

    required List<SolutionData> solutions,

    required void Function(int) visitedNodes,

    required _MutableInt visitedNodesMutable,

    required int maxSolutions,

    required Map<CellPosition, String> zoneMap,

    required String victimId,

    required String killerId,

    required List<BoardRuleData> globalRules,

  }) {

    visitedNodesMutable.value++;

    visitedNodes(visitedNodesMutable.value);



    if (unassigned.isEmpty) {
      if (globalRules.any((r) => r.type == BoardRuleType.noEmptyRooms)) {
        final occupiedZones = state.assignments.values.map((p) => zoneMap[p]).where((z) => z != null).toSet();
        final allZones = zoneMap.values.toSet();
        if (occupiedZones.length < allZones.length) {
          return false;
        }
      }

      if (_allCluesSatisfied(state.assignments, clues, objectPositions, zoneMap: zoneMap)) {
        solutions.add(SolutionData(suspectPositions: Map.of(state.assignments)));
      }
      return solutions.length >= maxSolutions;
    }



    final suspectId = _ordering.pickNext(unassigned, domains);

    final remainingUnassigned =

        unassigned.where((id) => id != suspectId).toList();

    final domain = domains[suspectId] ?? [];



    for (final position in domain) {

      bool isBlocked = false;

      for (final occupied in state.occupiedPositions) {

        if (occupied.row == position.row || occupied.col == position.col) {

          isBlocked = true;

          break;

        }

      }

      if (isBlocked) continue;



      final newState = state.extend(suspectId, position);



      // Verificación de la Regla de Asesióno (Zonas)

      // 1. Víctima y Asesióno deben estar en la misma zona.

      // 2. Nadie más puede estar en la zona de la víctima.

      if (!_isZoneRuleSatisfied(newState.assignments, zoneMap, victimId, killerId, globalRules, objectPositions)) {
        continue;
      }

      if (_hasUnsatisfiedClue(newState.assignments, clues, objectPositions, zoneMap: zoneMap)) {
        continue;
      }

      final prunedDomains = _forwardCheck(
        remainingUnassigned,
        domains,
        position,
      );

      if (prunedDomains == null) continue;

      final shouldStop = _backtrack(
        state: newState,
        unassigned: remainingUnassigned,
        domains: prunedDomains,
        clues: clues,
        objectPositions: objectPositions,
        solutions: solutions,
        visitedNodes: visitedNodes,
        visitedNodesMutable: visitedNodesMutable,
        maxSolutions: maxSolutions,
        zoneMap: zoneMap,
        victimId: victimId,
        killerId: killerId,
        globalRules: globalRules,
      );



      if (shouldStop) return true;

    }



    return false;

  }



  /// Verifica la validez parcial o total de la regla de zonas y reglas globales para el estado actual.
  bool _isZoneRuleSatisfied(
    Map<String, CellPosition> assignments,
    Map<CellPosition, String> zoneMap,
    String victimId,
    String killerId,
    List<BoardRuleData> globalRules,
    Map<String, CellPosition> objectPositions,
  ) {
    final victimPos = assignments[victimId];
    final killerPos = assignments[killerId];

    // Si la víctima está asignada, verificamos a los demás respecto a ella.
    if (victimPos != null) {
      final victimZone = zoneMap[victimPos];

      for (final entry in assignments.entries) {
        final id = entry.key;
        final pos = entry.value;
        if (id == victimId) continue;

        final zone = zoneMap[pos];

        if (id == killerId) {
          // El asesino DEBE estar en la misma zona que la víctima.
          if (zone != victimZone) return false;
        } else {
          // Los inocentes NO PUEDEN estar en la zona de la víctima.
          if (zone == victimZone) return false;
        }
      }
    } else {
      // Si la víctima NO está asignada, verificamos si el asesino
      // y algún inocente comparten zona
      if (killerPos != null) {
        final killerZone = zoneMap[killerPos];

        for (final entry in assignments.entries) {
          final id = entry.key;
          final pos = entry.value;
          if (id == killerId) continue;

          final zone = zoneMap[pos];
          if (zone == killerZone) return false;
        }
      }
    }

    if (globalRules.isEmpty) return true;

    final zonesWithObjects = objectPositions.values.map((p) => zoneMap[p]).where((z) => z != null).toSet();

    for (final rule in globalRules) {
      switch (rule.type) {
        case BoardRuleType.maxOnePersonPerRoomExceptCrime:
          final zoneCount = <String, int>{};
          for (final entry in assignments.entries) {
            final z = zoneMap[entry.value];
            if (z != null) {
              zoneCount[z] = (zoneCount[z] ?? 0) + 1;
            }
          }
          for (final entry in zoneCount.entries) {
            final isCrimeZone = (victimPos != null && entry.key == zoneMap[victimPos]) ||
                (victimPos == null && killerPos != null && entry.key == zoneMap[killerPos]);
            if (isCrimeZone) {
              if (entry.value > 2) return false;
            } else {
              if (entry.value > 1) return false;
            }
          }
          break;

        case BoardRuleType.noEmptyRooms:
          break;

        case BoardRuleType.singleOccupantZone:
          if (rule.targetId != null) {
            int count = 0;
            for (final pos in assignments.values) {
              if (zoneMap[pos] == rule.targetId) count++;
            }
            if (count > 1) return false;
          }
          break;

        case BoardRuleType.crimeSceneHasObject:
          if (victimPos != null) {
            final vZone = zoneMap[victimPos];
            if (vZone != null && !zonesWithObjects.contains(vZone)) {
              return false;
            }
          }
          break;

        case BoardRuleType.crimeSceneHasNoObject:
          if (victimPos != null) {
            final vZone = zoneMap[victimPos];
            if (vZone != null && zonesWithObjects.contains(vZone)) {
              return false;
            }
          }
          break;
      }
    }

    return true;
  }



    bool _hasUnsatisfiedClue(
    Map<String, CellPosition> assignments,
    List<SpatialClueData> clues,
    Map<String, CellPosition> objectPositions, {
    Map<CellPosition, String>? zoneMap,
  }) {
    for (final clue in clues) {
      final result = _clueEvaluator.evaluate(
        clue,
        assignments,
        objectPositions,
        zoneMap: zoneMap,
      );
      if (result == ClueEvaluationResult.unsatisfied) return true;
    }
    return false;
  }

  bool _allCluesSatisfied(
    Map<String, CellPosition> assignments,
    List<SpatialClueData> clues,
    Map<String, CellPosition> objectPositions, {
    Map<CellPosition, String>? zoneMap,
  }) {
    for (final clue in clues) {
      final result = _clueEvaluator.evaluate(
        clue,
        assignments,
        objectPositions,
        zoneMap: zoneMap,
      );
      if (result != ClueEvaluationResult.satisfied) return false;
    }
    return true;
  }

Map<String, List<CellPosition>>? _forwardCheck(

    List<String> unassigned,

    Map<String, List<CellPosition>> currentDomains,

    CellPosition occupiedPosition,

  ) {

    final pruned = <String, List<CellPosition>>{};



    for (final id in unassigned) {

      final domain = currentDomains[id] ?? [];

      final filtered = domain.where((pos) {

        return pos.row != occupiedPosition.row && pos.col != occupiedPosition.col;

      }).toList();



      if (filtered.isEmpty) return null; 



      pruned[id] = filtered;

    }



    return pruned;

  }

}



class _MutableInt {

  _MutableInt(this.value);

  int value;

}

