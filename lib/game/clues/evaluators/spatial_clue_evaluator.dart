import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Motor matemático para resolver pistas espaciales en el tablero.
///
/// Esta clase es puramente funcional y no conoce el estado del juego,
/// garantizando que pueda ser inyectada en cualquier validador o generador.
///
/// --- FUTURAS EXPANSIÓNES DOCUMENTADAS ---
/// 
/// Relaciones Negativas (Próxima iteración):
/// - notAdjacentTo
/// - notLeftOf
/// - notRightOf
/// - notAbove
/// - notBelow
/// 
/// Relaciones de Distancia:
/// - distanceExactly(int n)
/// - distanceAtLeast(int n)
/// - distanceAtMost(int n)
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
      case SpatialRelation.leftOf:
        return suspectPosition.col < targetPosition.col;
      case SpatialRelation.rightOf:
        return suspectPosition.col > targetPosition.col;
      case SpatialRelation.above:
        return suspectPosition.row < targetPosition.row;
      case SpatialRelation.below:
        return suspectPosition.row > targetPosition.row;
    }
  }

  /// Adyacencia Von Neumann (4 direcciones: arriba, abajo, izquierda, derecha).
  /// NO permite diagonales. Dos celdas idénticas tampoco son adyacentes.
  bool _isAdjacentVonNeumann(CellPosition a, CellPosition b) {
    final rowDiff = (a.row - b.row).abs();
    final colDiff = (a.col - b.col).abs();
    
    // Exactamente 1 paso de distancia en Manhattan.
    return (rowDiff + colDiff) == 1;
  }
}
