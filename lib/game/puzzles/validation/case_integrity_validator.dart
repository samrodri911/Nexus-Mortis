import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/generator/services/clue_text_formatter.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/utils/zone_validator.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_rejection_reason.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_validation_result.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

/// Validador riguroso de integridad formal, referencial y deductiva para [CaseData].
class CaseIntegrityValidator {
  CaseIntegrityValidator({
    PuzzleSolver? solver,
    HumanDeductionReplay? simulator,
  })  : _solver = solver ?? PuzzleSolver(),
        _simulator = simulator ?? const HumanDeductionReplay();

  final PuzzleSolver _solver;
  final HumanDeductionReplay _simulator;

  /// Valida la integridad estructural, lógica y deductiva de un [CaseData].
  bool validate(CaseData caseData) => validateDetailed(caseData).isValid;

  /// Ejecuta la autorrevisión pre-entrega completa y devuelve un [CaseValidationResult]
  /// con el motivo formal de rechazo en caso de no ser apto para el jugador.
  CaseValidationResult validateDetailed(CaseData caseData) {
    // 1. Dimensiones y metadatos básicos
    if (caseData.boardRows <= 0 || caseData.boardColumns <= 0) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidDimensions,
        details: 'Dimensiones inválidas (${caseData.boardRows}x${caseData.boardColumns})',
      );
    }
    if (caseData.title.trim().isEmpty) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidDimensions,
        details: 'Título del caso vacío',
      );
    }

    // 2. Sospechosos y roles
    if (caseData.suspects.length < 2) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidSuspects,
        details: 'Menos de 2 sospechosos (${caseData.suspects.length})',
      );
    }
    if (caseData.suspects.length > caseData.boardRows ||
        caseData.suspects.length > caseData.boardColumns) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidSuspects,
        details: 'Cantidad de sospechosos (${caseData.suspects.length}) excede dimensiones del tablero (${caseData.boardRows}x${caseData.boardColumns})',
      );
    }

    final suspectIds = caseData.suspects.map((s) => s.id).toSet();
    if (!suspectIds.contains(caseData.victimId)) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidSuspects,
        details: 'victimId "${caseData.victimId}" no está en la lista de sospechosos',
      );
    }
    if (!suspectIds.contains(caseData.killerId)) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidSuspects,
        details: 'killerId "${caseData.killerId}" no está en la lista de sospechosos',
      );
    }
    if (caseData.victimId == caseData.killerId) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidSuspects,
        details: 'La víctima no puede ser su propio asesino',
      );
    }

    // 3. Zonas (Layout y celdas válidas)
    if (!ZoneValidator.validateZones(
      caseData.boardRows,
      caseData.boardColumns,
      caseData.zones,
    )) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidZoneLayout,
        details: 'Las zonas no cubren válidamente la cuadrícula',
      );
    }

    final zoneIds = <String>{};
    final zoneNames = <String>{};
    final zoneMap = <CellPosition, ZoneData>{};
    for (final z in caseData.zones) {
      if (z.id.trim().isEmpty) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidZoneLayout,
          details: 'Zona con ID vacío',
        );
      }
      if (!zoneIds.add(z.id)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidZoneLayout,
          details: 'ID de zona duplicado "${z.id}"',
        );
      }
      final name = z.name?.trim() ?? '';
      if (name.isEmpty) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidZoneLayout,
          details: 'Zona "${z.id}" tiene nombre vacío',
        );
      }
      zoneNames.add(name.toLowerCase());
      for (final c in z.cells) {
        zoneMap[c] = z;
      }
    }

    // 4. Objetos colocados
    final objectPositions = <CellPosition>{};
    final objectIds = <String>{};
    final objectNames = <String>{};
    for (final placed in caseData.placedObjects) {
      if (placed.object.id.trim().isEmpty) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidObjectReference,
          details: 'Objeto con ID vacío',
        );
      }
      if (!objectIds.add(placed.object.id)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidObjectReference,
          details: 'ID de objeto duplicado "${placed.object.id}"',
        );
      }
      final oName = placed.object.name.trim();
      if (oName.isEmpty) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidObjectReference,
          details: 'Objeto "${placed.object.id}" tiene nombre vacío',
        );
      }
      objectNames.add(oName.toLowerCase());

      final pos = placed.position;
      if (pos.row < 0 || pos.row >= caseData.boardRows || pos.col < 0 || pos.col >= caseData.boardColumns) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.objectOutOfBounds,
          details: 'Objeto "${placed.object.name}" en posición fuera del tablero $pos',
        );
      }
      if (!objectPositions.add(pos)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.overlappingObjects,
          details: 'Objetos superpuestos en la celda $pos',
        );
      }
    }

    // 5. Solución y Escena del Crimen
    final sol = caseData.solution.suspectPositions;
    if (sol.length != caseData.suspects.length) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.nonUniqueSolution,
        details: 'La solución contiene ${sol.length} posiciones para ${caseData.suspects.length} sospechosos',
      );
    }

    final usedRows = <int>{};
    final usedCols = <int>{};

    for (final entry in sol.entries) {
      final sId = entry.key;
      final pos = entry.value;

      if (!suspectIds.contains(sId)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidSuspects,
          details: 'Entidad desconocida "$sId" en la solución',
        );
      }
      if (pos.row < 0 || pos.row >= caseData.boardRows || pos.col < 0 || pos.col >= caseData.boardColumns) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidDimensions,
          details: 'Sospechoso "$sId" posicionado fuera del tablero en $pos',
        );
      }
      if (objectPositions.contains(pos)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.overlappingObjects,
          details: 'Sospechoso "$sId" colisiona con un objeto en $pos',
        );
      }

      // Regla Murdoku: Filas y columnas únicas
      if (!usedRows.add(pos.row) || !usedCols.add(pos.col)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.nonUniqueSolution,
          details: 'Violación de unicidad de fila/columna Murdoku en $pos',
        );
      }
    }

    // Regla de Asesinato Inquebrantable:
    // Asesino y víctima comparten zona. Ocupantes de la zona del crimen == EXACTAMENTE 2.
    final victimPos = sol[caseData.victimId];
    final killerPos = sol[caseData.killerId];
    if (victimPos == null || killerPos == null) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimWithoutKiller,
        details: 'Víctima o asesino sin posición asignada en la solución',
      );
    }

    final victimZone = zoneMap[victimPos];
    final killerZone = zoneMap[killerPos];
    if (victimZone == null || killerZone == null || victimZone.id != killerZone.id) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimWithoutKiller,
        details: 'La víctima (zona "${victimZone?.id}") y el asesino (zona "${killerZone?.id}") no comparten habitación',
      );
    }

    final occupantsInCrimeZone = <String>[];
    for (final entry in sol.entries) {
      final sZone = zoneMap[entry.value];
      if (sZone?.id == victimZone.id) {
        occupantsInCrimeZone.add(entry.key);
      }
    }

    if (occupantsInCrimeZone.length != 2) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.crimeSceneThirdOccupant,
        details: 'La escena del crimen tiene ${occupantsInCrimeZone.length} ocupantes (${occupantsInCrimeZone.join(", ")}); debe tener exactamente 2',
      );
    }

    if (!occupantsInCrimeZone.contains(caseData.victimId) || !occupantsInCrimeZone.contains(caseData.killerId)) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.innocentInCrimeScene,
        details: 'La escena del crimen contiene sospechosos que no son víctima y asesino',
      );
    }

    // 6. Tarjeta Canónica de la Víctima
    final victimClue = caseData.clues.where((c) => c.suspectId == caseData.victimId).toList();
    if (victimClue.isEmpty) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimCardInvalid,
        details: 'Falta la tarjeta de la víctima en el conjunto de pistas',
      );
    }
    if (victimClue.length > 1) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimCardInvalid,
        details: 'Múltiples tarjetas asignadas a la víctima',
      );
    }
    if (victimClue.first.text.trim() != ClueTextFormatter.canonicalVictimText) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimCardInvalid,
        details: 'Texto de la víctima no canónico: "${victimClue.first.text}"',
      );
    }
    if (victimClue.first.constraints.isNotEmpty) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimCardInvalid,
        details: 'La tarjeta de la víctima contiene restricciones espaciales directas',
      );
    }

    // 7. Pistas e Integridad Referencial
    if (caseData.clues.isEmpty) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.invalidSuspects,
        details: 'Conjunto de pistas vacío',
      );
    }

    final validTargets = {...suspectIds, ...objectIds, ...zoneIds};

    for (final clue in caseData.clues) {
      if (!suspectIds.contains(clue.suspectId)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidSuspects,
          details: 'Pista asignada a un sospechoso inexistente "${clue.suspectId}"',
        );
      }
      if (clue.text.trim().isEmpty) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidSuspects,
          details: 'Texto de pista vacío para "${clue.suspectId}"',
        );
      }
      // Prohibir IDs técnicos crudos en texto visible
      if (clue.text.contains('suspect_') || clue.text.contains('obj_') || clue.text.contains('z_') || clue.text.contains('z1') || clue.text.contains('z2')) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.invalidSuspects,
          details: 'Pista contiene identificadores técnicos crudos en el texto visible: "${clue.text}"',
        );
      }

      for (final constraint in clue.activeConstraints) {
        if (!validTargets.contains(constraint.targetId)) {
          if (constraint.type == ClueType.zone || constraint.relation == SpatialRelation.inZone || constraint.relation == SpatialRelation.notInZone) {
            return CaseValidationResult.rejected(
              CaseRejectionReason.invalidZoneReference,
              details: 'Restricción referencia zona inexistente "${constraint.targetId}"',
            );
          } else {
            return CaseValidationResult.rejected(
              CaseRejectionReason.invalidObjectReference,
              details: 'Restricción referencia objetivo inexistente "${constraint.targetId}"',
            );
          }
        }
        if (clue.suspectId == constraint.targetId) {
          return CaseValidationResult.rejected(
            CaseRejectionReason.invalidSuspects,
            details: 'Sospechoso se referencia a sí mismo en una restricción',
          );
        }
      }
    }

    // Reglas Globales (Máximo 1 y estructuralmente válidas)
    if (caseData.globalRules.length > 1) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.globalRuleTooMany,
        details: 'Se permiten como máximo 1 regla global (${caseData.globalRules.length} presentes)',
      );
    }
    for (final rule in caseData.globalRules) {
      if (rule.targetId != null && !zoneIds.contains(rule.targetId)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.globalRuleInvalidTarget,
          details: 'Regla global referencia zona inexistente "${rule.targetId}"',
        );
      }
    }

    // 8. Determinación Deductiva Humana (CERO Grados de Libertad y CERO Guessing)
    final simResult = _simulator.simulate(caseData, caseData.clues);
    if (!simResult.solved || simResult.stuck) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.suspectAmbiguous,
        details: 'La simulación humana quedó estancada o no resolvió todas las entidades',
      );
    }
    if (simResult.requiresGuessing) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.requiresGuessing,
        details: 'La deducción humana requirió adivinación / branching',
      );
    }

    // Nivel B: HumanReplay == GroundTruth
    for (final suspect in caseData.suspects) {
      final replayPos = simResult.finalPositions[suspect.id];
      final groundTruthPos = caseData.solution.suspectPositions[suspect.id];
      if (replayPos != groundTruthPos) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.suspectAmbiguous,
          details: 'La solución deducida para ${suspect.id} ($replayPos) no coincide con el Ground Truth ($groundTruthPos)',
        );
      }
    }

    if (!simResult.killerDeductionUnique || simResult.deducedKillerId != caseData.killerId) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.killerDeductionFailed,
        details: 'La deducción del asesino falló o dedujo a "${simResult.deducedKillerId}" en lugar de "${caseData.killerId}"',
      );
    }
    if (simResult.domainSizes.values.any((count) => count != 1)) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.suspectAmbiguous,
        details: 'Uno o más sospechosos terminaron con más de 1 celda candidata: ${simResult.domainSizes}',
      );
    }
    if (simResult.victimCandidateCells != 1 || simResult.victimCandidateRooms != 1) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.victimAmbiguous,
        details: 'La víctima terminó con ${simResult.victimCandidateCells} celdas en ${simResult.victimCandidateRooms} habitaciones',
      );
    }

    // 9. Necesidad de la Regla Global (No redundancia)
    if (caseData.globalRules.isNotEmpty) {
      final baseSim = _simulator.simulate(caseData.copyWith(globalRules: const []), caseData.clues);
      if (baseSim.solved && !baseSim.requiresGuessing && baseSim.domainSizes.values.every((v) => v == 1)) {
        return CaseValidationResult.rejected(
          CaseRejectionReason.globalRuleRedundant,
          details: 'La regla global es redundante porque el caso ya se cerraba determinísticamente a 1 sin ella',
        );
      }
    }

    // 10. Unicidad Matemática mediante PuzzleSolver (Nivel A)
    final solverResult = _solver.solve(caseData, maxSolutions: 2);
    if (solverResult.solutionCount != 1) {
      return CaseValidationResult.rejected(
        CaseRejectionReason.nonUniqueSolution,
        details: 'El solver encontró ${solverResult.solutionCount} soluciones matemáticas (requerido: 1)',
      );
    }

    // Nivel A: SolverSolution == GroundTruth
    for (final suspect in caseData.suspects) {
      final solverPos = solverResult.solutions.first.suspectPositions[suspect.id];
      final groundTruthPos = caseData.solution.suspectPositions[suspect.id];
      if (solverPos != groundTruthPos) {
         return CaseValidationResult.rejected(
          CaseRejectionReason.suspectAmbiguous,
          details: 'La solución matemática para ${suspect.id} ($solverPos) no coincide con el Ground Truth ($groundTruthPos)',
        );
      }
    }

    return CaseValidationResult.valid();
  }
}
