import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/local/mappers/case_data_mapper.dart';
import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

void main() {
  group('CaseDataMapper Round-Trip Tests', () {
    test('Serializa y deserializa un CaseData completo preservando 100% de los datos', () {
      const originalCase = CaseData(
        id: 'case_test_001',
        title: 'El Misterio del Conservatorio',
        description: 'La víctima fue hallada en la Rosaleda.',
        difficulty: PuzzleDifficulty.medium,
        boardRows: 4,
        boardColumns: 4,
        zones: [
          ZoneData(
            id: 'z1',
            name: 'Rosaleda',
            cells: [CellPosition(0, 0), CellPosition(0, 1), CellPosition(1, 0), CellPosition(1, 1)],
          ),
          ZoneData(
            id: 'z2',
            name: 'Invernadero',
            cells: [
              CellPosition(0, 2), CellPosition(0, 3), CellPosition(1, 2), CellPosition(1, 3),
              CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2), CellPosition(2, 3),
              CellPosition(3, 0), CellPosition(3, 1), CellPosition(3, 2), CellPosition(3, 3),
            ],
          ),
        ],
        suspects: [
          SuspectData(id: 's_juan', name: 'Juan'),
          SuspectData(id: 's_ana', name: 'Ana'),
          SuspectData(id: 'victim', name: 'Víctima'),
        ],
        victimId: 'victim',
        killerId: 's_juan',
        placedObjects: [
          PlacedObjectData(
            object: ObjectData(id: 'obj_fuente', name: 'Fuente'),
            position: CellPosition(2, 2),
          ),
        ],
        clues: [
          SpatialClueData(
            id: 'c1',
            text: 'Juan estaba al oeste de la fuente.',
            relation: SpatialRelation.leftOf,
            suspectId: 's_juan',
            targetId: 'obj_fuente',
            type: ClueType.cardinal,
          ),
          SpatialClueData(
            id: 'c2',
            text: 'La víctima se encontraba en la Rosaleda.',
            relation: SpatialRelation.inZone,
            suspectId: 'victim',
            targetId: 'z1',
            type: ClueType.zone,
          ),
        ],
        solution: SolutionData(
          suspectPositions: {
            's_juan': CellPosition(0, 0),
            's_ana': CellPosition(3, 1),
            'victim': CellPosition(1, 1),
          },
        ),
        requiredCaseId: 'case_000',
        origin: CaseOrigin.campaign,
      );

      final jsonMap = CaseDataMapper.toJson(originalCase);
      final jsonString = jsonEncode(jsonMap);

      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final restoredCase = CaseDataMapper.fromJson(decodedMap);

      expect(restoredCase.id, equals(originalCase.id));
      expect(restoredCase.title, equals(originalCase.title));
      expect(restoredCase.description, equals(originalCase.description));
      expect(restoredCase.difficulty, equals(originalCase.difficulty));
      expect(restoredCase.boardRows, equals(originalCase.boardRows));
      expect(restoredCase.boardColumns, equals(originalCase.boardColumns));
      expect(restoredCase.victimId, equals(originalCase.victimId));
      expect(restoredCase.killerId, equals(originalCase.killerId));
      expect(restoredCase.requiredCaseId, equals(originalCase.requiredCaseId));
      expect(restoredCase.origin, equals(originalCase.origin));

      // Zonas
      expect(restoredCase.zones.length, equals(originalCase.zones.length));
      for (int i = 0; i < originalCase.zones.length; i++) {
        expect(restoredCase.zones[i].id, equals(originalCase.zones[i].id));
        expect(restoredCase.zones[i].name, equals(originalCase.zones[i].name));
        expect(restoredCase.zones[i].cells, equals(originalCase.zones[i].cells));
      }

      // Sospechosos
      expect(restoredCase.suspects.length, equals(originalCase.suspects.length));
      for (int i = 0; i < originalCase.suspects.length; i++) {
        expect(restoredCase.suspects[i].id, equals(originalCase.suspects[i].id));
        expect(restoredCase.suspects[i].name, equals(originalCase.suspects[i].name));
      }

      // Objetos
      expect(restoredCase.placedObjects.length, equals(originalCase.placedObjects.length));
      for (int i = 0; i < originalCase.placedObjects.length; i++) {
        expect(restoredCase.placedObjects[i].object.id, equals(originalCase.placedObjects[i].object.id));
        expect(restoredCase.placedObjects[i].object.name, equals(originalCase.placedObjects[i].object.name));
        expect(restoredCase.placedObjects[i].position, equals(originalCase.placedObjects[i].position));
      }

      // Pistas
      expect(restoredCase.clues.length, equals(originalCase.clues.length));
      for (int i = 0; i < originalCase.clues.length; i++) {
        expect(restoredCase.clues[i].id, equals(originalCase.clues[i].id));
        expect(restoredCase.clues[i].text, equals(originalCase.clues[i].text));
        expect(restoredCase.clues[i].relation, equals(originalCase.clues[i].relation));
        expect(restoredCase.clues[i].suspectId, equals(originalCase.clues[i].suspectId));
        expect(restoredCase.clues[i].targetId, equals(originalCase.clues[i].targetId));
        expect(restoredCase.clues[i].type, equals(originalCase.clues[i].type));
      }

      // Solución
      expect(restoredCase.solution.suspectPositions, equals(originalCase.solution.suspectPositions));
    });
  });
}
