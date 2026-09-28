import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:nexus_mortis/game/board/components/architectural_furniture_renderer.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';
import 'package:nexus_mortis/game/board/services/decorative_furniture_evaluator.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';

/// Componente responsable de renderizar el mobiliario arquitectónico en capa 2.5D.
///
/// Se ubica en [priority = 10], por encima del suelo y alfombras (priority = 0),
/// pero por debajo de los muros continuos (priority = 20) y de las marcas
/// interactivas del jugador (priority = 30).
///
/// Dibuja:
/// 1. Mobiliario decorativo temático sutil (con densidad controlada y safe margins).
/// 2. Objetos lógicos 2.5D con sombras proyectadas y trazo de contorno nítido.
///
/// Prioriza sprites de [FurnitureCatalog] y [AtlasManager]. Si un sprite o atlas
/// no está disponible, realiza fallback transparente e inmediato a
/// [ArchitecturalFurnitureRenderer].
/// Optimizado con caché de [ui.Picture].
class FurnitureLayerComponent extends PositionComponent {
  FurnitureLayerComponent({
    required this.controller,
    required this.metrics,
    this.geometry,
    required super.size,
  }) {
    priority = 10;
  }

  final BoardController controller;
  BoardLayoutMetrics metrics;
  ZoneGeometryResult? geometry;

  static const _furnitureRenderer = ArchitecturalFurnitureRenderer();
  static const _decorativeEvaluator = DecorativeFurnitureEvaluator();

  ui.Picture? _cachedPicture;
  Vector2? _lastRecordedSize;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _rebuildCache(size);

    // Si el atlas por defecto aún no está cargado, cargarlo asíncronamente
    // y regenerar la caché gráfica al completarse.
    if (!AtlasManager.instance.isLoaded(FurnitureCatalog.kitchenAtlasId)) {
      try {
        await AtlasManager.instance.loadAtlas(FurnitureCatalog.kitchenAtlas);
        _rebuildCache(size);
      } catch (_) {
        // Fallback garantizado: ArchitecturalFurnitureRenderer se mantiene activo.
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (_lastRecordedSize != this.size) {
      _rebuildCache(this.size);
    }
  }

  /// Actualiza las métricas y geometría, y regenera la caché gráfica del mobiliario.
  void updateMetrics(
    BoardLayoutMetrics newMetrics,
    Vector2 newSize, [
    ZoneGeometryResult? newGeometry,
  ]) {
    metrics = newMetrics;
    if (newGeometry != null) {
      geometry = newGeometry;
    }
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

    // Detectar celdas bloqueadas por objetos lógicos
    final blocked = <CellPosition>{};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (controller.cells[r][c].isBlocked) {
          blocked.add(CellPosition(r, c));
        }
      }
    }

    // 1. Mobiliario decorativo temático sutil (capa base de mobiliario)
    final decorativeItems = _decorativeEvaluator.evaluate(
      rows: rows,
      columns: cols,
      zones: controller.zones,
      blockedCells: blocked,
      zoneVisualCenters: geometry?.zoneVisualCenters ?? const {},
      zoneRugRects: geometry?.zoneRugRects ?? const {},
      theme: controller.zoneTheme,
      cellWidth: metrics.tileSize,
      cellHeight: metrics.tileSize,
    );

    for (final item in decorativeItems) {
      final pos = metrics.getCellPosition(item.position.row, item.position.col);
      final localX = pos.x - metrics.offsetX;
      final localY = pos.y - metrics.offsetY;

      _renderFurnitureItem(
        canvas: canvas,
        objectId: item.objectId,
        cellRect: Rect.fromLTWH(localX, localY, metrics.tileSize, metrics.tileSize),
        tileSize: metrics.tileSize,
        isDecorative: true,
      );
    }

    // 2. Objetos lógicos del caso (capa principal con contornos nítidos)
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

        _renderFurnitureItem(
          canvas: canvas,
          objectId: cellData.objectId ?? '',
          objectLabel: objectLabel,
          cellRect: Rect.fromLTWH(localX, localY, metrics.tileSize, metrics.tileSize),
          tileSize: metrics.tileSize,
          isDecorative: false,
        );
      }
    }

    _cachedPicture?.dispose();
    _cachedPicture = recorder.endRecording();
    _lastRecordedSize = boardSize.clone();
  }

  void _renderFurnitureItem({
    required Canvas canvas,
    required String objectId,
    String? objectLabel,
    required Rect cellRect,
    required double tileSize,
    required bool isDecorative,
  }) {
    // 1. Intentar resolver sprite desde FurnitureCatalog
    final entry = FurnitureCatalog.instance.findEntryForLogicalObject(objectId);
    if (entry != null) {
      final sprite =
          AtlasManager.instance.getSprite(entry.atlasId, entry.regionName);
      if (sprite != null) {
        final destRect = SpriteLayoutHelper.calculateDestRect(
          cellRect: cellRect,
          srcWidth: sprite.srcSize.x,
          srcHeight: sprite.srcSize.y,
          fillRatio: entry.defaultScaleRatio,
        );

        // Sombra elíptica suave en la base del mueble para integrarlo al plano
        final shadowRect = Rect.fromCenter(
          center: Offset(
            destRect.center.dx,
            destRect.bottom - (destRect.height * 0.05),
          ),
          width: destRect.width * 0.72,
          height: destRect.height * 0.18,
        );
        canvas.drawOval(
          shadowRect,
          Paint()..color = const Color(0x28000000),
        );

        final paint = isDecorative
            ? (Paint()..color = const Color(0xDDFFFFFF))
            : null;
        sprite.renderRect(canvas, destRect, overridePaint: paint);
        return;
      }
    }

    // 2. Fallback garantizado a ArchitecturalFurnitureRenderer
    _furnitureRenderer.render(
      canvas: canvas,
      objectId: objectId,
      objectLabel: objectLabel,
      cellRect: cellRect,
      tileSize: tileSize,
      isDecorative: isDecorative,
    );
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
