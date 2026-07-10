import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

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
  suspects: const [
    SuspectData(id: 'suspect_juan', name: 'Juan'),
    SuspectData(id: 'suspect_ana', name: 'Ana'),
    SuspectData(id: 'suspect_carlos', name: 'Carlos'),
  ],
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
      text: 'Carlos estaba a la izquierda de la silla.',
      relation: SpatialRelation.leftOf,
      suspectId: 'suspect_carlos',
      targetId: 'obj_silla',
    ),
    SpatialClueData(
      id: 'clue_5',
      text: 'Ana estaba junto a Juan.',
      relation: SpatialRelation.adjacentTo,
      suspectId: 'suspect_ana',
      targetId: 'suspect_juan',
    ),
    SpatialClueData(
      id: 'clue_6',
      text: 'Ana estaba debajo de Juan.',
      relation: SpatialRelation.below,
      suspectId: 'suspect_ana',
      targetId: 'suspect_juan',
    ),
  ],
  solution: const SolutionData(
    suspectPositions: {
      'suspect_juan': CellPosition(1, 2),
      'suspect_ana': CellPosition(2, 2),
      'suspect_carlos': CellPosition(3, 2),
    },
  ),
);
