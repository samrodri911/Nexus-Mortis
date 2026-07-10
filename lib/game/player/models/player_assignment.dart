import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Representa el estado de asignación de un sospechoso desde
/// la perspectiva del jugador.
class PlayerAssignment {
  const PlayerAssignment({
    required this.suspectId,
    required this.candidates,
  });

  /// Identificador del sospechoso.
  final String suspectId;

  /// Posiciones en el tablero donde el jugador ha marcado a este
  /// sospechoso como candidato ("Posible").
  final List<CellPosition> candidates;
}
