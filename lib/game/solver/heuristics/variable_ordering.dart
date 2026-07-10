import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Implementa la heurística MRV (Minimum Remaining Values).
///
/// En cada paso del backtracking, selecciona el sospechoso no asignado
/// que tiene el menor número de posiciones posibles en su dominio actual.
///
/// Esta heurística reduce drásticamente el tamaño del árbol de búsqueda
/// al fallar antes en ramas inviables.
class VariableOrdering {
  const VariableOrdering();

  /// Selecciona el próximo sospechoso a asignar usando MRV.
  ///
  /// Recibe todos los sospechosos pendientes y sus dominios actuales.
  /// Devuelve el ID del sospechoso con el dominio más pequeño.
  ///
  /// En caso de empate, se usa el que aparece primero en la lista
  /// (orden estable, determinista).
  String pickNext(
    List<String> unassigned,
    Map<String, List<CellPosition>> domains,
  ) {
    assert(unassigned.isNotEmpty, 'No quedan sospechosos sin asignar');

    String best = unassigned.first;
    int bestSize = domains[best]?.length ?? 0;

    for (int i = 1; i < unassigned.length; i++) {
      final id = unassigned[i];
      final size = domains[id]?.length ?? 0;
      if (size < bestSize) {
        best = id;
        bestSize = size;
      }
    }

    return best;
  }
}
