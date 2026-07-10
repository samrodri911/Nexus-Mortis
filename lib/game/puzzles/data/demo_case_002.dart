import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

/// Caso demostrativo número 2.
/// Se usa para probar el sistema de progresión y desbloqueo secuencial.
final CaseData demoCase002 = CaseData(
  id: 'demo_case_002',
  title: 'El misterio de la puerta sur',
  description: 'Un nuevo sospechoso entra a la sala. Descubre dónde se ocultaba.',
  difficulty: PuzzleDifficulty.easy,
  boardRows: 4,
  boardColumns: 4,
  requiredCaseId: 'demo_case_001', // Dependencia: requiere completar el 1
  suspects: const [
    SuspectData(id: 'suspect_luis', name: 'Luis'),
    SuspectData(id: 'suspect_sofia', name: 'Sofia'),
  ],
  placedObjects: const [],
  clues: const [
    SpatialClueData(
      id: 'clue_luis_left_sofia',
      text: 'Luis está a la izquierda de Sofia.',
      relation: SpatialRelation.leftOf,
      suspectId: 'suspect_luis',
      targetId: 'suspect_sofia',
    ),
  ],
  solution: const SolutionData(
    suspectPositions: {
      'suspect_luis': CellPosition(1, 1),
      'suspect_sofia': CellPosition(1, 2),
    },
  ),
);
