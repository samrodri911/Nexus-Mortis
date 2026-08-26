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

final demoCase002 = CaseData(
  id: 'case_002',
  title: 'El Jardín Botánico',
  description: 'Tres sospechosos paseaban por el jardín...',
  difficulty: PuzzleDifficulty.medium,
  boardRows: 4,
  boardColumns: 4,
  zones: const [
    ZoneData(id: 'z1', name: 'Z1', cells: [CellPosition(0,0)])
  ],
  suspects: const [
    SuspectData(id: 'suspect_luis', name: 'Luis'),
    SuspectData(id: 'suspect_marta', name: 'Marta'),
    SuspectData(id: 'suspect_pedro', name: 'Pedro'),
    SuspectData(id: 'victim', name: 'Víctima'),
  ],
  victimId: 'victim',
  killerId: 'suspect_luis',
  placedObjects: const [],
  clues: const [],
  solution: const SolutionData(suspectPositions: {}),
);
