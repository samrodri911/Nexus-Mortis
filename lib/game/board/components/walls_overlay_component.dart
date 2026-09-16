import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';

/// Componente responsable de renderizar los muros continuos del plano arquitectónico.
///
/// Se ubica en [priority = 20], por encima del suelo, alfombras y mobiliario,
/// actuando como una línea arquitectónica dominante y limpia que oculta
/// posibles imperfecciones en las aristas de los muebles o texturas.
///
/// Queda por debajo de [CellComponent] (priority = 30) para garantizar que
/// los elementos interactivos del jugador (✓, X, candidatos y confirmaciones)
/// permanezcan siempre legibles y con máxima jerarquía visual.
class WallsOverlayComponent extends PositionComponent {
  WallsOverlayComponent({
    required this.geometry,
    required super.size,
  }) {
    priority = 20;
  }

  ZoneGeometryResult geometry;
  ui.Picture? _cachedPicture;
  Vector2? _lastRecordedSize;

  static const _colorInteriorWall = ui.Color(0xFF141416); // Muro divisorio negro sólido
  static const _colorExteriorWall = ui.Color(0xFF0A0A0C); // Muro perimetral exterior negro profundo

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

  /// Actualiza la geometría y regenera la caché gráfica de muros.
  void updateGeometry(ZoneGeometryResult newGeometry, Vector2 newSize) {
    geometry = newGeometry;
    size = newSize;
    _rebuildCache(size);
  }

  void _rebuildCache(Vector2 boardSize) {
    if (boardSize.x <= 0 || boardSize.y <= 0) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, boardSize.x, boardSize.y));

    // Grosor arquitectónico responsive de muros
    final wallThickness = (geometry.cellWidth * 0.08).clamp(3.5, 6.0);

    // 1. Muros Interiores Continuos (5-6px)
    _renderWalls(
      canvas: canvas,
      walls: geometry.interiorWalls,
      wallColor: _colorInteriorWall,
      strokeWidth: wallThickness,
    );

    // 2. Muros Exteriores Perimetrales (un poco más gruesos)
    _renderWalls(
      canvas: canvas,
      walls: geometry.exteriorWalls,
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
