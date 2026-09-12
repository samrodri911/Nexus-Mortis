import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

class ClueDeterminismResult {
  const ClueDeterminismResult({
    required this.isValid,
    required this.candidateCount,
    required this.candidates,
    this.rejectionReason,
    this.semanticallyConsistent = true,
    this.usesKnownInformation = true,
    this.isTruthful = true,
  });

  final bool isValid;
  final int candidateCount;
  final List<CellPosition> candidates;
  final String? rejectionReason;
  final bool semanticallyConsistent;
  final bool usesKnownInformation;
  final bool isTruthful;
}

class KnowledgeState {
  KnowledgeState({
    required this.domains,
  });

  /// Dominios de candidatos actuales para cada entidad (sospechosos y víctima)
  final Map<String, Set<CellPosition>> domains;

  KnowledgeState copy() {
    return KnowledgeState(
      domains: {
        for (final entry in domains.entries) entry.key: Set.from(entry.value),
      },
    );
  }
}

class ClueDeterminismValidator {
  const ClueDeterminismValidator([this._evaluator = const SpatialClueEvaluator()]);

  final SpatialClueEvaluator _evaluator;

  ClueDeterminismResult validateClue({
    required CaseData caseData,
    required SpatialClueData clue,
    required KnowledgeState state,
  }) {
    if (clue.isVictimCard) {
      return const ClueDeterminismResult(
        isValid: true,
        candidateCount: 1, // La tarjeta de víctima se evalúa globalmente
        candidates: [],
      );
    }

    final subjDomain = state.domains[clue.suspectId];
    if (subjDomain == null || subjDomain.isEmpty) {
      return const ClueDeterminismResult(
        isValid: false,
        candidateCount: 0,
        candidates: [],
        rejectionReason: 'Subject domain is already empty',
        isTruthful: false,
      );
    }

    final objectMap = <String, CellPosition>{};
    for (final po in caseData.placedObjects) {
      objectMap[po.object.id] = po.position;
    }

    final zoneMap = <CellPosition, String>{};
    for (final z in caseData.zones) {
      for (final c in z.cells) {
        zoneMap[c] = z.id;
      }
    }

    final validCandidates = <CellPosition>[];

    for (final sPos in subjDomain) {
      bool satisfiesAll = true;

      for (final constraint in clue.activeConstraints) {
        if (!_evaluateConstraint(sPos, constraint, state.domains, objectMap, zoneMap)) {
          satisfiesAll = false;
          break;
        }
      }

      if (satisfiesAll) {
        validCandidates.add(sPos);
      }
    }

    final truePos = caseData.solution.suspectPositions[clue.suspectId];
    final isTruthful = truePos != null && validCandidates.contains(truePos);

    if (!isTruthful) {
      return ClueDeterminismResult(
        isValid: false,
        candidateCount: validCandidates.length,
        candidates: validCandidates,
        rejectionReason: 'Clue is not truthful (ground truth position not in candidates)',
        isTruthful: false,
      );
    }

    if (validCandidates.length > 1) {
      return ClueDeterminismResult(
        isValid: false,
        candidateCount: validCandidates.length,
        candidates: validCandidates,
        rejectionReason: 'Ambiguous clue: leaves ${validCandidates.length} candidates',
        isTruthful: true,
      );
    }

    if (validCandidates.isEmpty) {
      return const ClueDeterminismResult(
        isValid: false,
        candidateCount: 0,
        candidates: [],
        rejectionReason: 'Impossible clue: 0 candidates',
        isTruthful: false,
      );
    }

    return ClueDeterminismResult(
      isValid: true,
      candidateCount: 1,
      candidates: validCandidates,
      isTruthful: true,
    );
  }

  bool _evaluateConstraint(
    CellPosition sPos,
    SpatialConstraint constraint,
    Map<String, Set<CellPosition>> domains,
    Map<String, CellPosition> objectMap,
    Map<CellPosition, String> zoneMap,
  ) {
    if (constraint.relation == SpatialRelation.inZone) {
      return zoneMap[sPos] == constraint.targetId;
    }
    if (constraint.relation == SpatialRelation.notInZone) {
      return zoneMap[sPos] != constraint.targetId;
    }

    Set<CellPosition> targetDomain;
    final isTargetObject = objectMap.containsKey(constraint.targetId);
    if (isTargetObject) {
      targetDomain = {objectMap[constraint.targetId]!};
    } else {
      targetDomain = domains[constraint.targetId] ?? {};
    }

    if (targetDomain.isEmpty) return false;

    return targetDomain.any((tPos) {
      if (!isTargetObject && (sPos.row == tPos.row || sPos.col == tPos.col)) {
        if (constraint.relation != SpatialRelation.sameRow &&
            constraint.relation != SpatialRelation.sameColumn) {
          return false;
        }
      }
      return _evaluator.evaluate(
        suspectPosition: sPos,
        targetPosition: tPos,
        relation: constraint.relation,
      );
    });
  }
}
