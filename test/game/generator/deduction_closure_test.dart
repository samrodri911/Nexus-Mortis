import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_quality_evaluator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  const simulator = PuzzleSimulator();
  const evaluator = PuzzleQualityEvaluator(simulator);
  final solver = PuzzleSolver();
  final validator = CaseIntegrityValidator(solver: solver, simulator: simulator);

  group('Nexus Mortis — Deduction Closure & Quality Invariants Tests', () {
    test('Test 1 (Eje Incompleto - Regresión Juan): Pista de 1 solo eje con 2 candidatos es rechazada', () {
      const s1 = SuspectData(id: 's1', name: 'Juan');
      const victim = SuspectData(id: 'victim', name: 'Víctima');
      const objLibrero = ObjectData(id: 'obj_librero', name: 'Librero');

      final juanCase = CaseData(
        id: 'test_juan',
        title: 'Juan Eje Incompleto',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 6,
        boardColumns: 6,
        zones: const [
          ZoneData(id: 'z_rosa', cells: [
            CellPosition(4, 4), CellPosition(5, 4),
          ]),
          ZoneData(id: 'z_other', cells: [
            CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2), CellPosition(0, 3), CellPosition(0, 4), CellPosition(0, 5),
            CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2), CellPosition(1, 3), CellPosition(1, 4), CellPosition(1, 5),
            CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2), CellPosition(2, 3), CellPosition(2, 4), CellPosition(2, 5),
            CellPosition(3, 0), CellPosition(3, 1), CellPosition(3, 2), CellPosition(3, 3), CellPosition(3, 4), CellPosition(3, 5),
            CellPosition(4, 0), CellPosition(4, 1), CellPosition(4, 2), CellPosition(4, 3), CellPosition(4, 5),
            CellPosition(5, 0), CellPosition(5, 1), CellPosition(5, 2), CellPosition(5, 3), CellPosition(5, 5),
          ]),
        ],
        suspects: const [s1, victim],
        victimId: 'victim',
        killerId: 's1',
        placedObjects: const [
          PlacedObjectData(object: objLibrero, position: CellPosition(1, 4)),
        ],
        clues: const [
          SpatialClueData(
            id: 'c_juan',
            suspectId: 's1',
            text: 'Juan estaba en la zona Rosa, en la misma columna que el Librero.',
            constraints: [
              SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_rosa', type: ClueType.zone),
              SpatialConstraint(relation: SpatialRelation.sameColumn, targetId: 'obj_librero', type: ClueType.coLocation),
            ],
          ),
          SpatialClueData(
            id: 'c_victim',
            suspectId: 'victim',
            text: 'La víctima. Estaba a solas con el asesino.',
            constraints: [],
          ),
        ],
        solution: const SolutionData(suspectPositions: {
          's1': CellPosition(4, 4),
          'victim': CellPosition(5, 4),
        }),
      );

      final simResult = simulator.simulate(juanCase, juanCase.clues);
      expect(simResult.domainSizes['s1'], equals(2));
      expect(evaluator.isAcceptable(juanCase, juanCase.clues), isFalse);
    });

    test('Test 2 (Doble Anclaje Real): Cruce de restricciones produce exactamente 1 celda inicial', () {
      const s1 = SuspectData(id: 's1', name: 'Carlos');
      const victim = SuspectData(id: 'victim', name: 'Víctima');
      const objArmario = ObjectData(id: 'obj_armario', name: 'Armario');

      final caseDualAnchor = CaseData(
        id: 'test_dual_anchor',
        title: 'Caso Doble Anclaje',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 4,
        boardColumns: 4,
        zones: const [
          ZoneData(id: 'z_cian', cells: [
            CellPosition(1, 1), CellPosition(1, 2),
            CellPosition(2, 1), CellPosition(2, 2),
          ]),
          ZoneData(id: 'z_otra', cells: [
            CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2), CellPosition(0, 3),
            CellPosition(1, 0), CellPosition(1, 3), CellPosition(2, 0), CellPosition(2, 3),
            CellPosition(3, 0), CellPosition(3, 1), CellPosition(3, 2), CellPosition(3, 3),
          ]),
        ],
        suspects: const [s1, victim],
        victimId: 'victim',
        killerId: 's1',
        placedObjects: const [
          PlacedObjectData(object: objArmario, position: CellPosition(1, 2)),
        ],
        clues: const [
          SpatialClueData(
            id: 'c_carlos',
            suspectId: 's1',
            text: 'Carlos estaba en la Zona Cian, inmediatamente al oeste del Armario.',
            constraints: [
              SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_cian', type: ClueType.zone),
              SpatialConstraint(relation: SpatialRelation.immediatelyWestOf, targetId: 'obj_armario', type: ClueType.cardinal),
            ],
          ),
          SpatialClueData(
            id: 'c_victim',
            suspectId: 'victim',
            text: 'La víctima. Estaba a solas con el asesino.',
            constraints: [],
          ),
        ],
        solution: const SolutionData(suspectPositions: {
          's1': CellPosition(1, 1),
          'victim': CellPosition(2, 2),
        }),
      );

      final simResult = simulator.simulate(caseDualAnchor, caseDualAnchor.clues);
      expect(simResult.domainSizes['s1'], equals(1));
      expect(simResult.finalPositions['s1'], equals(const CellPosition(1, 1)));
    });

    test('Test 3 (Víctima Flotante Sin Regla de Clausura): Rechazada por ambigüedad residual', () {
      const s1 = SuspectData(id: 's1', name: 'S1');
      const s2 = SuspectData(id: 's2', name: 'S2');
      const victim = SuspectData(id: 'victim', name: 'Víctima');

      final emptyRoomsCase = CaseData(
        id: 'test_floating_victim',
        title: 'Víctima Flotante',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 4,
        boardColumns: 4,
        zones: const [
          ZoneData(id: 'z_a', cells: [CellPosition(0, 0), CellPosition(1, 1)]),
          ZoneData(id: 'z_b', cells: [CellPosition(2, 2), CellPosition(3, 3)]),
          ZoneData(id: 'z_c', cells: [CellPosition(2, 0), CellPosition(2, 1)]),
          ZoneData(id: 'z_d', cells: [CellPosition(0, 2), CellPosition(0, 3)]),
        ],
        suspects: const [s1, s2, victim],
        victimId: 'victim',
        killerId: 's1',
        placedObjects: const [
          PlacedObjectData(object: ObjectData(id: 'obj_1', name: 'Obj1'), position: CellPosition(0, 1)),
          PlacedObjectData(object: ObjectData(id: 'obj_2', name: 'Obj2'), position: CellPosition(2, 3)),
        ],
        clues: const [
          SpatialClueData(
            id: 'c_s1',
            suspectId: 's1',
            text: 'S1 en z_a al O de obj_1',
            constraints: [
              SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_a', type: ClueType.zone),
              SpatialConstraint(relation: SpatialRelation.immediatelyWestOf, targetId: 'obj_1', type: ClueType.cardinal),
            ],
          ),
          SpatialClueData(
            id: 'c_s2',
            suspectId: 's2',
            text: 'S2 en z_b al O de obj_2',
            constraints: [
              SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_b', type: ClueType.zone),
              SpatialConstraint(relation: SpatialRelation.immediatelyWestOf, targetId: 'obj_2', type: ClueType.cardinal),
            ],
          ),
          SpatialClueData(
            id: 'c_victim',
            suspectId: 'victim',
            text: 'La víctima. Estaba a solas con el asesino.',
            constraints: [],
          ),
        ],
        globalRules: const [],
        solution: const SolutionData(suspectPositions: {
          's1': CellPosition(0, 0),
          's2': CellPosition(2, 2),
          'victim': CellPosition(1, 1),
        }),
      );

      final simResult = simulator.simulate(emptyRoomsCase, emptyRoomsCase.clues);
      // Sin regla global, la víctima puede estar en z_a o en z_b
      expect(simResult.victimCandidateRooms, equals(2));
      expect(evaluator.isAcceptable(emptyRoomsCase, emptyRoomsCase.clues), isFalse);
    });

    test('Test 4 (Clausura Válida Natural): Regla global natural cierra el espacio residual exactamente a 1 celda', () {
      const s1 = SuspectData(id: 's1', name: 'S1');
      const s2 = SuspectData(id: 's2', name: 'S2');
      const victim = SuspectData(id: 'victim', name: 'Víctima');

      // Objeto Obj1 colocado en z_a (en 0,1). Objeto Obj2 colocado en z_c (en 2,1).
      // z_b no tiene objetos.
      final caseWithClosure = CaseData(
        id: 'test_closure_success',
        title: 'Clausura Exitosa',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 4,
        boardColumns: 4,
        zones: const [
          ZoneData(id: 'z_a', cells: [CellPosition(0, 0), CellPosition(1, 1), CellPosition(0, 1)]),
          ZoneData(id: 'z_b', cells: [CellPosition(2, 2), CellPosition(3, 3)]),
          ZoneData(id: 'z_c', cells: [CellPosition(2, 0), CellPosition(2, 1)]),
          ZoneData(id: 'z_d', cells: [CellPosition(0, 2), CellPosition(0, 3)]),
        ],
        suspects: const [s1, s2, victim],
        victimId: 'victim',
        killerId: 's1',
        placedObjects: const [
          PlacedObjectData(object: ObjectData(id: 'obj_1', name: 'Obj1'), position: CellPosition(0, 1)),
          PlacedObjectData(object: ObjectData(id: 'obj_2', name: 'Obj2'), position: CellPosition(2, 1)),
        ],
        clues: const [
          SpatialClueData(
            id: 'c_s1',
            suspectId: 's1',
            text: 'S1 en z_a al O de obj_1',
            constraints: [
              SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_a', type: ClueType.zone),
              SpatialConstraint(relation: SpatialRelation.immediatelyWestOf, targetId: 'obj_1', type: ClueType.cardinal),
            ],
          ),
          SpatialClueData(
            id: 'c_s2',
            suspectId: 's2',
            text: 'S2 en z_b al E de obj_2',
            constraints: [
              SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_b', type: ClueType.zone),
              SpatialConstraint(relation: SpatialRelation.immediatelyEastOf, targetId: 'obj_2', type: ClueType.cardinal),
            ],
          ),
          SpatialClueData(
            id: 'c_victim',
            suspectId: 'victim',
            text: 'La víctima. Estaba a solas con el asesino.',
            constraints: [],
          ),
        ],
        // Regla natural: El crimen ocurrió en una habitación provista de mobiliario (z_a contiene obj_1, z_b no contiene objetos)
        globalRules: const [
          BoardRuleData(
            id: 'r_crime_obj',
            type: BoardRuleType.crimeSceneHasObject,
            text: 'La escena del crimen tuvo lugar en una habitación provista de mobiliario.',
          ),
        ],
        solution: const SolutionData(suspectPositions: {
          's1': CellPosition(0, 0),
          's2': CellPosition(2, 2),
          'victim': CellPosition(1, 1),
        }),
      );

      final simResult = simulator.simulate(caseWithClosure, caseWithClosure.clues);
      expect(simResult.victimCandidateRooms, equals(1));
      expect(simResult.victimCandidateCells, equals(1));
      expect(simResult.solved, isTrue);
      expect(simResult.deducedKillerId, equals('s1'));
      expect(evaluator.isAcceptable(caseWithClosure, caseWithClosure.clues), isTrue);
    });

    test('Test 5 (Regla Redundante Rechazada): Regla global innecesaria es descartada por el evaluador', () {
      // demoCase001 se resuelve al 100% por Murdoku sin reglas globales
      final redundantCase = demoCase001.copyWith(
        globalRules: const [
          BoardRuleData(
            id: 'r_redundant',
            type: BoardRuleType.maxOnePersonPerRoomExceptCrime,
            text: 'Cada habitación ocupada albergaba exactamente a una persona, salvo la escena del crimen, donde se encontraban dos.',
          ),
        ],
      );

      // Evaluator debe rechazar el caso por redundancia
      expect(evaluator.isAcceptable(redundantCase, redundantCase.clues), isFalse);
      expect(validator.validate(redundantCase), isFalse);
    });

    test('Test 6 (Regla Artificial / Múltiples Reglas Rechazadas): Más de 1 regla global invalida el caso', () {
      final multiRuleCase = demoCase001.copyWith(
        globalRules: const [
          BoardRuleData(
            id: 'r1',
            type: BoardRuleType.maxOnePersonPerRoomExceptCrime,
            text: 'Regla 1',
          ),
          BoardRuleData(
            id: 'r2',
            type: BoardRuleType.noEmptyRooms,
            text: 'Regla 2',
          ),
        ],
      );

      expect(validator.validate(multiRuleCase), isFalse);
      expect(evaluator.isAcceptable(multiRuleCase, multiRuleCase.clues), isFalse);
    });

    test('Test 7 (Independencia Estricta de killerId): La deducción posicional es idéntica con killerId alterado', () {
      final alteredKillerCase = demoCase001.copyWith(killerId: 'dummy_fake_killer');

      final simResult = simulator.simulate(alteredKillerCase, alteredKillerCase.clues);

      // Todas las posiciones deben deducirse exactamente igual
      expect(simResult.domainSizes['suspect_juan'], equals(1));
      expect(simResult.domainSizes['suspect_ana'], equals(1));
      expect(simResult.domainSizes['suspect_carlos'], equals(1));
      expect(simResult.domainSizes['victim'], equals(1));

      expect(simResult.finalPositions['victim'], equals(const CellPosition(3, 4)));
      expect(simResult.finalPositions['suspect_carlos'], equals(const CellPosition(4, 3)));
    });

    test('Test 8 (Pureza de la Escena del Crimen): La escena contiene víctima + asesino y ningún inocente', () {
      final allDemoCases = [demoCase001];

      for (final c in allDemoCases) {
        final zoneMap = {
          for (final z in c.zones)
            for (final cell in z.cells) cell: z.id,
        };

        final victimPos = c.solution.suspectPositions[c.victimId]!;
        final killerPos = c.solution.suspectPositions[c.killerId]!;
        final crimeZone = zoneMap[victimPos];

        expect(crimeZone, equals(zoneMap[killerPos]), reason: 'Víctima y asesino deben compartir zona');

        final suspectsInCrimeZone = c.solution.suspectPositions.entries.where(
          (e) => zoneMap[e.value] == crimeZone,
        ).toList();

        expect(suspectsInCrimeZone.length, equals(2),
            reason: 'La escena del crimen debe contener exactamente 2 personas (víctima + asesino)');
      }
    });
  });
}
