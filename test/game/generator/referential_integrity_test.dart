import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_rejection_reason.dart';

void main() {
  late CaseIntegrityValidator validator;

  setUp(() {
    validator = CaseIntegrityValidator();
  });

  group('Referential Integrity & Crime Scene Invariants', () {
    test('Caso canónico demoCase001 pasa todas las validaciones', () {
      final result = validator.validateDetailed(demoCase001);
      expect(result.isValid, isTrue);
      expect(result.rejectionReason, isNull);
    });

    test('Test 1: Pista con zona inexistente es rechazada', () {
      final invalidClues = [
        ...demoCase001.clues.where((c) => c.suspectId != 'suspect_juan'),
        const SpatialClueData(
          id: 'clue_juan',
          suspectId: 'suspect_juan',
          text: 'Juan estuvo en la Zona Fantasma',
          constraints: [
            SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_fantasma', type: ClueType.zone),
          ],
        ),
      ];

      final caseWithGhostZone = demoCase001.copyWith(clues: invalidClues);
      final result = validator.validateDetailed(caseWithGhostZone);

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.invalidZoneReference));
    });

    test('Test 2: Pista con objeto inexistente es rechazada', () {
      final invalidClues = [
        ...demoCase001.clues.where((c) => c.suspectId != 'suspect_juan'),
        const SpatialClueData(
          id: 'clue_juan',
          suspectId: 'suspect_juan',
          text: 'Juan estuvo al este del Armario Fantasma',
          constraints: [
            SpatialConstraint(relation: SpatialRelation.immediatelyEastOf, targetId: 'obj_armario_fantasma', type: ClueType.cardinal),
          ],
        ),
      ];

      final caseWithGhostObject = demoCase001.copyWith(clues: invalidClues);
      final result = validator.validateDetailed(caseWithGhostObject);

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.invalidObjectReference));
    });

    test('Test 3: Objeto fuera de los límites del tablero es rechazado', () {
      final caseWithOOBObject = demoCase001.copyWith(
        placedObjects: [
          ...demoCase001.placedObjects,
          const PlacedObjectData(
            object: ObjectData(id: 'obj_fuera', name: 'Escritorio'),
            position: CellPosition(5, 5), // Fuera de una grilla 5x5 (0..4, 0..4)
          ),
        ],
      );

      final result = validator.validateDetailed(caseWithOOBObject);
      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.objectOutOfBounds));
    });

    test('Test 4: Víctima sola en una habitación sin sospechoso es rechazada', () {
      // Mover a la víctima a la zona z3 (donde no está Carlos/asesino) sin colisiones de fila/col
      final modifiedSolution = SolutionData(
        suspectPositions: {
          'suspect_juan': const CellPosition(1, 2), // z1
          'suspect_ana': const CellPosition(0, 1), // z1
          'suspect_carlos': const CellPosition(4, 3), // z2
          'victim': const CellPosition(3, 0), // z3 (sola en z3!)
        },
      );

      final caseVictimAlone = demoCase001.copyWith(solution: modifiedSolution);
      final result = validator.validateDetailed(caseVictimAlone);

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.victimWithoutKiller));
    });

    test('Test 5: Escena del crimen con 3 personas es rechazada', () {
      // Ubicar a Carlos (asesino), Ana (inocente) y Víctima en z1 sin colisiones de fila/col
      final modifiedSolution = SolutionData(
        suspectPositions: {
          'suspect_juan': const CellPosition(4, 3), // z2
          'suspect_ana': const CellPosition(0, 1), // z1
          'suspect_carlos': const CellPosition(1, 0), // z1
          'victim': const CellPosition(2, 2), // z1 (3 ocupantes en z1!)
        },
      );

      final caseThreeInCrimeScene = demoCase001.copyWith(solution: modifiedSolution);
      final result = validator.validateDetailed(caseThreeInCrimeScene);

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.crimeSceneThirdOccupant));
    });

    test('Test 6: Pista ambigua que deja 2+ candidatos es rechazada', () {
      // Dejar a Juan con pista insuficiente (solo inZone z1, dejando 7 casillas posibles)
      final ambiguousClues = [
        const SpatialClueData(
          id: 'clue_juan',
          suspectId: 'suspect_juan',
          text: 'Juan se encontraba en la Zona Izquierda.',
          constraints: [
            SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z1', type: ClueType.zone),
          ],
        ),
        ...demoCase001.clues.where((c) => c.suspectId != 'suspect_juan'),
      ];

      final caseAmbiguous = demoCase001.copyWith(clues: ambiguousClues);
      final result = validator.validateDetailed(caseAmbiguous);

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.suspectAmbiguous));
    });

    test('Test 7: Tarjeta de víctima alterada o no canónica es rechazada', () {
      final alteredVictimClues = [
        ...demoCase001.clues.where((c) => c.suspectId != 'victim'),
        const SpatialClueData(
          id: 'clue_victim',
          suspectId: 'victim',
          text: 'La víctima estaba al norte de la Cama.',
          constraints: [
            SpatialConstraint(relation: SpatialRelation.immediatelyNorthOf, targetId: 'obj_cama', type: ClueType.cardinal),
          ],
        ),
      ];

      final caseAlteredVictim = demoCase001.copyWith(clues: alteredVictimClues);
      final result = validator.validateDetailed(caseAlteredVictim);

      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.victimCardInvalid));
    });

    test('Test 8: Regla global redundante/innecesaria es rechazada', () {
      // demoCase001 ya es 100% resoluble sin regla global. Añadir una regla verdadera pero redundante debe ser rechazado.
      final caseWithRedundantRule = demoCase001.copyWith(
        globalRules: const [
          BoardRuleData(
            id: 'rule_redundant',
            type: BoardRuleType.crimeSceneHasObject,
            text: 'La escena del crimen tenía mobiliario.',
          ),
        ],
      );

      final result = validator.validateDetailed(caseWithRedundantRule);
      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.globalRuleRedundant));
    });

    test('Test 9: Más de 1 regla global es rechazada', () {
      final caseWithTooManyRules = demoCase001.copyWith(
        globalRules: const [
          BoardRuleData(id: 'r1', type: BoardRuleType.noEmptyRooms, text: 'R1'),
          BoardRuleData(id: 'r2', type: BoardRuleType.crimeSceneHasObject, text: 'R2'),
        ],
      );

      final result = validator.validateDetailed(caseWithTooManyRules);
      expect(result.isValid, isFalse);
      expect(result.rejectionReason, equals(CaseRejectionReason.globalRuleTooMany));
    });
  });
}
