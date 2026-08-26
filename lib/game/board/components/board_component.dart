import 'package:nexus_mortis/game/board/components/zone_border_component.dart';
import 'package:flame/components.dart';
import 'package:nexus_mortis/game/board/components/cell_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';

/// Componente raíz del tablero espacial.
///
/// Responsabilidades:
/// - Construir la grilla de [CellComponent] a partir de [BoardController].
/// - Recibir notificaciones de tap de cada celda.
/// - Delegar la lógica de toggle al [BoardController].
///
/// Es el único componente que conoce tanto la posición de las celdas
/// como el controlador de estado. Las celdas no toman decisiones.
class BoardComponent extends Component {
  BoardComponent({
    required this.controller,
    required this.boardSize,
  });

  final BoardController controller;

  /// Tamaño disponible del canvas para calcular el tamaño de cada celda.
  /// Se recibe desde [NexusGame.onLoad] para evitar importar NexusGame
  /// y crear una dependencia circular.
  final Vector2 boardSize;

  @override
  Future<void> onLoad() async {
    final rows = controller.cells.length;
    final cols = controller.cells[0].length;
    final cellW = boardSize.x / cols;
    final cellH = boardSize.y / rows;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        final cellData = controller.cells[r][c];

        // Resuelve el nombre del objeto desde el mapa del controlador.
        // CellComponent solo recibe el label ya resuelto.
        final objectLabel = cellData.objectId != null
            ? controller.getObjectLabel(cellData.objectId!)
            : null;

        await add(CellComponent(
          cellData: cellData,
          onTapped: _onCellTapped,
          getActiveSuspectId: () => controller.selectedSuspect?.id,
          allSuspects: controller.suspects,
          objectLabel: objectLabel,
          position: Vector2(c * cellW, r * cellH),
          size: Vector2(cellW, cellH),
        ));
      }
    }
  }

  /// Recibe la notificación de tap de una [CellComponent]
  /// y delega la decisión al controlador.
  ///
  /// Flame re-renderiza cada frame, por lo que [CellComponent] refleja
  /// automáticamente el nuevo estado de [candidateIds] sin necesidad
  /// de un refresh manual.
  void _onCellTapped(int row, int col) {
    controller.toggleMark(row, col);
  }
}
