import 'package:flame/components.dart';
import 'package:nexus_mortis/game/board/components/cell_component.dart';
import 'package:nexus_mortis/game/board/components/floor_plan_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';

/// Componente raíz del tablero espacial.
///
/// Responsabilidades:
/// - Garantizar que cada celda sea un cuadrado perfecto (`tileWidth == tileHeight == tileSize`).
/// - Centrar perfectamente el tablero en el área visible disponible.
/// - Adaptar dinámicamente el tamaño de celdas cuando el viewport se expande o contrae.
class BoardComponent extends Component {
  BoardComponent({
    required this.controller,
    required this.boardSize,
  });

  final BoardController controller;
  Vector2 boardSize;

  late FloorPlanComponent _floorPlanComponent;
  final List<List<CellComponent>> _cellComponents = [];
  late BoardLayoutMetrics _metrics;

  @override
  Future<void> onLoad() async {
    final rows = controller.cells.length;
    final cols = controller.cells[0].length;

    _metrics = BoardLayoutMetrics.calculate(
      availableWidth: boardSize.x,
      availableHeight: boardSize.y,
      rows: rows,
      cols: cols,
    );

    // 1. Agregar el plano arquitectónico continuo (suelos, muros, ambientación)
    _floorPlanComponent = FloorPlanComponent(
      controller: controller,
      size: Vector2(_metrics.boardWidth, _metrics.boardHeight),
    )..position = Vector2(_metrics.offsetX, _metrics.offsetY);

    await add(_floorPlanComponent);

    // 2. Agregar celdas interactivas perfectamente cuadradas y centradas
    for (var r = 0; r < rows; r++) {
      final rowList = <CellComponent>[];
      for (var c = 0; c < cols; c++) {
        final cellData = controller.cells[r][c];

        final objectLabel = cellData.objectId != null
            ? controller.getObjectLabel(cellData.objectId!)
            : null;

        final cellComp = CellComponent(
          cellData: cellData,
          onTapped: _onCellTapped,
          getActiveSuspectId: () => controller.selectedSuspect?.id,
          allSuspects: controller.suspects,
          objectLabel: objectLabel,
          position: _metrics.getCellPosition(r, c),
          size: Vector2(_metrics.tileSize, _metrics.tileSize),
        );
        rowList.add(cellComp);
        await add(cellComp);
      }
      _cellComponents.add(rowList);
    }
  }

  /// Recalcula métricas y reposiciona/reescala componentes cuando cambia el viewport disponible.
  void resize(Vector2 newViewportSize) {
    if (newViewportSize.x <= 0 || newViewportSize.y <= 0) return;
    boardSize = newViewportSize;

    final rows = controller.cells.length;
    final cols = controller.cells[0].length;

    _metrics = BoardLayoutMetrics.calculate(
      availableWidth: boardSize.x,
      availableHeight: boardSize.y,
      rows: rows,
      cols: cols,
    );

    // Actualizar FloorPlanComponent
    _floorPlanComponent.position = Vector2(_metrics.offsetX, _metrics.offsetY);
    _floorPlanComponent.updateBoardSize(Vector2(_metrics.boardWidth, _metrics.boardHeight));

    // Actualizar cada CellComponent
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (r < _cellComponents.length && c < _cellComponents[r].length) {
          final cellComp = _cellComponents[r][c];
          cellComp.position = _metrics.getCellPosition(r, c);
          cellComp.size = Vector2(_metrics.tileSize, _metrics.tileSize);
        }
      }
    }
  }

  void _onCellTapped(int row, int col) {
    controller.toggleMark(row, col);
  }
}
