import 'dart:math';
import 'dart:ui' as ui;

import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Representa una arista indivisible de la cuadrícula entre dos celdas o en el borde del tablero.
class RawGridEdge {
  const RawGridEdge({
    required this.index1,
    required this.index2,
    required this.isHorizontal,
    this.zoneA,
    this.zoneB,
    this.isExterior = false,
  });

  /// Para aristas horizontales: `index1` = fila (0..rows), `index2` = columna (0..cols-1).
  /// Para aristas verticales: `index1` = fila (0..rows-1), `index2` = columna (0..cols).
  final int index1;
  final int index2;
  final bool isHorizontal;
  final String? zoneA;
  final String? zoneB;
  final bool isExterior;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RawGridEdge &&
          runtimeType == other.runtimeType &&
          index1 == other.index1 &&
          index2 == other.index2 &&
          isHorizontal == other.isHorizontal;

  @override
  int get hashCode => Object.hash(index1, index2, isHorizontal);
}

/// Segmento de muro continuo (unión de aristas contiguas colineales) con coordenadas físicas en el tablero.
class WallSegment {
  const WallSegment({
    required this.start,
    required this.end,
    required this.isHorizontal,
    required this.isExterior,
    this.zoneA,
    this.zoneB,
  });

  final ui.Offset start;
  final ui.Offset end;
  final bool isHorizontal;
  final bool isExterior;
  final String? zoneA;
  final String? zoneB;

  double get length => (end - start).distance;

  @override
  String toString() =>
      'WallSegment(${isHorizontal ? "H" : "V"}, ${start.dx.toStringAsFixed(1)},${start.dy.toStringAsFixed(1)} -> ${end.dx.toStringAsFixed(1)},${end.dy.toStringAsFixed(1)}, exterior: $isExterior, zones: $zoneA/$zoneB)';
}

/// Resultado integral del cálculo geométrico del mapa y sus habitaciones.
class ZoneGeometryResult {
  const ZoneGeometryResult({
    required this.rawInteriorEdges,
    required this.rawExteriorEdges,
    required this.interiorWalls,
    required this.exteriorWalls,
    required this.zoneFloorPaths,
    required this.zoneCentroids,
    required this.zoneVisualCenters,
    required this.zoneBoundingBoxes,
    required this.cellWidth,
    required this.cellHeight,
    required this.rows,
    required this.columns,
  });

  final List<RawGridEdge> rawInteriorEdges;
  final List<RawGridEdge> rawExteriorEdges;
  final List<WallSegment> interiorWalls;
  final List<WallSegment> exteriorWalls;
  final Map<String, ui.Path> zoneFloorPaths;
  final Map<String, ui.Offset> zoneCentroids;
  final Map<String, ui.Offset> zoneVisualCenters;
  final Map<String, ui.Rect> zoneBoundingBoxes;
  final double cellWidth;
  final double cellHeight;
  final int rows;
  final int columns;
}

/// Constructor geométrico puro de fronteras continuas y habitaciones arquitectónicas.
///
/// Evalúa el tablero completo con visión global:
/// - Cada arista de frontera se detecta exactamente una vez (cero duplicados).
/// - Las aristas contiguas colineales se fusionan en [WallSegment] continuos.
/// - Celdas vecinas de la misma zona nunca generan muros divisorios.
/// - Funciona con zonas rectangulares y de geometrías irregulares (L, T, etc.).
class ZoneGeometryBuilder {
  const ZoneGeometryBuilder();

  ZoneGeometryResult build({
    required int rows,
    required int columns,
    required List<ZoneData> zones,
    required double boardWidth,
    required double boardHeight,
    Set<CellPosition> blockedCells = const {},
  }) {
    if (rows <= 0 || columns <= 0) {
      throw ArgumentError('Las filas y columnas deben ser mayores que cero.');
    }

    final cellW = boardWidth / columns;
    final cellH = boardHeight / rows;

    // 1. Mapear cada celda (r, c) a su Zone ID
    final cellToZone = <CellPosition, String>{};
    for (final zone in zones) {
      for (final cell in zone.cells) {
        cellToZone[cell] = zone.id;
      }
    }

    String? getZoneId(int r, int c) {
      if (r < 0 || r >= rows || c < 0 || c >= columns) return null;
      return cellToZone[CellPosition(r, c)];
    }

    final rawInteriorEdges = <RawGridEdge>[];
    final rawExteriorEdges = <RawGridEdge>[];

    // 2. Extraer aristas horizontales (y = r * cellH, entre fila r-1 y fila r)
    // Hay rows + 1 líneas horizontales (de r = 0 a r = rows)
    for (int r = 0; r <= rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (r == 0) {
          // Borde exterior superior
          rawExteriorEdges.add(RawGridEdge(
            index1: r,
            index2: c,
            isHorizontal: true,
            isExterior: true,
            zoneB: getZoneId(r, c),
          ));
        } else if (r == rows) {
          // Borde exterior inferior
          rawExteriorEdges.add(RawGridEdge(
            index1: r,
            index2: c,
            isHorizontal: true,
            isExterior: true,
            zoneA: getZoneId(r - 1, c),
          ));
        } else {
          // Arista interna entre celda superior (r-1, c) y celda inferior (r, c)
          final zAbove = getZoneId(r - 1, c);
          final zBelow = getZoneId(r, c);
          if (zAbove != null && zBelow != null && zAbove != zBelow) {
            rawInteriorEdges.add(RawGridEdge(
              index1: r,
              index2: c,
              isHorizontal: true,
              isExterior: false,
              zoneA: zAbove,
              zoneB: zBelow,
            ));
          }
        }
      }
    }

    // 3. Extraer aristas verticales (x = c * cellW, entre columna c-1 y columna c)
    // Hay columns + 1 líneas verticales (de c = 0 a c = columns)
    for (int c = 0; c <= columns; c++) {
      for (int r = 0; r < rows; r++) {
        if (c == 0) {
          // Borde exterior izquierdo
          rawExteriorEdges.add(RawGridEdge(
            index1: r,
            index2: c,
            isHorizontal: false,
            isExterior: true,
            zoneB: getZoneId(r, c),
          ));
        } else if (c == columns) {
          // Borde exterior derecho
          rawExteriorEdges.add(RawGridEdge(
            index1: r,
            index2: c,
            isHorizontal: false,
            isExterior: true,
            zoneA: getZoneId(r, c - 1),
          ));
        } else {
          // Arista interna entre celda izquierda (r, c-1) y celda derecha (r, c)
          final zLeft = getZoneId(r, c - 1);
          final zRight = getZoneId(r, c);
          if (zLeft != null && zRight != null && zLeft != zRight) {
            rawInteriorEdges.add(RawGridEdge(
              index1: r,
              index2: c,
              isHorizontal: false,
              isExterior: false,
              zoneA: zLeft,
              zoneB: zRight,
            ));
          }
        }
      }
    }

    // 4. Fusionar aristas contiguas colineales en WallSegments continuos
    final interiorWalls = _mergeEdgesToWallSegments(
      edges: rawInteriorEdges,
      cellW: cellW,
      cellH: cellH,
    );

    final exteriorWalls = _mergeEdgesToWallSegments(
      edges: rawExteriorEdges,
      cellW: cellW,
      cellH: cellH,
    );

    // 5. Construir polígonos de suelo (Paths), centroides, centros visuales y bounding boxes por zona
    final zoneFloorPaths = <String, ui.Path>{};
    final zoneCentroids = <String, ui.Offset>{};
    final zoneVisualCenters = <String, ui.Offset>{};
    final zoneBoundingBoxes = <String, ui.Rect>{};

    for (final zone in zones) {
      if (zone.cells.isEmpty) continue;

      final path = ui.Path();
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = -double.infinity;
      double maxY = -double.infinity;
      double sumX = 0;
      double sumY = 0;

      for (final cell in zone.cells) {
        final x = cell.col * cellW;
        final y = cell.row * cellH;
        path.addRect(ui.Rect.fromLTWH(x, y, cellW, cellH));

        minX = min(minX, x);
        minY = min(minY, y);
        maxX = max(maxX, x + cellW);
        maxY = max(maxY, y + cellH);

        sumX += x + (cellW / 2);
        sumY += y + (cellH / 2);
      }

      final bbox = ui.Rect.fromLTRB(minX, minY, maxX, maxY);
      zoneFloorPaths[zone.id] = path;
      zoneBoundingBoxes[zone.id] = bbox;
      zoneCentroids[zone.id] = ui.Offset(sumX / zone.cells.length, sumY / zone.cells.length);

      // Cálculo del mejor punto visual disponible dentro de la geometría real:
      final idealCenter = bbox.center;
      final availableCells = zone.cells.where((c) => !blockedCells.contains(c)).toList();

      if (availableCells.isNotEmpty) {
        // 1. Generar puntos candidatos: centros de celdas libres y puntos medios entre celdas libres contiguas
        final candidatePoints = <ui.Offset>[];

        for (final cell in availableCells) {
          candidatePoints.add(ui.Offset(
            cell.col * cellW + (cellW / 2),
            cell.row * cellH + (cellH / 2),
          ));
        }

        // Si hay celdas libres adyacentes horizontal o verticalmente, evaluar el punto medio entre ambas
        for (int i = 0; i < availableCells.length; i++) {
          for (int j = i + 1; j < availableCells.length; j++) {
            final c1 = availableCells[i];
            final c2 = availableCells[j];
            final isAdjacentH = (c1.row == c2.row) && ((c1.col - c2.col).abs() == 1);
            final isAdjacentV = (c1.col == c2.col) && ((c1.row - c2.row).abs() == 1);
            if (isAdjacentH || isAdjacentV) {
              candidatePoints.add(ui.Offset(
                (c1.col + c2.col + 1) * cellW / 2,
                (c1.row + c2.row + 1) * cellH / 2,
              ));
            }
          }
        }

        // 2. Evaluar cada punto candidato por holgura a paredes, distancia a muebles y proximidad al centro
        ui.Offset bestPoint = candidatePoints.first;
        double bestScore = -double.infinity;

        for (final pt in candidatePoints) {
          // Distancia al centro ideal del bounding box
          final distToCenter = ((pt.dx - idealCenter.dx) / cellW).abs() +
              ((pt.dy - idealCenter.dy) / cellH).abs();

          // Medir holgura respecto a las celdas de la misma zona
          int interiorNeighborhood = 0;
          final cellCol = (pt.dx / cellW).floor();
          final cellRow = (pt.dy / cellH).floor();

          final deltas = const [
            [-1, 0], [1, 0], [0, -1], [0, 1],
            [-1, -1], [-1, 1], [1, -1], [1, 1],
          ];
          for (final d in deltas) {
            final nr = cellRow + d[0];
            final nc = cellCol + d[1];
            if (getZoneId(nr, nc) == zone.id) {
              interiorNeighborhood++;
            }
          }

          // Distancia mínima a cualquier celda bloqueada
          double minBlockedDist = 10.0;
          for (final b in blockedCells) {
            final bx = b.col * cellW + (cellW / 2);
            final by = b.row * cellH + (cellH / 2);
            final d = sqrt(pow((pt.dx - bx) / cellW, 2) + pow((pt.dy - by) / cellH, 2));
            if (d < minBlockedDist) {
              minBlockedDist = d;
            }
          }

          // Puntuación: mayor apertura interior + mayor distancia a muebles - penalización por lejanía al centro
          final score = (interiorNeighborhood * 2.5) + (minBlockedDist * 3.0) - (distToCenter * 1.8);

          if (score > bestScore) {
            bestScore = score;
            bestPoint = pt;
          }
        }

        zoneVisualCenters[zone.id] = bestPoint;
      } else {
        // Todas las celdas de la habitación contienen muebles (caso excepcional)
        // Seleccionar la celda más céntrica y desplazar el punto al margen superior libre
        CellPosition mostCentral = zone.cells.first;
        double minDist = double.infinity;
        for (final cell in zone.cells) {
          final cx = cell.col * cellW + (cellW / 2);
          final cy = cell.row * cellH + (cellH / 2);
          final d = (cx - idealCenter.dx).abs() + (cy - idealCenter.dy).abs();
          if (d < minDist) {
            minDist = d;
            mostCentral = cell;
          }
        }

        zoneVisualCenters[zone.id] = ui.Offset(
          mostCentral.col * cellW + (cellW / 2),
          mostCentral.row * cellH + (cellH * 0.22),
        );
      }
    }

    return ZoneGeometryResult(
      rawInteriorEdges: rawInteriorEdges,
      rawExteriorEdges: rawExteriorEdges,
      interiorWalls: interiorWalls,
      exteriorWalls: exteriorWalls,
      zoneFloorPaths: zoneFloorPaths,
      zoneCentroids: zoneCentroids,
      zoneVisualCenters: zoneVisualCenters,
      zoneBoundingBoxes: zoneBoundingBoxes,
      cellWidth: cellW,
      cellHeight: cellH,
      rows: rows,
      columns: columns,
    );
  }

  /// Fusiona aristas contiguas que pertenecen a la misma línea recta en segmentos continuos.
  List<WallSegment> _mergeEdgesToWallSegments({
    required List<RawGridEdge> edges,
    required double cellW,
    required double cellH,
  }) {
    final segments = <WallSegment>[];

    // A. Separar horizontales y verticales
    final horizontalEdges = edges.where((e) => e.isHorizontal).toList();
    final verticalEdges = edges.where((e) => !e.isHorizontal).toList();

    // B. Procesar aristas horizontales agrupadas por fila (index1)
    final hByRow = <int, List<RawGridEdge>>{};
    for (final e in horizontalEdges) {
      hByRow.putIfAbsent(e.index1, () => []).add(e);
    }

    for (final entry in hByRow.entries) {
      final r = entry.key;
      final rowEdges = entry.value..sort((a, b) => a.index2.compareTo(b.index2));

      int startCol = rowEdges.first.index2;
      int endCol = startCol;
      RawGridEdge prevEdge = rowEdges.first;

      for (int i = 1; i < rowEdges.length; i++) {
        final current = rowEdges[i];
        final isContiguous = current.index2 == endCol + 1;
        final sameZones = _haveSameZones(prevEdge, current);

        if (isContiguous && sameZones) {
          endCol = current.index2;
          prevEdge = current;
        } else {
          segments.add(WallSegment(
            start: ui.Offset(startCol * cellW, r * cellH),
            end: ui.Offset((endCol + 1) * cellW, r * cellH),
            isHorizontal: true,
            isExterior: prevEdge.isExterior,
            zoneA: prevEdge.zoneA,
            zoneB: prevEdge.zoneB,
          ));
          startCol = current.index2;
          endCol = startCol;
          prevEdge = current;
        }
      }

      segments.add(WallSegment(
        start: ui.Offset(startCol * cellW, r * cellH),
        end: ui.Offset((endCol + 1) * cellW, r * cellH),
        isHorizontal: true,
        isExterior: prevEdge.isExterior,
        zoneA: prevEdge.zoneA,
        zoneB: prevEdge.zoneB,
      ));
    }

    // C. Procesar aristas verticales agrupadas por columna (index2)
    final vByCol = <int, List<RawGridEdge>>{};
    for (final e in verticalEdges) {
      vByCol.putIfAbsent(e.index2, () => []).add(e);
    }

    for (final entry in vByCol.entries) {
      final c = entry.key;
      final colEdges = entry.value..sort((a, b) => a.index1.compareTo(b.index1));

      int startRow = colEdges.first.index1;
      int endRow = startRow;
      RawGridEdge prevEdge = colEdges.first;

      for (int i = 1; i < colEdges.length; i++) {
        final current = colEdges[i];
        final isContiguous = current.index1 == endRow + 1;
        final sameZones = _haveSameZones(prevEdge, current);

        if (isContiguous && sameZones) {
          endRow = current.index1;
          prevEdge = current;
        } else {
          segments.add(WallSegment(
            start: ui.Offset(c * cellW, startRow * cellH),
            end: ui.Offset(c * cellW, (endRow + 1) * cellH),
            isHorizontal: false,
            isExterior: prevEdge.isExterior,
            zoneA: prevEdge.zoneA,
            zoneB: prevEdge.zoneB,
          ));
          startRow = current.index1;
          endRow = startRow;
          prevEdge = current;
        }
      }

      segments.add(WallSegment(
        start: ui.Offset(c * cellW, startRow * cellH),
        end: ui.Offset(c * cellW, (endRow + 1) * cellH),
        isHorizontal: false,
        isExterior: prevEdge.isExterior,
        zoneA: prevEdge.zoneA,
        zoneB: prevEdge.zoneB,
      ));
    }

    return segments;
  }

  bool _haveSameZones(RawGridEdge a, RawGridEdge b) {
    if (a.isExterior != b.isExterior) return false;
    final setA = {a.zoneA, a.zoneB};
    final setB = {b.zoneA, b.zoneB};
    return setA.length == setB.length && setA.containsAll(setB);
  }
}
