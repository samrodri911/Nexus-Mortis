import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:nexus_mortis/game/board/components/architectural_furniture_renderer.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';

/// Componente responsable de renderizar el mobiliario arquitectónico en capa 2.5D.
///
/// Se ubica en [priority = 10], por encima del suelo y alfombras (priority = 0),
/// pero por debajo de los muros continuos (priority = 20) y de las marcas
/// interactivas del jugador (priority = 30).
///
/// Dibuja sombras proyectadas y volumen 2.5D para cada objeto lógico,
/// optimizado con caché de [ui.Picture].
class FurnitureLayerComponent extends PositionComponent {
  FurnitureLayerComponent({
    required this.controller,
    required this.metrics,
    required super.size,
  }) {
    priority = 10;
  }

  final BoardController controller;
  BoardLayoutMetrics metrics;
  static const _furnitureRenderer = ArchitecturalFurnitureRenderer();

  ui.Picture? _cachedPicture;
  Vector2? _lastRecordedSize;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _rebuildCache(size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_lastRecordedSize != this.size) {
      _rebuildCache(this.size);
    }
  }

  /// Actualiza las métricas y regenera la caché gráfica del mobiliario.
  void updateMetrics(BoardLayoutMetrics newMetrics, Vector2 newSize) {
    metrics = newMetrics;
    size = newSize;
    _rebuildCache(size);
  }

  void _rebuildCache(Vector2 boardSize) {
    if (controller.cells.isEmpty || controller.cells[0].isEmpty) return;
    if (boardSize.x <= 0 || boardSize.y <= 0) return;

    final rows = controller.cells.length;
    final cols = controller.cells[0].length;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, boardSize.x, boardSize.y));

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cellData = controller.cells[r][c];
        if (!cellData.isBlocked) continue;

        final pos = metrics.getCellPosition(r, c);
        // Ajuste relativo a la posición local del componente (offsetX, offsetY)
        final localX = pos.x - metrics.offsetX;
        final localY = pos.y - metrics.offsetY;

        final objectLabel = cellData.objectId != null
            ? controller.getObjectLabel(cellData.objectId!)
            : null;

        _furnitureRenderer.render(
          canvas: canvas,
          objectId: cellData.objectId ?? '',
          objectLabel: objectLabel,
          cellRect: Rect.fromLTWH(localX, localY, metrics.tileSize, metrics.tileSize),
          tileSize: metrics.tileSize,
        );
      }
    }

    _cachedPicture?.dispose();
    _cachedPicture = recorder.endRecording();
    _lastRecordedSize = boardSize.clone();
  }

  @override
  void render(Canvas canvas) {
    if (_cachedPicture != null) {
      canvas.drawPicture(_cachedPicture!);
    }
  }

  @override
  void onRemove() {
    _cachedPicture?.dispose();
    _cachedPicture = null;
    super.onRemove();
  }
}
