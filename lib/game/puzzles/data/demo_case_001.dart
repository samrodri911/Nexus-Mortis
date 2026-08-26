import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
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
/// Un caso matemáticamente verificado con una solución única en base a 6 pistas.
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
      position: CellPosition(4, 0), // Objeto decorativo
    ),
  ],
  clues: const [
    SpatialClueData(
      id: 'clue_1',
      text: 'Juan estaba junto a la cama.',
      relation: SpatialRelation.adjacentTo,
      suspectId: 'suspect_juan',
      targetId: 'obj_cama',
    ),
    SpatialClueData(
      id: 'clue_2',
      text: 'Juan estaba a la derecha de la cama.',
      relation: SpatialRelation.rightOf,
      suspectId: 'suspect_juan',
      targetId: 'obj_cama',
    ),
    SpatialClueData(
      id: 'clue_3',
      text: 'Carlos estaba junto a la silla.',
      relation: SpatialRelation.adjacentTo,
      suspectId: 'suspect_carlos',
      targetId: 'obj_silla',
    ),
    SpatialClueData(
      id: 'clue_4',
      text: 'Carlos estaba debajo de la silla.',
      relation: SpatialRelation.below,
      suspectId: 'suspect_carlos',
      targetId: 'obj_silla',
    ),
    SpatialClueData(
      id: 'clue_5',
      text: 'Ana estaba junto a la cama.',
      relation: SpatialRelation.adjacentTo,
      suspectId: 'suspect_ana',
      targetId: 'obj_cama',
    ),
    SpatialClueData(
      id: 'clue_6',
      text: 'Ana estaba arriba de la cama.',
      relation: SpatialRelation.above,
      suspectId: 'suspect_ana',
      targetId: 'obj_cama',
    ),
    SpatialClueData(
      id: 'clue_7',
      text: 'La víctima estaba junto a la silla.',
      relation: SpatialRelation.adjacentTo,
      suspectId: 'victim',
      targetId: 'obj_silla',
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
