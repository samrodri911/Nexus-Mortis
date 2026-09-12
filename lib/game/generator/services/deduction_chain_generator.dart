import 'dart:math';

import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/generator/services/clue_text_formatter.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Generador maestro de cadenas deductivas humanas para Nexus Mortis.
///
/// Diseña deliberadamente un Grafo Acíclico Dirigido (DAG) de deducciones:
/// 1. Anclaje de sospechosos ($S_0$) con restricciones complementarias estrictas.
/// 2. Encadenamiento progresivo ($S_1 \dots S_n$) priorizando pistas concretas y visuales.
/// 3. Descarte de la víctima por agotamiento espacial Murdoku (0 pistas posicionales).
/// 4. Deducción del asesino en la zona de la víctima al finalizar el tablero.
class DeductionChainGenerator {
  const DeductionChainGenerator({
    this.simulator = const HumanDeductionReplay(),
    this.formatter = const ClueTextFormatter(),
  });

  final HumanDeductionReplay simulator;
  final ClueTextFormatter formatter;

  /// Intenta construir una cadena deductiva válida para el [caseData] dado.
  /// Retorna un registro con las pistas formateadas y las reglas globales (si fueran necesarias).
  ({List<SpatialClueData> clues, List<BoardRuleData> globalRules})? generateChain(
    CaseData caseData, {
    Random? random,
  }) {
    final rand = random ?? Random();
    final suspects = caseData.suspects.where((s) => s.id != caseData.victimId).toList();
    if (suspects.isEmpty) return null;

    final sol = caseData.solution.suspectPositions;
    final zoneMap = <CellPosition, String>{};
    for (final z in caseData.zones) {
      for (final c in z.cells) {
        zoneMap[c] = z.id;
      }
    }

    final suspectNames = {for (final s in caseData.suspects) s.id: s.name};
    final objectNames = {for (final po in caseData.placedObjects) po.object.id: po.object.name};
    final zoneNames = {for (final z in caseData.zones) z.id: z.name ?? z.id};

    // Generar todas las restricciones verdaderas posibles para cada sospechoso
    final candidateConstraintsPerSuspect = <String, List<SpatialConstraint>>{};
    for (final s in suspects) {
      candidateConstraintsPerSuspect[s.id] = _findTrueConstraintsForSuspect(
        sPos: sol[s.id]!,
        suspectId: s.id,
        caseData: caseData,
        zoneMap: zoneMap,
      );
    }

    // Intentar múltiples permutaciones y combinaciones de tarjetas
    for (int attempt = 0; attempt < 40; attempt++) {
      final shuffledSuspects = List.of(suspects)..shuffle(rand);
      final cards = <SpatialClueData>[];

      for (int i = 0; i < shuffledSuspects.length; i++) {
        final s = shuffledSuspects[i];
        final priorSuspects = shuffledSuspects.sublist(0, i).map((ps) => ps.id).toSet();

        final availableConstraints = candidateConstraintsPerSuspect[s.id]!.where((c) {
          if (suspectNames.containsKey(c.targetId)) {
            return priorSuspects.contains(c.targetId);
          }
          return true;
        }).toList();

        if (availableConstraints.isEmpty) break;

        final prioritized = (List.of(availableConstraints)
              ..sort((a, b) => _constraintPriority(b).compareTo(_constraintPriority(a))))
            .take(16)
            .toList();

        final prevCase = caseData.copyWith(clues: cards, globalRules: const []);
        final prevSim = simulator.simulate(prevCase, cards);
        final before = prevSim.domainSizes[s.id] ?? (caseData.boardRows * caseData.boardColumns);

        SpatialClueData? bestClueForSuspect;
        int minAfter = before;

        // Probar combinaciones de restricciones buscando la reducción más efectiva
        for (int c1 = 0; c1 < prioritized.length; c1++) {
          for (int c2 = c1; c2 < prioritized.length; c2++) {
            final selectedConstraints = <SpatialConstraint>[];
            selectedConstraints.add(prioritized[c1]);
            if (c1 != c2) {
              selectedConstraints.add(prioritized[c2]);
            }

            final testClue = SpatialClueData(
              id: 'clue_${s.id}',
              suspectId: s.id,
              text: '',
              constraints: selectedConstraints,
            );

            final tempCards = [...cards, testClue];
            final tempCase = caseData.copyWith(clues: tempCards, globalRules: const []);
            final simResult = simulator.simulate(tempCase, tempCards);
            final after = simResult.domainSizes[s.id] ?? 0;

            if (after > 0 && after < minAfter) {
              minAfter = after;
              bestClueForSuspect = testClue;
              if (after == 1 && c1 == c2) {
                // Si con 1 sola restricción ya alcanza 1 candidato, es óptimo
                break;
              }
            }
          }
          if (minAfter == 1 && bestClueForSuspect?.activeConstraints.length == 1) {
            break;
          }
        }

        if (bestClueForSuspect != null && minAfter < before) {
          cards.add(bestClueForSuspect);
        } else {
          break;
        }
      }

      if (cards.length != suspects.length) continue;

      // Tarjeta canónica de la víctima (0 restricciones posicionales directas)
      final victimCard = SpatialClueData(
        id: 'clue_${caseData.victimId}',
        suspectId: caseData.victimId,
        text: ClueTextFormatter.canonicalVictimText,
        constraints: const [],
      );

      final fullClueSet = [...cards, victimCard];

      // Formatear texto de cada tarjeta
      final formattedClues = <SpatialClueData>[];
      for (final card in fullClueSet) {
        final text = formatter.format(
          clue: card,
          suspectNames: suspectNames,
          objectNames: objectNames,
          zoneNames: zoneNames,
          victimId: caseData.victimId,
        );
        formattedClues.add(card.copyWith(text: text));
      }

      // =======================================================================
      // EVALUACIÓN DE CADENA DEDUCTIVA Y OPERADORES DE CLAUSURA GLOBAL
      // =======================================================================
      // Buscar reglas globales verdaderas y semánticamente correctas para el escenario
      final candidateRules = _findTrueGlobalRules(caseData, zoneMap, zoneNames);
      BoardRuleData? bestUsefulRule;
      int maxUsefulReduction = 0;

      for (final rule in candidateRules) {
        final caseWithRule = caseData.copyWith(clues: formattedClues, globalRules: [rule]);
        final simWithRule = simulator.simulate(caseWithRule, formattedClues);

        if (_isValidSimulation(simWithRule, caseData)) {
          final ruleSteps = simWithRule.trace.where((s) => s.sourceType == DeductionSourceType.globalRule && s.ruleId == rule.id);
          final reduction = ruleSteps.fold<int>(0, (sum, s) => sum + s.reductionAmount);

          if (reduction > 0 && reduction > maxUsefulReduction) {
            maxUsefulReduction = reduction;
            bestUsefulRule = rule;
            if (rule.type == BoardRuleType.maxOnePersonPerRoomExceptCrime) {
              break;
            }
          }
        }
      }

      // 1. Si encontramos una regla global útil que aporta reducción real y resuelve el caso:
      if (bestUsefulRule != null) {
        return (clues: formattedClues, globalRules: [bestUsefulRule]);
      }

      // 2. Probar combinación dual de reglas si 1 no fue suficiente para cerrar ambigüedades
      if (candidateRules.length >= 2) {
        for (int r1 = 0; r1 < candidateRules.length; r1++) {
          for (int r2 = r1 + 1; r2 < candidateRules.length; r2++) {
            final dualRules = [candidateRules[r1], candidateRules[r2]];
            final caseWithDual = caseData.copyWith(clues: formattedClues, globalRules: dualRules);
            final simWithDual = simulator.simulate(caseWithDual, formattedClues);
            if (_isValidSimulation(simWithDual, caseData)) {
              final dualSteps = simWithDual.trace.where((s) => s.sourceType == DeductionSourceType.globalRule);
              final dualReduction = dualSteps.fold<int>(0, (sum, s) => sum + s.reductionAmount);
              if (dualReduction > 0) {
                return (clues: formattedClues, globalRules: dualRules);
              }
            }
          }
        }
      }
    }

    return null;
  }

  List<BoardRuleData> _findTrueGlobalRules(
    CaseData caseData,
    Map<CellPosition, String> zoneMap,
    Map<String, String> zoneNames,
  ) {
    final rules = <BoardRuleData>[];
    final sol = caseData.solution.suspectPositions;
    final victimPos = sol[caseData.victimId]!;
    final crimeZone = zoneMap[victimPos]!;

    final occupantsPerZone = <String, int>{};
    for (final pos in sol.values) {
      final z = zoneMap[pos];
      if (z != null) {
        occupantsPerZone[z] = (occupantsPerZone[z] ?? 0) + 1;
      }
    }

    // 1. maxOnePersonPerRoomExceptCrime
    final allNonCrimeHaveAtMostOne = occupantsPerZone.entries.where((e) => e.key != crimeZone).every((e) => e.value <= 1);
    final crimeHasExactlyTwo = (occupantsPerZone[crimeZone] ?? 0) == 2;
    if (allNonCrimeHaveAtMostOne && crimeHasExactlyTwo) {
      rules.add(const BoardRuleData(
        id: 'rule_room_occupancy',
        type: BoardRuleType.maxOnePersonPerRoomExceptCrime,
        text: 'Cada habitación ocupada albergaba exactamente a una persona, salvo la escena del crimen, donde se encontraban dos.',
      ));
    }

    // 2. noEmptyRooms
    final allZonesOccupied = caseData.zones.every((z) => (occupantsPerZone[z.id] ?? 0) >= 1);
    if (allZonesOccupied) {
      rules.add(const BoardRuleData(
        id: 'rule_no_empty_rooms',
        type: BoardRuleType.noEmptyRooms,
        text: 'Ninguna habitación del recinto quedó desierta durante el suceso; todas tenían al menos un ocupante.',
      ));
    }

    // 3. singleOccupantZone
    for (final z in caseData.zones) {
      if (z.id != crimeZone && (occupantsPerZone[z.id] ?? 0) == 1) {
        final zName = zoneNames[z.id] ?? z.id;
        rules.add(BoardRuleData(
          id: 'rule_single_occupant_${z.id}',
          type: BoardRuleType.singleOccupantZone,
          text: 'La zona $zName albergaba a una única persona durante la noche.',
          targetId: z.id,
        ));
      }
    }

    // 4. crimeSceneHasObject / crimeSceneHasNoObject
    final zonesWithObjects = caseData.placedObjects.map((po) => zoneMap[po.position]).where((z) => z != null).toSet();
    if (zonesWithObjects.contains(crimeZone)) {
      rules.add(const BoardRuleData(
        id: 'rule_crime_has_object',
        type: BoardRuleType.crimeSceneHasObject,
        text: 'La escena del crimen tuvo lugar en una habitación provista de mobiliario.',
      ));
    } else {
      rules.add(const BoardRuleData(
        id: 'rule_crime_has_no_object',
        type: BoardRuleType.crimeSceneHasNoObject,
        text: 'La escena del crimen era una estancia despejada, completamente desprovista de muebles.',
      ));
    }

    return rules;
  }

  bool _isValidSimulation(HumanDeductionReplayResult simResult, CaseData caseData) {
    if (!simResult.solved ||
        simResult.stuck ||
        simResult.requiresGuessing ||
        !simResult.killerDeductionUnique ||
        simResult.deducedKillerId != caseData.killerId ||
        !simResult.victimSolvedByExhaustion ||
        simResult.victimCandidateCells != 1 ||
        simResult.victimCandidateRooms != 1 ||
        !simResult.domainSizes.values.every((c) => c == 1)) {
      return false;
    }

    // Verify final positions exactly match Ground Truth
    for (final s in caseData.suspects) {
      if (simResult.finalPositions[s.id] != caseData.solution.suspectPositions[s.id]) {
        return false;
      }
    }
    return true;
  }

  int _constraintPriority(SpatialConstraint c) {
    switch (c.relation) {
      case SpatialRelation.immediatelyNorthOf:
      case SpatialRelation.immediatelySouthOf:
      case SpatialRelation.immediatelyEastOf:
      case SpatialRelation.immediatelyWestOf:
        return 10;
      case SpatialRelation.adjacentTo:
        return 8;
      case SpatialRelation.inZone:
        return 7;
      case SpatialRelation.sameRow:
      case SpatialRelation.sameColumn:
        return 5;
      case SpatialRelation.leftOf:
      case SpatialRelation.rightOf:
      case SpatialRelation.above:
      case SpatialRelation.below:
        return 3;
      case SpatialRelation.notAdjacentTo:
      case SpatialRelation.differentRow:
      case SpatialRelation.differentColumn:
      case SpatialRelation.notInZone:
        return 1;
    }
  }

  List<SpatialConstraint> _findTrueConstraintsForSuspect({
    required CellPosition sPos,
    required String suspectId,
    required CaseData caseData,
    required Map<CellPosition, String> zoneMap,
  }) {
    final list = <SpatialConstraint>[];
    final sol = caseData.solution.suspectPositions;
    const evaluator = SpatialClueEvaluator();

    // 1. Zona
    final sZone = zoneMap[sPos];
    if (sZone != null) {
      list.add(SpatialConstraint(
        relation: SpatialRelation.inZone,
        targetId: sZone,
        type: ClueType.zone,
      ));
    }

      // 2. Relaciones con objetos
      for (final relation in SpatialRelation.values) {
        if (relation == SpatialRelation.inZone || relation == SpatialRelation.notInZone) {
          continue;
        }

        for (final po in caseData.placedObjects) {
          final oPos = po.position;
          final oId = po.object.id;
          if (evaluator.evaluate(suspectPosition: sPos, targetPosition: oPos, relation: relation)) {
             list.add(SpatialConstraint(relation: relation, targetId: oId, type: _getTypeForRelation(relation)));
          }
        }

        // 3. Otros Sospechosos
        for (final other in caseData.suspects) {
          if (other.id == suspectId || other.id == caseData.victimId) continue;
          final oPos = sol[other.id]!;
          final oId = other.id;
          if (evaluator.evaluate(suspectPosition: sPos, targetPosition: oPos, relation: relation)) {
             list.add(SpatialConstraint(relation: relation, targetId: oId, type: _getTypeForRelation(relation)));
          }
        }
      }

    return list;
  }

  ClueType _getTypeForRelation(SpatialRelation r) {
    switch(r) {
      case SpatialRelation.adjacentTo:
      case SpatialRelation.notAdjacentTo:
        return ClueType.adjacency;
      case SpatialRelation.sameRow:
      case SpatialRelation.sameColumn:
      case SpatialRelation.differentRow:
      case SpatialRelation.differentColumn:
        return ClueType.coLocation;
      case SpatialRelation.above:
      case SpatialRelation.below:
      case SpatialRelation.leftOf:
      case SpatialRelation.rightOf:
      case SpatialRelation.immediatelyNorthOf:
      case SpatialRelation.immediatelySouthOf:
      case SpatialRelation.immediatelyEastOf:
      case SpatialRelation.immediatelyWestOf:
        return ClueType.cardinal;
      case SpatialRelation.inZone:
      case SpatialRelation.notInZone:
        return ClueType.zone;
    }
  }
}
