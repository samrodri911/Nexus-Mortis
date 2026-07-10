import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Representa una asignación parcial de sospechosos a posiciones durante
/// la búsqueda del solver.
///
/// Es inmutable por diseño: cada expansión del árbol de búsqueda genera
/// una nueva instancia sin mutar la anterior.
class AssignmentState {
  const AssignmentState(this.assignments);

  /// Asignación actual: suspectId -> CellPosition.
  final Map<String, CellPosition> assignments;

  /// Crea una nueva instancia extendida con la asignación adicional.
  AssignmentState extend(String suspectId, CellPosition position) {
    return AssignmentState({
      ...assignments,
      suspectId: position,
    });
  }

  /// Retorna las posiciones ya ocupadas en esta asignación.
  Set<CellPosition> get occupiedPositions => assignments.values.toSet();

  /// Retorna true si el sospechoso ya fue asignado.
  bool isAssigned(String suspectId) => assignments.containsKey(suspectId);
}
