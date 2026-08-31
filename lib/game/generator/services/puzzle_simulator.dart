import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Representa un paso formal de deducción en la simulación humana.
class DeductionStep {
  const DeductionStep({
    required this.stepNumber,
    required this.entityId,
    required this.candidateCountBefore,
    required this.candidateCountAfter,
    required this.reason,
  });

  final int stepNumber;
  final String entityId;
  final int candidateCountBefore;
  final int candidateCountAfter;
  final String reason;

  @override
  String toString() =>
      'Paso $stepNumber: $entityId ($candidateCountBefore -> $candidateCountAfter) [$reason]';
}

/// Resultado exhaustivo de la simulación deductiva humana.
class PuzzleSimulationResult {
  const PuzzleSimulationResult({
    required this.solved,
    required this.domainSizes,
    required this.steps,
    required this.stuck,
    required this.requiresGuessing,
    required this.trace,
    required this.ambiguousEntities,
    this.finalPositions = const {},
    this.killerDeductionUnique = false,
    this.deducedKillerId,
    this.victimSolvedByExhaustion = false,
    this.victimCandidateRooms = 0,
    this.victimCandidateCells = 0,
  });

  /// Indica si el caso fue resuelto completamente por deducción humana sin branching.
  final bool solved;

  /// Cantidad de celdas candidatas finales para cada sospechoso y la víctima.
  final Map<String, int> domainSizes;

  /// Cantidad de ciclos o pasos de razonamiento empleados.
  final int steps;

  /// Verdadero si el razonamiento se estancó antes de determinar a todas las entidades.
  final bool stuck;

  /// Verdadero si se requirió probar hipótesis / adivinar para avanzar.
  final bool requiresGuessing;

  /// Traza detallada paso a paso de cada reducción de dominio.
  final List<DeductionStep> trace;

  /// Entidades que quedaron con > 1 candidato al finalizar la simulación.
  final List<String> ambiguousEntities;

  /// Posiciones finales resueltas para cada entidad (solo si solved == true).
  final Map<String, CellPosition> finalPositions;

  /// Verdadero si el asesino pudo ser deducido unívocamente en la zona de la víctima.
  final bool killerDeductionUnique;

  /// ID del asesino deducido lógicamente al final.
  final String? deducedKillerId;

  /// Verdadero si la víctima fue deducida por agotamiento espacial sin pistas directas.
  final bool victimSolvedByExhaustion;

  /// Zonas candidatas para la víctima al finalizar la simulación.
  final int victimCandidateRooms;

  /// Celdas candidatas para la víctima al finalizar la simulación.
  final int victimCandidateCells;
}

/// Simula rigurosamente el razonamiento deductivo humano para resolver el puzzle
/// basándose exclusivamente en restricciones visibles (Murdoku, Zonas, Pistas y Reglas de Tablero),
/// SIN utilizar conocimiento oculto (como el killerId o la posición de la solución).
class PuzzleSimulator {
  const PuzzleSimulator([this._evaluator = const SpatialClueEvaluator()]);

  final SpatialClueEvaluator _evaluator;

  PuzzleSimulationResult simulate(CaseData data, List<SpatialClueData> cluesToUse) {
    final domains = <String, Set<CellPosition>>{};
    final allCells = <CellPosition>[];
    final trace = <DeductionStep>[];
    int stepCounter = 1;

    final blocked = data.placedObjects.map((o) => o.position).toSet();
    for (int r = 0; r < data.boardRows; r++) {
      for (int c = 0; c < data.boardColumns; c++) {
        final pos = CellPosition(r, c);
        if (!blocked.contains(pos)) {
          allCells.add(pos);
        }
      }
    }

    // Inicializar dominios completos para todos los sospechosos y la víctima
    for (final s in data.suspects) {
      domains[s.id] = Set.from(allCells);
    }

    final zoneMap = <CellPosition, String>{};
    for (final z in data.zones) {
      for (final c in z.cells) {
        zoneMap[c] = z.id;
      }
    }

    final objectMap = <String, CellPosition>{};
    for (final po in data.placedObjects) {
      objectMap[po.object.id] = po.position;
    }

    bool changed = true;
    int loopCycles = 0;

    while (changed) {
      changed = false;
      loopCycles++;

      if (domains.values.any((d) => d.isEmpty)) {
        return PuzzleSimulationResult(
          solved: false,
          domainSizes: {for (final e in domains.entries) e.key: e.value.length},
          steps: loopCycles,
          stuck: true,
          requiresGuessing: true,
          trace: trace,
          ambiguousEntities: domains.keys.toList(),
        );
      }

      // =========================================================================
      // 1. REGLA MURDOKU BÁSICA: Si una entidad está fija en (r, c),
      // ninguna otra entidad puede ocupar (r, c), ni la fila r, ni la columna c.
      // =========================================================================
      final lockedEntries = domains.entries.where((e) => e.value.length == 1).toList();
      for (final locked in lockedEntries) {
        if (locked.value.isEmpty) continue;
        final lockedPos = locked.value.first;
        for (final other in domains.keys) {
          if (other == locked.key) continue;
          final domain = domains[other]!;
          final before = domain.length;
          domain.removeWhere((p) => p.row == lockedPos.row || p.col == lockedPos.col);
          if (domain.length < before) {
            changed = true;
            trace.add(DeductionStep(
              stepNumber: stepCounter++,
              entityId: other,
              candidateCountBefore: before,
              candidateCountAfter: domain.length,
              reason: 'Exclusión Murdoku por posición fijada de ${locked.key} en (${lockedPos.row}, ${lockedPos.col})',
            ));
          }
        }
      }

      // =========================================================================
      // 2. EXCLUSIÓN DE LÍNEAS COMPLETAS: Si TODOS los candidatos de una entidad
      // están en la misma fila r (o columna c), ninguna OTRA entidad puede estar en esa fila r (o col c).
      // =========================================================================
      for (final entry in domains.entries) {
        if (entry.value.isEmpty) continue;
        final uniqueRows = entry.value.map((p) => p.row).toSet();
        if (uniqueRows.length == 1) {
          final fixedRow = uniqueRows.first;
          for (final other in domains.keys) {
            if (other == entry.key) continue;
            final otherDomain = domains[other]!;
            final before = otherDomain.length;
            otherDomain.removeWhere((p) => p.row == fixedRow);
            if (otherDomain.length < before) {
              changed = true;
              trace.add(DeductionStep(
                stepNumber: stepCounter++,
                entityId: other,
                candidateCountBefore: before,
                candidateCountAfter: otherDomain.length,
                reason: 'Exclusión de fila $fixedRow porque ${entry.key} está forzada en esa fila',
              ));
            }
          }
        }

        final uniqueCols = entry.value.map((p) => p.col).toSet();
        if (uniqueCols.length == 1) {
          final fixedCol = uniqueCols.first;
          for (final other in domains.keys) {
            if (other == entry.key) continue;
            final otherDomain = domains[other]!;
            final before = otherDomain.length;
            otherDomain.removeWhere((p) => p.col == fixedCol);
            if (otherDomain.length < before) {
              changed = true;
              trace.add(DeductionStep(
                stepNumber: stepCounter++,
                entityId: other,
                candidateCountBefore: before,
                candidateCountAfter: otherDomain.length,
                reason: 'Exclusión de columna $fixedCol porque ${entry.key} está forzada en esa columna',
              ));
            }
          }
        }
      }

      // =========================================================================
      // 3. PROPAGACIÓN DE PISTAS (Arc-Consistency AC-3 para Tarjetas Compuestas)
      // =========================================================================
      for (final clue in cluesToUse) {
        if (clue.isVictimCard) continue; // La víctima no tiene pistas posicionales directas

        final subjDomain = domains[clue.suspectId];
        if (subjDomain == null || subjDomain.isEmpty) continue;

        final constraints = clue.activeConstraints;
        if (constraints.isEmpty) continue;

        final beforeSubj = subjDomain.length;

        // Cada candidato del sujeto debe satisfacer TODAS las restricciones de la tarjeta (Conjunción)
        subjDomain.retainWhere((sPos) {
          return constraints.every((constraint) {
            return _evaluateConstraint(
              sPos: sPos,
              constraint: constraint,
              domains: domains,
              objectMap: objectMap,
              zoneMap: zoneMap,
            );
          });
        });

        if (subjDomain.length < beforeSubj) {
          changed = true;
          trace.add(DeductionStep(
            stepNumber: stepCounter++,
            entityId: clue.suspectId,
            candidateCountBefore: beforeSubj,
            candidateCountAfter: subjDomain.length,
            reason: 'Tarjeta de Pista: ${clue.text.isNotEmpty ? clue.text : clue.id}',
          ));
        }

        // Propagación simétrica sobre objetivos que sean sospechosos
        for (final constraint in constraints) {
          if (!objectMap.containsKey(constraint.targetId) &&
              !data.zones.any((z) => z.id == constraint.targetId) &&
              domains.containsKey(constraint.targetId)) {
            final targetDomain = domains[constraint.targetId]!;
            final beforeTarget = targetDomain.length;

            targetDomain.retainWhere((tPos) {
              return subjDomain.any((sPos) {
                if (sPos.row == tPos.row || sPos.col == tPos.col) {
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
            });

            if (targetDomain.length < beforeTarget) {
              changed = true;
              trace.add(DeductionStep(
                stepNumber: stepCounter++,
                entityId: constraint.targetId,
                candidateCountBefore: beforeTarget,
                candidateCountAfter: targetDomain.length,
                reason: 'Propagación simétrica con ${clue.suspectId}',
              ));
            }
          }
        }
      }

      // =========================================================================
      // 4. DEDUCCIÓN DE LA ZONA DE LA VÍCTIMA (Regla de Asesinato Legítima):
      // Si una zona ya tiene >= 2 sospechosos fijados, la víctima NO puede estar allí.
      // =========================================================================
      final victimDomain = domains[data.victimId];
      if (victimDomain != null && victimDomain.isNotEmpty) {
        final zoneSuspectCount = <String, int>{};
        for (final entry in domains.entries) {
          if (entry.key == data.victimId) continue;
          if (entry.value.length == 1) {
            final z = zoneMap[entry.value.first];
            if (z != null) {
              zoneSuspectCount[z] = (zoneSuspectCount[z] ?? 0) + 1;
            }
          }
        }

        for (final entry in zoneSuspectCount.entries) {
          if (entry.value >= 2) {
            final before = victimDomain.length;
            victimDomain.removeWhere((p) => zoneMap[p] == entry.key);
            if (victimDomain.length < before) {
              changed = true;
              trace.add(DeductionStep(
                stepNumber: stepCounter++,
                entityId: data.victimId,
                candidateCountBefore: before,
                candidateCountAfter: victimDomain.length,
                reason: 'Regla de Asesinato: Zona ${entry.key} tiene ${entry.value} sospechosos fijados (máximo 1)',
              ));
            }
          }
        }

        // Si una zona tiene 0 sospechosos posibles, la víctima NO puede estar allí (debe haber un asesino con ella).
        final allZonesWithSuspects = <String>{};
        for (final entry in domains.entries) {
          if (entry.key == data.victimId) continue;
          for (final pos in entry.value) {
            final z = zoneMap[pos];
            if (z != null) allZonesWithSuspects.add(z);
          }
        }

        final beforeVictim = victimDomain.length;
        victimDomain.removeWhere((p) => !allZonesWithSuspects.contains(zoneMap[p]));
        if (victimDomain.length < beforeVictim) {
          changed = true;
          trace.add(DeductionStep(
            stepNumber: stepCounter++,
            entityId: data.victimId,
            candidateCountBefore: beforeVictim,
            candidateCountAfter: victimDomain.length,
            reason: 'Regla de Asesinato: La víctima debe estar en una zona con al menos un sospechoso (el asesino)',
          ));
        }
      }

      // =========================================================================
      // 5. EVALUACIÓN DE REGLAS GLOBALES DEL ESCENARIO (BoardRuleData)
      // =========================================================================
      final zonesWithObjects = data.placedObjects.map((po) => zoneMap[po.position]).where((z) => z != null).toSet();

      for (final rule in data.globalRules) {
        switch (rule.type) {
          case BoardRuleType.maxOnePersonPerRoomExceptCrime:
            final lockedSuspectsByZone = <String, List<String>>{};
            for (final entry in domains.entries) {
              if (entry.key == data.victimId) continue;
              if (entry.value.length == 1) {
                final z = zoneMap[entry.value.first];
                if (z != null) {
                  lockedSuspectsByZone.putIfAbsent(z, () => []).add(entry.key);
                }
              }
            }
            for (final entry in lockedSuspectsByZone.entries) {
              final zId = entry.key;
              final fixedSuspect = entry.value.first;
              for (final other in domains.keys) {
                if (other == data.victimId || other == fixedSuspect) continue;
                final otherDomain = domains[other]!;
                final beforeOther = otherDomain.length;
                otherDomain.removeWhere((p) => zoneMap[p] == zId);
                if (otherDomain.length < beforeOther) {
                  changed = true;
                  trace.add(DeductionStep(
                    stepNumber: stepCounter++,
                    entityId: other,
                    candidateCountBefore: beforeOther,
                    candidateCountAfter: otherDomain.length,
                    reason: 'Regla Global Ocupación: ${rule.text}',
                  ));
                }
              }
            }
            break;

          case BoardRuleType.noEmptyRooms:
            // Si una zona no tiene candidatos de sospechosos, la víctima debe estar allí (con el asesino)
            final allSuspectZones = <String>{};
            for (final entry in domains.entries) {
              if (entry.key == data.victimId) continue;
              for (final p in entry.value) {
                final z = zoneMap[p];
                if (z != null) allSuspectZones.add(z);
              }
            }
            final emptyZones = data.zones.map((z) => z.id).where((zId) => !allSuspectZones.contains(zId)).toSet();
            if (emptyZones.isNotEmpty && victimDomain != null && victimDomain.isNotEmpty) {
              final before = victimDomain.length;
              victimDomain.retainWhere((p) => emptyZones.contains(zoneMap[p]));
              if (victimDomain.length < before) {
                changed = true;
                trace.add(DeductionStep(
                  stepNumber: stepCounter++,
                  entityId: data.victimId,
                  candidateCountBefore: before,
                  candidateCountAfter: victimDomain.length,
                  reason: 'Regla Global: ${rule.text}',
                ));
              }
            }
            break;

          case BoardRuleType.singleOccupantZone:
            if (rule.targetId != null && victimDomain != null && victimDomain.isNotEmpty) {
              final before = victimDomain.length;
              victimDomain.removeWhere((p) => zoneMap[p] == rule.targetId);
              if (victimDomain.length < before) {
                changed = true;
                trace.add(DeductionStep(
                  stepNumber: stepCounter++,
                  entityId: data.victimId,
                  candidateCountBefore: before,
                  candidateCountAfter: victimDomain.length,
                  reason: 'Regla Global (Zona de Ocupante Único): ${rule.text}',
                ));
              }
            }
            break;

          case BoardRuleType.crimeSceneHasObject:
            if (victimDomain != null && victimDomain.isNotEmpty) {
              final before = victimDomain.length;
              victimDomain.removeWhere((p) => !zonesWithObjects.contains(zoneMap[p]));
              if (victimDomain.length < before) {
                changed = true;
                trace.add(DeductionStep(
                  stepNumber: stepCounter++,
                  entityId: data.victimId,
                  candidateCountBefore: before,
                  candidateCountAfter: victimDomain.length,
                  reason: 'Regla Global Escenario: ${rule.text}',
                ));
              }
            }
            break;

          case BoardRuleType.crimeSceneHasNoObject:
            if (victimDomain != null && victimDomain.isNotEmpty) {
              final before = victimDomain.length;
              victimDomain.removeWhere((p) => zonesWithObjects.contains(zoneMap[p]));
              if (victimDomain.length < before) {
                changed = true;
                trace.add(DeductionStep(
                  stepNumber: stepCounter++,
                  entityId: data.victimId,
                  candidateCountBefore: before,
                  candidateCountAfter: victimDomain.length,
                  reason: 'Regla Global Escenario: ${rule.text}',
                ));
              }
            }
            break;
        }
      }
    }

    // =========================================================================
    // EVALUACIÓN FINAL DE DETERMINACIÓN EXACTA (CERO GRADOS DE LIBERTAD)
    // =========================================================================
    final domainSizes = {for (final e in domains.entries) e.key: e.value.length};
    final ambiguous = domains.entries.where((e) => e.value.length != 1).map((e) => e.key).toList();
    final isEveryEntityDetermined = ambiguous.isEmpty && domainSizes.values.every((v) => v == 1);

    final finalPositions = <String, CellPosition>{};
    if (isEveryEntityDetermined) {
      for (final e in domains.entries) {
        finalPositions[e.key] = e.value.first;
      }
    }

    bool killerUnique = false;
    String? deducedKiller;

    // Deducción del asesino: Una vez resuelto el tablero, se examina la zona de la víctima
    if (isEveryEntityDetermined && finalPositions.containsKey(data.victimId)) {
      final victimPos = finalPositions[data.victimId]!;
      final victimZone = zoneMap[victimPos];

      final suspectsInVictimZone = finalPositions.entries
          .where((e) => e.key != data.victimId && zoneMap[e.value] == victimZone)
          .map((e) => e.key)
          .toList();

      if (suspectsInVictimZone.length == 1) {
        killerUnique = true;
        deducedKiller = suspectsInVictimZone.first;
      }
    }

    int vRooms = 0;
    int vCells = 0;
    final finalVictimDomain = domains[data.victimId];
    if (finalVictimDomain != null) {
      vCells = finalVictimDomain.length;
      final uniqueZones = finalVictimDomain.map((p) => zoneMap[p]).where((z) => z != null).toSet();
      vRooms = uniqueZones.length;
    }

    final victimClues = cluesToUse.where((c) => c.suspectId == data.victimId && !c.isVictimCard);
    final victimSolvedByExhaustion = isEveryEntityDetermined && victimClues.isEmpty;

    return PuzzleSimulationResult(
      solved: isEveryEntityDetermined && killerUnique,
      domainSizes: domainSizes,
      steps: loopCycles,
      stuck: !isEveryEntityDetermined || !killerUnique,
      requiresGuessing: !isEveryEntityDetermined,
      trace: trace,
      ambiguousEntities: ambiguous,
      finalPositions: finalPositions,
      killerDeductionUnique: killerUnique,
      deducedKillerId: deducedKiller,
      victimSolvedByExhaustion: victimSolvedByExhaustion,
      victimCandidateRooms: vRooms,
      victimCandidateCells: vCells,
    );
  }

  bool _evaluateConstraint({
    required CellPosition sPos,
    required SpatialConstraint constraint,
    required Map<String, Set<CellPosition>> domains,
    required Map<String, CellPosition> objectMap,
    required Map<CellPosition, String> zoneMap,
  }) {
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
