import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Representa un objeto fijo del escenario posicionado en una celda específica.
class PlacedObjectData {
  const PlacedObjectData({
    required this.object,
    required this.position,
  });

  /// Los datos base del objeto (ID, nombre).
  final ObjectData object;

  /// La posición física donde se encuentra en el tablero,
  /// lo que bloqueará dicha celda.
  final CellPosition position;
}
