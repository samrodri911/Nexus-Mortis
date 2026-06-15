import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Contenedor de la verdad absoluta de un caso.
///
/// Define dónde se encuentra realmente cada sospechoso.
/// Esta clase vive separada de la lógica del tablero del jugador para 
/// evitar bugs en el estado y garantizar que la validación sea pura.
class SolutionData {
  const SolutionData({
    required this.suspectPositions,
  });

  /// Mapea el ID de un sospechoso a su posición correcta en la solución.
  final Map<String, CellPosition> suspectPositions;
}
