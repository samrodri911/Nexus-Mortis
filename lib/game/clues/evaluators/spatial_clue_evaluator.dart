import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Motor matemático para resolver relaciones espaciales y de línea en el tablero.
class SpatialClueEvaluator {
  const SpatialClueEvaluator();

  /// Determina si [suspectPosition] cumple la regla [relation] respecto a [targetPosition].
  bool evaluate({
    required CellPosition suspectPosition,
    required CellPosition targetPosition,
    required SpatialRelation relation,
  }) {
    switch (relation) {
      case SpatialRelation.adjacentTo:
        return _isAdjacentVonNeumann(suspectPosition, targetPosition);
      case SpatialRelation.notAdjacentTo:
        return !_isAdjacentVonNeumann(suspectPosition, targetPosition);
      case SpatialRelation.leftOf:
        return suspectPosition.row == targetPosition.row && suspectPosition.col < targetPosition.col;
      case SpatialRelation.rightOf:
        return suspectPosition.row == targetPosition.row && suspectPosition.col > targetPosition.col;
      case SpatialRelation.above:
        return suspectPosition.col == targetPosition.col && suspectPosition.row < targetPosition.row;
      case SpatialRelation.below:
        return suspectPosition.col == targetPosition.col && suspectPosition.row > targetPosition.row;
      case SpatialRelation.sameRow:
        return suspectPosition.row == targetPosition.row;
      case SpatialRelation.sameColumn:
        return suspectPosition.col == targetPosition.col;
      case SpatialRelation.differentRow:
        return suspectPosition.row != targetPosition.row;
      case SpatialRelation.differentColumn:
        return suspectPosition.col != targetPosition.col;
      case SpatialRelation.immediatelyNorthOf:
        return suspectPosition.row == targetPosition.row - 1 && suspectPosition.col == targetPosition.col;
      case SpatialRelation.immediatelySouthOf:
        return suspectPosition.row == targetPosition.row + 1 && suspectPosition.col == targetPosition.col;
      case SpatialRelation.immediatelyEastOf:
        return suspectPosition.row == targetPosition.row && suspectPosition.col == targetPosition.col + 1;
      case SpatialRelation.immediatelyWestOf:
        return suspectPosition.row == targetPosition.row && suspectPosition.col == targetPosition.col - 1;
      case SpatialRelation.inZone:
      case SpatialRelation.notInZone:
        return true;
    }
  }

  /// Adyacencia Von Neumann (4 direcciones ortogonales).
  bool _isAdjacentVonNeumann(CellPosition a, CellPosition b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    return (rowDiff + colDiff) == 1;
  }
}
