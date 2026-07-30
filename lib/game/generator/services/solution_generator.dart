import 'dart:math';

import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

/// Genera una solución aleatoria válida (asignación de entidades a celdas).
class SolutionGenerator {
  const SolutionGenerator(this._random);

  final Random _random;

  ({SolutionData solution, Map<String, CellPosition> objectPositions}) generateSolution({
    required int rows,
    required int columns,
    required List<SuspectData> suspects,
    required List<ObjectData> objects,
  }) {
    if (suspects.length + objects.length > rows * columns) {
      throw ArgumentError('Not enough cells for all entities.');
    }

    final positions = <CellPosition>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        positions.add(CellPosition(r, c));
      }
    }

    positions.shuffle(_random);

    final suspectPositions = <String, CellPosition>{};
    for (int i = 0; i < suspects.length; i++) {
      suspectPositions[suspects[i].id] = positions[i];
    }

    final objectPositions = <String, CellPosition>{};
    for (int i = 0; i < objects.length; i++) {
      objectPositions[objects[i].id] = positions[suspects.length + i];
    }

    return (
      solution: SolutionData(suspectPositions: suspectPositions),
      objectPositions: objectPositions,
    );
  }
}
