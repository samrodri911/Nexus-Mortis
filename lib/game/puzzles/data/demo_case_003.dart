import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';

import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Caso de nivel Difícil en una Biblioteca Antigua (5x5).
/// Demuestra el uso explícito del Operador de Clausura Global (Pista General).
final demoCase003 = CaseData(
  id: 'case_003',
  title: 'La Biblioteca Antigua',
  description: 'Un asesinato entre libros. Usa la pista general para cerrar el caso.',
  difficulty: PuzzleDifficulty.hard,
  requiredCaseId: 'case_002',
  boardRows: 5,
  boardColumns: 5,
  zones: const [
    ZoneData(id: 'z_archivo', name: 'Archivo', cells: [
      CellPosition(0, 0), CellPosition(1, 0), CellPosition(2, 0), CellPosition(3, 0), CellPosition(4, 0),
      CellPosition(0, 1), CellPosition(1, 1),
    ]),
    ZoneData(id: 'z_hemeroteca', name: 'Hemeroteca', cells: [
      CellPosition(0, 2), CellPosition(1, 2), CellPosition(2, 2), CellPosition(3, 2), CellPosition(4, 2),
      CellPosition(2, 3),
    ]),
    ZoneData(id: 'z_lectura', name: 'Lectura', cells: [
      CellPosition(0, 4), CellPosition(1, 4), CellPosition(2, 4), CellPosition(3, 4), CellPosition(4, 4),
      CellPosition(0, 3), CellPosition(1, 3), CellPosition(3, 3), CellPosition(4, 3),
    ]),
    ZoneData(id: 'z_pasillo', name: 'Pasillo', cells: [
      CellPosition(2, 1), CellPosition(3, 1), CellPosition(4, 1),
    ]),
  ],
  suspects: const [
    SuspectData(id: 'suspect_elena', name: 'Elena'),
    SuspectData(id: 'suspect_roberto', name: 'Roberto'),
    SuspectData(id: 'suspect_sofia', name: 'Sofía'),
    SuspectData(id: 'victim', name: 'Víctima'),
  ],
  victimId: 'victim',
  killerId: 'suspect_roberto',
  placedObjects: const [
    PlacedObjectData(
      object: ObjectData(id: 'obj_librero', name: 'Librero'),
      position: CellPosition(1, 1),
    ),
    PlacedObjectData(
      object: ObjectData(id: 'obj_reloj', name: 'Reloj'),
      position: CellPosition(3, 4),
    ),
  ],
  solution: const SolutionData(
    suspectPositions: {
      'suspect_elena': CellPosition(1, 0),
      'suspect_roberto': CellPosition(3, 2),
      'suspect_sofia': CellPosition(4, 4),
      'victim': CellPosition(2, 3),
    },
  ),
  globalRules: const [
    BoardRuleData(id: 'rule_1',
      type: BoardRuleType.crimeSceneHasNoObject,
      text: 'La habitación donde ocurrió el crimen no contenía ningún mueble u objeto.',
    ),
  ],
  clues: const [
    SpatialClueData(
      id: 'c3_elena',
      text: 'Elena estaba en el Archivo, al oeste del Librero.',
      suspectId: 'suspect_elena',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_archivo', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.leftOf, targetId: 'obj_librero', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'c3_roberto',
      text: 'Roberto estaba en la Hemeroteca, al oeste del Reloj.',
      suspectId: 'suspect_roberto',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_hemeroteca', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.leftOf, targetId: 'obj_reloj', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'c3_sofia',
      text: 'Sofía estaba en la sala de Lectura, al sur del Reloj.',
      suspectId: 'suspect_sofia',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_lectura', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.below, targetId: 'obj_reloj', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'c3_victim',
      text: 'La víctima. Estaba a solas con el asesino.',
      suspectId: 'victim',
      constraints: [],
    ),
  ],
);
