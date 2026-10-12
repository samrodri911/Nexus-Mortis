import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/visual/models/visual_map_plan.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/floor_catalog.dart';

/// Componente responsable del plano arquitectónico base del tablero.
///
/// Se ubica en [priority = 0] (capa inferior absoluta).
/// Dibuja en una sola pasada optimizada (con caché de [ui.Picture]):
/// 1. Papel base arquitectónico.
/// 2. Suelos texturizados y ambientación de cada habitación.
/// 3. Alfombras y decoraciones ambientales confinadas dentro del perímetro de la zona.
/// 4. Nombres de habitación con auto-fit, word-wrap y contorno exterior de alto contraste.
/// 5. Cuadrícula técnica sutil.
class FloorPlanComponent extends PositionComponent {
  FloorPlanComponent({
    required this.controller,
    required super.size,
    this.geometry,
    this.visualPlan,
  }) {
    priority = 0;
  }

  final BoardController controller;
  ZoneGeometryResult? geometry;
  VisualMapPlan? visualPlan;
  static const _geometryBuilder = ZoneGeometryBuilder();

  ui.Picture? _cachedPicture;
  Vector2? _lastRecordedSize;

  static const _colorPaperBase    = ui.Color(0xFFF0EBE1); // Papel de plano arquitectónico cálido
  static const _colorInternalGrid = ui.Color(0xFFD4CEC3); // Cuadrícula interna sutil técnica

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

  /// Actualiza las dimensiones y regenera la caché gráfica del plano arquitectónico.
  void updateBoardSize(Vector2 newSize) {
    size = newSize;
    if (_lastRecordedSize != size) {
      _rebuildCache(size);
    }
  }

  /// Actualiza la geometría precalculada y regenera la caché.
  void updateGeometry(
    ZoneGeometryResult newGeometry,
    Vector2 newSize, [
    VisualMapPlan? newVisualPlan,
  ]) {
    geometry = newGeometry;
    if (newVisualPlan != null) {
      visualPlan = newVisualPlan;
    }
    size = newSize;
    _rebuildCache(size);
  }

  /// Invalida y reconstruye la caché cuando cambia el plan visual.
  void updateVisualPlan(VisualMapPlan? newPlan) {
    if (visualPlan != newPlan) {
      visualPlan = newPlan;
      _rebuildCache(size);
    }
  }

  void _rebuildCache(Vector2 boardSize) {
    if (controller.cells.isEmpty || controller.cells[0].isEmpty) return;
    if (boardSize.x <= 0 || boardSize.y <= 0) return;

    final rows = controller.cells.length;
    final cols = controller.cells[0].length;

    // Detectar celdas bloqueadas para que los nombres de habitación las eviten
    final blocked = <CellPosition>{};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (controller.cells[r][c].isBlocked) {
          blocked.add(CellPosition(r, c));
        }
      }
    }

    // 1. Usar geometría compartida o calcularla
    final geom = geometry ?? _geometryBuilder.build(
      rows: rows,
      columns: cols,
      zones: controller.zones,
      boardWidth: boardSize.x,
      boardHeight: boardSize.y,
      blockedCells: blocked,
      theme: controller.zoneTheme,
    );

    // 2. Mapear temas visuales por zona (incorporando VisualMapPlan si disponible)
    final themes = <String, ZoneVisualTheme>{};
    for (int i = 0; i < controller.zones.length; i++) {
      final zone = controller.zones[i];
      final baseTheme = ZoneVisualTheme.fromZoneName(zone.name, i);
      final roomPlan = visualPlan?.forZone(zone.id);

      if (roomPlan != null) {
        // Sobreescribir suelo y alfombra con decisiones del plan visual
        themes[zone.id] = ZoneVisualTheme(
          archetype: baseTheme.archetype,
          displayName: baseTheme.displayName,
          tintColor: baseTheme.tintColor,
          accentColor: baseTheme.accentColor,
          tileType: roomPlan.floorTileType,
          icon: baseTheme.icon,
          hasRug: roomPlan.hasRug,
        );
      } else {
        themes[zone.id] = baseTheme;
      }
    }

    // 3. Grabar dibujo estático
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, boardSize.x, boardSize.y));

    // A. Fondo base del plano / papel arquitectónico
    canvas.drawRect(
      Rect.fromLTWH(0, 0, boardSize.x, boardSize.y),
      Paint()..color = _colorPaperBase,
    );

    // B. Texturas y ambientación de suelo por habitación
    for (final zone in controller.zones) {
      final path = geom.zoneFloorPaths[zone.id];
      final bounds = geom.zoneBoundingBoxes[zone.id];
      final theme = themes[zone.id];
      if (path == null || bounds == null || theme == null) continue;

      final visualCenter = geom.zoneVisualCenters[zone.id] ?? geom.zoneCentroids[zone.id];

      // Suelo texturizado claro (sprite de FloorCatalog si existe, o fallback vectorial)
      _renderRoomFloor(
        canvas: canvas,
        path: path,
        bounds: bounds,
        zone: zone,
        theme: theme,
        geom: geom,
      );

      // Alfombra decorativa sutil (dibujada ÚNICAMENTE si fue evaluada y admitida en geom.zoneRugRects)
      final rugRect = geom.zoneRugRects[zone.id];
      if (rugRect != null) {
        theme.renderRug(
          canvas,
          path,
          rugRect,
          geom.cellWidth,
          geom.cellHeight,
        );
      }

      // Nombre de la habitación con auto-fit, word-wrap y contorno exterior negro
      if (visualCenter != null) {
        theme.renderRoomWatermark(
          canvas: canvas,
          visualCenter: visualCenter,
          roomBounds: bounds,
          cellWidth: geom.cellWidth,
          cellHeight: geom.cellHeight,
          roomClipPath: path,
        );
      }
    }

    // C. Cuadrícula interna sutil (1px, #D4CEC3) en todas las aristas de celda
    final gridWidth = (geom.cellWidth * 0.015).clamp(0.8, 1.2);
    final gridPaint = Paint()
      ..color = _colorInternalGrid
      ..style = PaintingStyle.stroke
      ..strokeWidth = gridWidth;

    for (int r = 1; r < rows; r++) {
      final y = r * geom.cellHeight;
      canvas.drawLine(Offset(0, y), Offset(boardSize.x, y), gridPaint);
    }
    for (int c = 1; c < cols; c++) {
      final x = c * geom.cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, boardSize.y), gridPaint);
    }

    _cachedPicture?.dispose();
    _cachedPicture = recorder.endRecording();
    _lastRecordedSize = boardSize.clone();
  }

  void _renderRoomFloor({
    required Canvas canvas,
    required ui.Path path,
    required Rect bounds,
    required ZoneData zone,
    required ZoneVisualTheme theme,
    required ZoneGeometryResult geom,
  }) {
    final roomPlan = visualPlan?.forZone(zone.id);
    final tileType = roomPlan?.floorTileType ?? theme.tileType;
    final floorEntry = FloorCatalog.instance.getFloorForTileType(tileType);

    if (floorEntry.hasSprite) {
      final sprite = AtlasManager.instance.getSprite(
        floorEntry.atlasId!,
        floorEntry.regionName!,
      );
      if (sprite != null && sprite.srcSize.x > 0 && sprite.srcSize.y > 0) {
        canvas.save();
        canvas.clipPath(path);

        // Fondo de tinte base suave para evitar artefactos en bordes
        canvas.drawRect(bounds, Paint()..color = theme.tintColor);

        // Mapear el sprite por celda para alineación geométrica precisa
        for (final cell in zone.cells) {
          final cellRect = Rect.fromLTWH(
            cell.col * geom.cellWidth,
            cell.row * geom.cellHeight,
            geom.cellWidth,
            geom.cellHeight,
          );
          // Opacidad y tinte sutil para preservar bajo contraste y legibilidad
          final floorPaint = Paint()..color = const Color(0xE6FFFFFF);
          sprite.renderRect(canvas, cellRect, overridePaint: floorPaint);
        }

        canvas.restore();
        return;
      }
    }

    // Fallback garantizado a dibujo vectorial existente
    theme.renderFloorTexture(canvas, path, bounds, geom.cellWidth);
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
