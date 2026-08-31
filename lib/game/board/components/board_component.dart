import 'package:flame/components.dart';
import 'package:nexus_mortis/game/board/components/cell_component.dart';
import 'package:nexus_mortis/game/board/components/zone_border_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';

/// Componente raíz del tablero espacial.
class BoardComponent extends Component {
  BoardComponent({
    required this.controller,
    required this.boardSize,
  });

  final BoardController controller;
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

    // Agregar bordes de zonas encima de las celdas
    await add(ZoneBorderComponent(
      controller: controller,
      size: boardSize,
    ));
  }

  void _onCellTapped(int row, int col) {
    controller.toggleMark(row, col);
  }
}
