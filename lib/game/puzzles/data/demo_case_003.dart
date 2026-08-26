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

final demoCase003 = CaseData(
  id: 'case_003',
  title: 'La Biblioteca',
  description: 'Un misterio entre libros antiguos.',
  difficulty: PuzzleDifficulty.hard,
  boardRows: 6,
  boardColumns: 6,
  zones: const [
    ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0,0)])
  ],
  suspects: const [
    SuspectData(id: 'suspect_elena', name: 'Elena'),
    SuspectData(id: 'suspect_roberto', name: 'Roberto'),
    SuspectData(id: 'suspect_sofia', name: 'Sofía'),
    SuspectData(id: 'suspect_diego', name: 'Diego'),
    SuspectData(id: 'victim', name: 'Víctima'),
  ],
  victimId: 'victim',
  killerId: 'suspect_elena',
  placedObjects: const [],
  clues: const [],
  solution: const SolutionData(suspectPositions: {}),
);
