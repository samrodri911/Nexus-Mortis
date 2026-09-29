import 'package:flame/components.dart';
import 'package:nexus_mortis/game/board/components/cell_component.dart';
import 'package:nexus_mortis/game/board/components/floor_plan_component.dart';
import 'package:nexus_mortis/game/board/components/furniture_layer_component.dart';
import 'package:nexus_mortis/game/board/components/walls_overlay_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/visual/services/visual_map_builder.dart';

/// Componente raíz del tablero espacial.
///
/// Responsabilidades:
/// - Garantizar que cada celda sea un cuadrado perfecto (	ileWidth == tileHeight == tileSize).
/// - Centrar perfectamente el tablero en el área visible disponible.
/// - Adaptar dinámicamente el tamaño de celdas cuando el viewport se expande o contrae.
/// - Orquestar la jerarquía estricta de capas visuales:
///   1. [FloorPlanComponent] (Priority 0): Suelo, alfombras, ambientación y nombres de zonas.
///   2. [FurnitureLayerComponent] (Priority 10): Mobiliario 2.5D con sombras proyectadas.
///   3. [WallsOverlayComponent] (Priority 20): Muros continuos dominantes (5-6px).
///   4. [CellComponent]s (Priority 30): Marcas de interacción del jugador (✓, X, candidatos, confirmaciones).
class BoardComponent extends Component {
  BoardComponent({
    required this.controller,
    required this.boardSize,
  });

  final BoardController controller;
  Vector2 boardSize;

  static const _geometryBuilder = ZoneGeometryBuilder();

  late FloorPlanComponent _floorPlanComponent;
  late FurnitureLayerComponent _furnitureLayerComponent;
  late WallsOverlayComponent _wallsOverlayComponent;
  final List<List<CellComponent>> _cellComponents = [];
  late BoardLayoutMetrics _metrics;
  late ZoneGeometryResult _geometry;

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

    _geometry = _calculateGeometry(_metrics, rows, cols);

    // Generar plan visual procedural UNA SOLA VEZ por caso.
    // El seed se genera de datos estables del caso (no Dart hashCode).
    final blocked = <CellPosition>{};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (controller.cells[r][c].isBlocked) {
          blocked.add(CellPosition(r, c));
        }
      }
    }
    final caseSeed = _buildCaseSeed(rows, cols, controller.zones.length);
    final visualPlan = VisualMapBuilder.build(
      zones: controller.zones,
      blockedCells: blocked,
      caseSeed: caseSeed,
      theme: controller.zoneTheme,
    );

    // 1. Capa 0: Plano arquitectónico continuo (suelos, alfombras, ambientación, nombres)
    _floorPlanComponent = FloorPlanComponent(
      controller: controller,
      geometry: _geometry,
      visualPlan: visualPlan,
      size: Vector2(_metrics.boardWidth, _metrics.boardHeight),
    )..position = Vector2(_metrics.offsetX, _metrics.offsetY);
    await add(_floorPlanComponent);

    // 2. Capa 10: Mobiliario arquitectónico 2.5D y sombras
    _furnitureLayerComponent = FurnitureLayerComponent(
      controller: controller,
      metrics: _metrics,
      geometry: _geometry,
      visualPlan: visualPlan,
      size: Vector2(_metrics.boardWidth, _metrics.boardHeight),
    )..position = Vector2(_metrics.offsetX, _metrics.offsetY);
    await add(_furnitureLayerComponent);

    // 3. Capa 20: Muros continuos dominantes (línea arquitectónica limpia)
    _wallsOverlayComponent = WallsOverlayComponent(
      geometry: _geometry,
      size: Vector2(_metrics.boardWidth, _metrics.boardHeight),
    )..position = Vector2(_metrics.offsetX, _metrics.offsetY);
    await add(_wallsOverlayComponent);

    // 4. Capa 30: Celdas interactivas (marcas de gameplay, candidatos, confirmaciones)
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

    _geometry = _calculateGeometry(_metrics, rows, cols);

    final boardDim = Vector2(_metrics.boardWidth, _metrics.boardHeight);
    final boardOffset = Vector2(_metrics.offsetX, _metrics.offsetY);

    // Actualizar FloorPlanComponent (Priority 0)
    _floorPlanComponent.position = boardOffset;
    _floorPlanComponent.updateGeometry(_geometry, boardDim);

    // Actualizar FurnitureLayerComponent (Priority 10)
    _furnitureLayerComponent.position = boardOffset;
    _furnitureLayerComponent.updateMetrics(_metrics, boardDim, _geometry);

    // Actualizar WallsOverlayComponent (Priority 20)
    _wallsOverlayComponent.position = boardOffset;
    _wallsOverlayComponent.updateGeometry(_geometry, boardDim);

    // Actualizar cada CellComponent (Priority 30)
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

  ZoneGeometryResult _calculateGeometry(BoardLayoutMetrics metrics, int rows, int cols) {
    final blocked = <CellPosition>{};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (controller.cells[r][c].isBlocked) {
          blocked.add(CellPosition(r, c));
        }
      }
    }

    return _geometryBuilder.build(
      rows: rows,
      columns: cols,
      zones: controller.zones,
      boardWidth: metrics.boardWidth,
      boardHeight: metrics.boardHeight,
      blockedCells: blocked,
      theme: controller.zoneTheme,
    );
  }

  void _onCellTapped(int row, int col) {
    controller.toggleMark(row, col);
  }

  /// Genera un seed determinista a partir de datos estables del caso.
  ///
  /// NO usa `hashCode` de Dart (no garantizado multiplataforma).
  /// Completamente independiente del RNG del puzzle.
  static int _buildCaseSeed(int rows, int cols, int zoneCount) {
    int seed = 0x5F3759DF; // Constante arbitraria determinista
    seed = ((seed * 31) + rows) & 0x7FFFFFFF;
    seed = ((seed * 37) + cols) & 0x7FFFFFFF;
    seed = ((seed * 41) + zoneCount) & 0x7FFFFFFF;
    return seed;
  }
}
