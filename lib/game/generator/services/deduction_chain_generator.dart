import 'dart:math';

import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/generator/services/clue_text_formatter.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
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
    this.simulator = const PuzzleSimulator(),
    this.formatter = const ClueTextFormatter(),
  });

  final PuzzleSimulator simulator;
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

        // Ordenar restricciones priorizando las más concretas y visuales
        availableConstraints.sort((a, b) => _constraintPriority(b).compareTo(_constraintPriority(a)));

        bool validCardFound = false;

        // Probar combinaciones de restricciones, priorizando anclajes iniciales fuertes
        for (int c1 = 0; c1 < availableConstraints.length; c1++) {
          for (int c2 = c1; c2 < availableConstraints.length; c2++) {
             final selectedConstraints = <SpatialConstraint>[];
             selectedConstraints.add(availableConstraints[c1]);
             if (c1 != c2) {
               selectedConstraints.add(availableConstraints[c2]);
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
             
             // STRICT REJECTION: If candidate count > 1, reject immediately!
             if (simResult.domainSizes[s.id] == 1) {
                 cards.add(testClue);
                 validCardFound = true;
                 break;
             }
          }
          if (validCardFound) break;
        }

        if (!validCardFound) break;
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
      // EVALUACIÓN DEL ESPACIO RESIDUAL DE LA VÍCTIMA (SIN REGLAS GLOBALES)
      // =======================================================================
      final caseWithoutRules = caseData.copyWith(clues: formattedClues, globalRules: const []);
      final baseSim = simulator.simulate(caseWithoutRules, formattedClues);

      // CASO 1: Ya está cerrado determinísticamente sin reglas globales
      if (_isValidSimulation(baseSim, caseData)) {
        return (clues: formattedClues, globalRules: const <BoardRuleData>[]);
      }

      // CASO 2: Espacio residual ambiguo -> Buscar operador de clausura natural
      final candidateRules = _findTrueGlobalRules(caseData, zoneMap, zoneNames);
      BoardRuleData? bestRule;
      int bestReduction = -1;

      for (final rule in candidateRules) {
        final caseWithRule = caseData.copyWith(clues: formattedClues, globalRules: [rule]);
        final simWithRule = simulator.simulate(caseWithRule, formattedClues);

        if (_isValidSimulation(simWithRule, caseData)) {
          final vBefore = baseSim.victimCandidateCells;
          final vAfter = simWithRule.victimCandidateCells;
          final reduction = vBefore - vAfter;

          // Exigir que la regla realmente haya reducido candidatos y cerrado a 1
          if (vAfter == 1 && simWithRule.victimCandidateRooms == 1 && reduction > bestReduction) {
            bestReduction = reduction;
            bestRule = rule;
            // Priorizar la regla canónica de ocupación de habitaciones
            if (rule.type == BoardRuleType.maxOnePersonPerRoomExceptCrime) {
              break;
            }
          }
        }
      }

      if (bestRule != null) {
        return (clues: formattedClues, globalRules: [bestRule]);
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

  bool _isValidSimulation(PuzzleSimulationResult simResult, CaseData caseData) {
    return simResult.solved &&
        !simResult.stuck &&
        !simResult.requiresGuessing &&
        simResult.killerDeductionUnique &&
        simResult.deducedKillerId == caseData.killerId &&
        simResult.victimSolvedByExhaustion &&
        simResult.victimCandidateCells == 1 &&
        simResult.victimCandidateRooms == 1 &&
        simResult.domainSizes.values.every((c) => c == 1);
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

    // 1. Zona
    final sZone = zoneMap[sPos];
    if (sZone != null) {
      list.add(SpatialConstraint(
        relation: SpatialRelation.inZone,
        targetId: sZone,
        type: ClueType.zone,
      ));
    }

    // 2. Objetos
    for (final po in caseData.placedObjects) {
      final oPos = po.position;
      final oId = po.object.id;

      // Inmediatos ortogonales (Máxima prioridad)
      if (sPos.row == oPos.row - 1 && sPos.col == oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.immediatelyNorthOf, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.row == oPos.row + 1 && sPos.col == oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.immediatelySouthOf, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.row == oPos.row && sPos.col == oPos.col + 1) {
        list.add(SpatialConstraint(relation: SpatialRelation.immediatelyEastOf, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.row == oPos.row && sPos.col == oPos.col - 1) {
        list.add(SpatialConstraint(relation: SpatialRelation.immediatelyWestOf, targetId: oId, type: ClueType.cardinal));
      }

      // Adyacencia
      final dist = (sPos.row - oPos.row).abs() + (sPos.col - oPos.col).abs();
      if (dist == 1) {
        list.add(SpatialConstraint(relation: SpatialRelation.adjacentTo, targetId: oId, type: ClueType.adjacency));
      }

      // Co-localización
      if (sPos.row == oPos.row) {
        list.add(SpatialConstraint(relation: SpatialRelation.sameRow, targetId: oId, type: ClueType.coLocation));
      }
      if (sPos.col == oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.sameColumn, targetId: oId, type: ClueType.coLocation));
      }

      // Cardinales abiertas
      if (sPos.row < oPos.row) {
        list.add(SpatialConstraint(relation: SpatialRelation.above, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.row > oPos.row) {
        list.add(SpatialConstraint(relation: SpatialRelation.below, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.col < oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.leftOf, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.col > oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.rightOf, targetId: oId, type: ClueType.cardinal));
      }
    }

    // 3. Otros Sospechosos (excluyendo a la víctima para evitar pistas indirectas)
    for (final other in caseData.suspects) {
      if (other.id == suspectId || other.id == caseData.victimId) continue;
      final oPos = sol[other.id]!;
      final oId = other.id;

      if (sPos.row == oPos.row) {
        list.add(SpatialConstraint(relation: SpatialRelation.sameRow, targetId: oId, type: ClueType.coLocation));
      }
      if (sPos.col == oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.sameColumn, targetId: oId, type: ClueType.coLocation));
      }

      final dist = (sPos.row - oPos.row).abs() + (sPos.col - oPos.col).abs();
      if (dist == 1) {
        list.add(SpatialConstraint(relation: SpatialRelation.adjacentTo, targetId: oId, type: ClueType.adjacency));
      }

      if (sPos.row < oPos.row) {
        list.add(SpatialConstraint(relation: SpatialRelation.above, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.row > oPos.row) {
        list.add(SpatialConstraint(relation: SpatialRelation.below, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.col < oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.leftOf, targetId: oId, type: ClueType.cardinal));
      }
      if (sPos.col > oPos.col) {
        list.add(SpatialConstraint(relation: SpatialRelation.rightOf, targetId: oId, type: ClueType.cardinal));
      }
    }

    return list;
  }
}
