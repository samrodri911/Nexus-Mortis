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

/// Caso de demostración 001.
/// 
/// "La Habitación del Hotel"
/// Formato canónico Murdoku: 1 Personaje = 1 Tarjeta + Tarjeta Canónica de Víctima.
final demoCase001 = CaseData(
  id: 'case_001',
  title: 'La Habitación del Hotel',
  description: 'Tres sospechosos estuvieron dentro de la habitación. Determina dónde se encontraba cada uno cuando ocurrió el incidente.',
  difficulty: PuzzleDifficulty.easy,
  boardRows: 5,
  boardColumns: 5,
  zones: const [
    ZoneData(id: 'z1', name: 'Izquierda', cells: [
      CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
      CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
      CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2),
    ]),
    ZoneData(id: 'z2', name: 'Derecha', cells: [
      CellPosition(0, 3), CellPosition(0, 4),
      CellPosition(1, 3), CellPosition(1, 4),
      CellPosition(2, 3), CellPosition(2, 4),
      CellPosition(3, 3), CellPosition(3, 4),
      CellPosition(4, 3), CellPosition(4, 4),
    ]),
    ZoneData(id: 'z3', name: 'Abajo', cells: [
      CellPosition(3, 0), CellPosition(3, 1), CellPosition(3, 2),
      CellPosition(4, 0), CellPosition(4, 1), CellPosition(4, 2),
    ]),
  ],
  suspects: const [
    SuspectData(id: 'suspect_juan', name: 'Juan'),
    SuspectData(id: 'suspect_ana', name: 'Ana'),
    SuspectData(id: 'suspect_carlos', name: 'Carlos'),
    SuspectData(id: 'victim', name: 'Víctima'),
  ],
  victimId: 'victim',
  killerId: 'suspect_carlos',
  placedObjects: const [
    PlacedObjectData(
      object: ObjectData(id: 'obj_cama', name: 'Cama'),
      position: CellPosition(1, 1),
    ),
    PlacedObjectData(
      object: ObjectData(id: 'obj_silla', name: 'Silla'),
      position: CellPosition(3, 3),
    ),
    PlacedObjectData(
      object: ObjectData(id: 'obj_mesa', name: 'Mesa'),
      position: CellPosition(2, 4),
    ),
  ],
  clues: const [
    SpatialClueData(
      id: 'clue_juan',
      text: 'Juan se encontraba en la Zona Izquierda, estaba inmediatamente al este de la Cama.',
      suspectId: 'suspect_juan',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z1', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.immediatelyEastOf, targetId: 'obj_cama', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'clue_ana',
      text: 'Ana se encontraba en la Zona Izquierda, estaba inmediatamente al norte de la Cama.',
      suspectId: 'suspect_ana',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z1', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.immediatelyNorthOf, targetId: 'obj_cama', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'clue_carlos',
      text: 'Carlos se encontraba en la Zona Derecha, estaba inmediatamente al sur de la Silla.',
      suspectId: 'suspect_carlos',
      constraints: [
        SpatialConstraint(relation: SpatialRelation.inZone, targetId: 'z2', type: ClueType.zone),
        SpatialConstraint(relation: SpatialRelation.immediatelySouthOf, targetId: 'obj_silla', type: ClueType.cardinal),
      ],
    ),
    SpatialClueData(
      id: 'clue_victim',
      text: 'La víctima. Estaba a solas con el asesino.',
      suspectId: 'victim',
      constraints: [],
    ),
  ],
  solution: const SolutionData(
    suspectPositions: {
      'suspect_juan': CellPosition(1, 2),
      'suspect_ana': CellPosition(0, 1),
      'suspect_carlos': CellPosition(4, 3),
      'victim': CellPosition(3, 4),
    },
  ),
);
