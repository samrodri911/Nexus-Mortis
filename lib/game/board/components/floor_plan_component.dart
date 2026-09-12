import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

/// Componente responsable del plano arquitectónico continuo del tablero.
///
/// Dibuja en una sola pasada optimizada (con caché de [ui.Picture]):
/// 1. Suelos texturizados y ambientación de cada habitación.
/// 2. Marcas de agua blueprint con el nombre de cada zona.
/// 3. Decoraciones arquitectónicas sutiles no-bloqueantes.
/// 4. Muros interiores y exteriores continuos, sin duplicados ni gaps.
class FloorPlanComponent extends PositionComponent {
  FloorPlanComponent({
    required this.controller,
    required super.size,
  });

  final BoardController controller;
  static const _geometryBuilder = ZoneGeometryBuilder();

  ui.Picture? _cachedPicture;
  Vector2? _lastRecordedSize;

  // Estilos de muros arquitectónicos
  static const _colorInteriorWall = ui.Color(0xFF141416); // Muro divisorio negro sólido
  static const _colorExteriorWall = ui.Color(0xFF0A0A0C); // Muro perimetral exterior negro profundo
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

    // 1. Calcular geometría continua del tablero y centros visuales óptimos
    final geom = _geometryBuilder.build(
      rows: rows,
      columns: cols,
      zones: controller.zones,
      boardWidth: boardSize.x,
      boardHeight: boardSize.y,
      blockedCells: blocked,
    );

    // 2. Mapear temas visuales por zona
    final themes = <String, ZoneVisualTheme>{};
    for (int i = 0; i < controller.zones.length; i++) {
      final zone = controller.zones[i];
      themes[zone.id] = ZoneVisualTheme.fromZoneName(zone.name, i);
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

      // Suelo texturizado claro
      theme.renderFloorTexture(canvas, path, bounds, geom.cellWidth);

      // Alfombra decorativa sutil (capa intermedia)
      theme.renderRug(canvas, bounds, geom.cellWidth, geom.cellHeight);

      // Decoración arquitectónica contextual (no bloqueante)
      theme.renderAmbientDecoration(canvas, bounds, geom.cellWidth, geom.cellHeight);

      // Nombre de la habitación en mayúsculas ubicado en el mejor punto visual
      final visualCenter = geom.zoneVisualCenters[zone.id] ?? geom.zoneCentroids[zone.id];
      if (visualCenter != null) {
        theme.renderRoomWatermark(
          canvas: canvas,
          visualCenter: visualCenter,
          roomBounds: bounds,
          cellWidth: geom.cellWidth,
          cellHeight: geom.cellHeight,
        );
      }
    }

    // C. Cuadrícula interna sutil (1px, #D0D0D0) en todas las aristas de celda
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

    // D. Muros Interiores y Exteriores Continuos (Negros, gruesos, dominantes)
    final wallThickness = (geom.cellWidth * 0.08).clamp(3.5, 6.0);

    // Muros Interiores Continuos
    _renderWalls(
      canvas: canvas,
      walls: geom.interiorWalls,
      wallColor: _colorInteriorWall,
      strokeWidth: wallThickness,
    );

    // Muros Exteriores Perimetrales
    _renderWalls(
      canvas: canvas,
      walls: geom.exteriorWalls,
      wallColor: _colorExteriorWall,
      strokeWidth: wallThickness + 0.8,
    );

    _cachedPicture?.dispose();
    _cachedPicture = recorder.endRecording();
    _lastRecordedSize = boardSize.clone();
  }

  void _renderWalls({
    required Canvas canvas,
    required List<WallSegment> walls,
    required ui.Color wallColor,
    required double strokeWidth,
  }) {
    if (walls.isEmpty) return;

    // Muro principal negro sólido con esquinas limpias
    final wallPaint = Paint()
      ..color = wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.round;

    final wallPath = Path();
    for (final wall in walls) {
      wallPath.moveTo(wall.start.dx, wall.start.dy);
      wallPath.lineTo(wall.end.dx, wall.end.dy);
    }

    canvas.drawPath(wallPath, wallPaint);
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
