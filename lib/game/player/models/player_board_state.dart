import 'package:nexus_mortis/game/player/models/player_assignment.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Representa una foto del estado completo del tablero del jugador
/// en un momento dado.
///
/// Este modelo aísla al tablero visual (Flame) de los sistemas
/// lógicos (Validación, Progreso, Hints).
class PlayerBoardState {
  const PlayerBoardState({
    required this.assignments,
    required this.eliminatedCells,
  });

  /// Estado de candidatos de cada sospechoso.
  final List<PlayerAssignment> assignments;

  /// Posiciones que el jugador ha marcado explícitamente con una X.
  /// (Preparado para el Confirmation / Lock System del futuro).
  final Set<CellPosition> eliminatedCells;
}
