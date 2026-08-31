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

/// Caso de nivel Medio en un Jardín Botánico (4x4).
/// Diseño revisado con Semántica Cardinal Estricta y Doble Anclaje.
final demoCase002 = CaseData(
  id: 'case_002',
  title: 'El Jardín Botánico',
  description: 'Tres sospechosos paseaban por el jardín botánico. Deduce dónde se encontraba cada uno.',
  difficulty: PuzzleDifficulty.medium,
  requiredCaseId: 'case_001',
  boardRows: 4,
  boardColumns: 4,
  zones: const [
    ZoneData(id: 'z_invernadero', name: 'Invernadero', cells: [
      CellPosition(0, 0), CellPosition(0, 1),
      CellPosition(1, 0), CellPosition(1, 1),
    ]),
    ZoneData(id: 'z_rosaleda', name: 'Rosaleda', cells: [
      CellPosition(0, 2), CellPosition(0, 3),
      CellPosition(1, 2), CellPosition(1, 3),
      CellPosition(2, 3), CellPosition(3, 3),
    ]),
    ZoneData(id: 'z_estanque', name: 'Estanque', cells: [
      CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2),
      CellPosition(3, 0), CellPosition(3, 1), CellPosition(3, 2),
    ]),
  ],
  suspects: const [
    SuspectData(id: 'suspect_luis', name: 'Luis'),
    SuspectData(id: 'suspect_marta', name: 'Marta'),
    SuspectData(id: 'suspect_pedro', name: 'Pedro'),
    SuspectData(id: 'victim', name: 'Víctima'),
  ],
  victimId: 'victim',
  killerId: 'suspect_luis',
  placedObjects: const [
    PlacedObjectData(
      object: ObjectData(id: 'obj_maceta', name: 'Maceta'),
      position: CellPosition(1, 0),
    ),
    PlacedObjectData(
      object: ObjectData(id: 'obj_fuente', name: 'Fuente'),
      position: CellPosition(2, 2),
    ),
    PlacedObjectData(
      object: ObjectData(id: 'obj_estatua', name: 'Estatua'),
      position: CellPosition(2, 0),
    ),
  ],
  solution: const SolutionData(
    suspectPositions: {
      'suspect_luis': CellPosition(0, 0),
      'victim': CellPosition(1, 1),
      'suspect_marta': CellPosition(2, 3),
      'suspect_pedro': CellPosition(3, 2),
    },
  ),
  clues: const [
    SpatialClueData(
      id: 'c2_luis',
      text: 'Luis se encontraba en el Invernadero, estaba inmediatamente al norte de la Maceta.',
      suspectId: 'suspect_luis',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_invernadero', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.immediatelyNorthOf, targetId: 'obj_maceta', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'c2_marta',
      text: 'Marta se encontraba en la Rosaleda, estaba al este de la Estatua.',
      suspectId: 'suspect_marta',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_rosaleda', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.rightOf, targetId: 'obj_estatua', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'c2_pedro',
      text: 'Pedro se encontraba en el Estanque, estaba inmediatamente al sur de la Fuente.',
      suspectId: 'suspect_pedro',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z_estanque', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.immediatelySouthOf, targetId: 'obj_fuente', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'c2_victim',
      text: 'La víctima. Estaba a solas con el asesino.',
      suspectId: 'victim',
      constraints: [],
    ),
  ],
);
