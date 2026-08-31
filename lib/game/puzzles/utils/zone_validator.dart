import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Validador de consistencia matemática y geométrica de zonas en un tablero.
class ZoneValidator {
  ZoneValidator._();

  /// Valida que las [zones] conformen una partición válida y contigua de la cuadrícula de [rows] x [cols].
  static bool validateZones(int rows, int cols, List<ZoneData> zones) {
    if (rows <= 0 || cols <= 0 || zones.isEmpty) return false;

    final totalCells = rows * cols;
    final coveredCells = <CellPosition>{};
    final seenZoneIds = <String>{};

    for (final zone in zones) {
      if (zone.id.trim().isEmpty) return false;
      if (!seenZoneIds.add(zone.id)) return false; // ID duplicado
      if (zone.cells.isEmpty) return false; // Zona vacía

      final zoneCellSet = <CellPosition>{};

      for (final cell in zone.cells) {
        if (cell.row < 0 || cell.row >= rows || cell.col < 0 || cell.col >= cols) {
          return false; // Celda fuera del tablero
        }
        if (!zoneCellSet.add(cell)) {
          return false; // Celda duplicada dentro de la misma zona
        }
        if (!coveredCells.add(cell)) {
          return false; // Celda solapada en múltiples zonas
        }
      }

      // Validar contigüidad ortogonal (Von Neumann) dentro de la zona
      if (!_isContiguous(zone.cells)) {
        return false;
      }
    }

    // Comprobar cobertura exacta del 100% del tablero
    if (coveredCells.length != totalCells) {
      return false;
    }

    return true;
  }

  /// Comprueba si un conjunto de celdas forma un componente conectado ortogonalmente.
  static bool _isContiguous(List<CellPosition> cells) {
    if (cells.length <= 1) return true;

    final cellSet = cells.toSet();
    final visited = <CellPosition>{};
    final queue = <CellPosition>[cells.first];
    visited.add(cells.first);

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      final neighbors = [
        CellPosition(current.row - 1, current.col),
        CellPosition(current.row + 1, current.col),
        CellPosition(current.row, current.col - 1),
        CellPosition(current.row, current.col + 1),
      ];

      for (final n in neighbors) {
        if (cellSet.contains(n) && visited.add(n)) {
          queue.add(n);
        }
      }
    }

    return visited.length == cells.length;
  }
}
