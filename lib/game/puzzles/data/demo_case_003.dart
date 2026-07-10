import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

/// Caso demostrativo número 3.
/// Se usa para probar el sistema de progresión y desbloqueo secuencial.
final CaseData demoCase003 = CaseData(
  id: 'demo_case_003',
  title: 'Enigma final del pasillo',
  description: 'Las sombras se alargan, y las pistas son pocas.',
  difficulty: PuzzleDifficulty.medium,
  boardRows: 3,
  boardColumns: 3,
  requiredCaseId: 'demo_case_002', // Dependencia: requiere completar el 2
  suspects: const [
    SuspectData(id: 'suspect_david', name: 'David'),
    SuspectData(id: 'suspect_elena', name: 'Elena'),
  ],
  placedObjects: const [],
  clues: const [
    SpatialClueData(
      id: 'clue_elena_above_david',
      text: 'Elena está arriba de David.',
      relation: SpatialRelation.above,
      suspectId: 'suspect_elena',
      targetId: 'suspect_david',
    ),
  ],
  solution: const SolutionData(
    suspectPositions: {
      'suspect_elena': CellPosition(0, 1),
      'suspect_david': CellPosition(1, 1),
    },
  ),
);
