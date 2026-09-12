import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  group('Pistas Generales como Operadores Activos de Deducción', () {
    const replay = HumanDeductionReplay();
    final solver = PuzzleSolver();

    // Caso de prueba base: 4x4 con 2 habitaciones (Izquierda y Derecha)
    // Habitación 1 (izq): cols 0, 1
    // Habitación 2 (der): cols 2, 3
    final zoneWest = ZoneData(
      id: 'room_west',
      name: 'Salón Oeste',
      cells: [
        for (int r = 0; r < 4; r++)
          for (int c = 0; c < 2; c++) CellPosition(r, c),
      ],
    );
    final zoneEast = ZoneData(
      id: 'room_east',
      name: 'Galería Este',
      cells: [
        for (int r = 0; r < 4; r++)
          for (int c = 2; c < 4; c++) CellPosition(r, c),
      ],
    );

    final suspects = [
      const SuspectData(id: 'suspect_a', name: 'Ana'),
      const SuspectData(id: 'suspect_b', name: 'Bruno'),
      const SuspectData(id: 'victim', name: 'Víctima'),
    ];

    // Objeto ubicado en Galería Este (r:0, c:2)
    final statue = PlacedObjectData(
      object: const ObjectData(id: 'statue', name: 'Estatua'),
      position: const CellPosition(0, 2),
    );

    // Ground Truth:
    // suspect_a (asesino) en (1, 2) [Galería Este]
    // victim en (2, 3) [Galería Este] (escena del crimen en Galería Este)
    // suspect_b (inocente) en (0, 1) [Salón Oeste]
    const solution = SolutionData(
      suspectPositions: {
        'suspect_a': CellPosition(1, 2),
        'suspect_b': CellPosition(0, 1),
        'victim': CellPosition(2, 3),
      },
    );

    final baseCase = CaseData(
      id: 'test_case_global_rules',
      title: 'Caso de Prueba Reglas Globales',
      description: 'Misterio de prueba para operadores globales.',
      boardRows: 4,
      boardColumns: 4,
      difficulty: PuzzleDifficulty.easy,
      suspects: suspects,
      zones: [zoneWest, zoneEast],
      placedObjects: [statue],
      clues: const [],
      solution: solution,
      killerId: 'suspect_a',
      victimId: 'victim',
    );

    test('Test 1 & Test 4: Regla general útil reduce dominio y registra DeductionSourceType.globalRule', () {
      const clueBruno = SpatialClueData(
        id: 'clue_b',
        suspectId: 'suspect_b',
        text: 'Bruno estaba en el Salón Oeste.',
        constraints: [
          SpatialConstraint(targetId: 'room_west', relation: SpatialRelation.inZone),
        ],
      );

      const clueAna = SpatialClueData(
        id: 'clue_a',
        suspectId: 'suspect_a',
        text: 'Ana estaba inmediatamente al sur de la estatua.',
        constraints: [
          SpatialConstraint(targetId: 'statue', relation: SpatialRelation.immediatelySouthOf),
        ],
      );

      final testCaseWithoutRule = baseCase.copyWith(
        clues: [clueAna, clueBruno],
        globalRules: const [],
      );

      final simBefore = replay.simulate(testCaseWithoutRule, [clueAna, clueBruno]);
      expect(simBefore.domainSizes['suspect_a'], equals(1)); // Ana fijada en (1,2)
      final victimBefore = simBefore.domainSizes['victim']!;
      expect(victimBefore, greaterThan(1));

      // Regla de ocupante único en Salón Oeste
      const singleOccupantRule = BoardRuleData(
        id: 'rule_single_west',
        type: BoardRuleType.singleOccupantZone,
        text: 'El Salón Oeste albergaba a una única persona durante la noche.',
        targetId: 'room_west',
      );

      final testCaseWithRule = baseCase.copyWith(
        clues: [clueAna, clueBruno],
        globalRules: [singleOccupantRule],
      );

      final simWithRule = replay.simulate(testCaseWithRule, [clueAna, clueBruno]);

      // Verificar que la regla redujo y registró el paso correctamente
      final victimSteps = simWithRule.trace.where(
        (s) => s.sourceType == DeductionSourceType.globalRule && s.entityId == 'victim',
      );
      expect(victimSteps.isNotEmpty, isTrue);
      expect(victimSteps.first.reductionAmount, greaterThan(0));
      expect(victimSteps.first.candidateCountBefore, greaterThan(victimSteps.first.candidateCountAfter));
    });

    test('Test 2: Regla general inútil (sin reducción) no genera pasos con reductionAmount <= 0', () {
      const clueAna = SpatialClueData(
        id: 'clue_a',
        suspectId: 'suspect_a',
        text: 'Ana estaba en (1,2).',
        constraints: [
          SpatialConstraint(targetId: 'statue', relation: SpatialRelation.immediatelySouthOf),
        ],
      );
      const clueBruno = SpatialClueData(
        id: 'clue_b',
        suspectId: 'suspect_b',
        text: 'Bruno estaba en (0,1).',
        constraints: [
          SpatialConstraint(targetId: 'statue', relation: SpatialRelation.immediatelyWestOf),
        ],
      );

      const redundantRule = BoardRuleData(
        id: 'rule_redundant',
        type: BoardRuleType.noEmptyRooms,
        text: 'Ninguna habitación quedó vacía.',
      );

      final caseWithRedundant = baseCase.copyWith(
        clues: [clueAna, clueBruno],
        globalRules: [redundantRule],
      );

      final sim = replay.simulate(caseWithRedundant, [clueAna, clueBruno]);
      final ruleSteps = sim.trace.where((s) => s.ruleId == 'rule_redundant');

      for (final step in ruleSteps) {
        expect(step.reductionAmount, greaterThan(0));
      }
    });

    test('Test 3 & Test 5: Replay registra sourceType: globalRule y cierra la zona de la víctima', () {
      const clueAna = SpatialClueData(
        id: 'clue_a',
        suspectId: 'suspect_a',
        text: 'Ana estaba inmediatamente al sur de la estatua.',
        constraints: [
          SpatialConstraint(targetId: 'statue', relation: SpatialRelation.immediatelySouthOf),
        ],
      );

      const crimeHasObjectRule = BoardRuleData(
        id: 'rule_crime_object',
        type: BoardRuleType.crimeSceneHasObject,
        text: 'La escena del crimen tuvo lugar en una habitación con mobiliario.',
      );

      final caseData = baseCase.copyWith(
        clues: [clueAna],
        globalRules: [crimeHasObjectRule],
      );

      final sim = replay.simulate(caseData, [clueAna]);

      final globalStep = sim.trace.firstWhere(
        (s) => s.sourceType == DeductionSourceType.globalRule && s.ruleId == 'rule_crime_object',
      );

      expect(globalStep, isNotNull);
      expect(globalStep.entityId, equals('victim'));
      expect(globalStep.reductionAmount, greaterThan(0));
      expect(globalStep.explanation, isNotNull);
    });

    test('Test 6: Doble validación Ground Truth (Solver == GT y HumanReplay == GT)', () {
      final chair = PlacedObjectData(
        object: const ObjectData(id: 'chair', name: 'Silla'),
        position: const CellPosition(3, 3),
      );

      const clueAna = SpatialClueData(
        id: 'clue_a',
        suspectId: 'suspect_a',
        text: 'Ana estaba inmediatamente al sur de la estatua.',
        constraints: [
          SpatialConstraint(targetId: 'statue', relation: SpatialRelation.immediatelySouthOf),
        ],
      );
      const clueBruno = SpatialClueData(
        id: 'clue_b',
        suspectId: 'suspect_b',
        text: 'Bruno estaba inmediatamente al oeste de la estatua.',
        constraints: [
          SpatialConstraint(targetId: 'statue', relation: SpatialRelation.immediatelyWestOf),
        ],
      );

      const crimeHasObjectRule = BoardRuleData(
        id: 'rule_crime_object',
        type: BoardRuleType.crimeSceneHasObject,
        text: 'La escena del crimen tuvo lugar en una habitación con mobiliario.',
      );

      final fullCase = baseCase.copyWith(
        placedObjects: [statue, chair],
        clues: [clueAna, clueBruno],
        globalRules: [crimeHasObjectRule],
      );

      // 1. Solver CSP
      final solverResult = solver.solve(fullCase);
      expect(solverResult.solutionCount, equals(1));
      expect(solverResult.solutions.first.suspectPositions, equals(solution.suspectPositions));

      // 2. Human Replay
      final replayResult = replay.simulate(fullCase, [clueAna, clueBruno]);
      expect(replayResult.solved, isTrue);
      expect(replayResult.requiresGuessing, isFalse);
      expect(replayResult.finalPositions, equals(solution.suspectPositions));
      expect(replayResult.deducedKillerId, equals('suspect_a'));
    });
  });
}
