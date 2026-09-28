import 'dart:math';
import 'dart:ui' as ui;

import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

/// Representación puramente visual de un elemento de mobiliario decorativo.
///
/// Estos elementos NO tienen existencia lógica:
/// - NO bloquean la celda ([CellData.isBlocked] permanece en false).
/// - NO alteran el puzzle, el solver, las pistas, el replay ni la validación.
/// - El jugador puede interactuar con normalidad en la celda (candidatos, X, sospechosos).
class DecorativeFurnitureItem {
  const DecorativeFurnitureItem({
    required this.position,
    required this.objectId,
    required this.zoneId,
  });

  final CellPosition position;
  final String objectId;
  final String zoneId;
}

/// Evaluador de colocación y densidad de mobiliario decorativo visual.
///
/// Reglas de diseño (V3.5):
/// 1. Densidad controlada: ~1-2 elementos representativos por habitación en total
///    (contando los objetos lógicos ya presentes).
///    - Habitaciones pequeñas (<= 2 celdas): 0 decoraciones (evitar saturación).
///    - Habitaciones medianas (3-4 celdas): 1 decoración si no tiene objetos lógicos, 0 si ya tiene.
///    - Habitaciones grandes (>= 5 celdas): máximo 2 elementos totales (lógicos + decorativos).
///    - Si una habitación ya tiene >= 2 objetos lógicos: 0 decoraciones.
/// 2. Exclusiones estrictas:
///    - Nunca en celdas bloqueadas por objetos lógicos.
///    - Nunca en la celda que contiene la marca de agua del nombre de la habitación.
///    - Nunca en celdas cubiertas por una alfombra ([zoneRugRects]).
/// 3. Preferencia de muros:
///    - Se priorizan celdas adyacentes a un muro arquitectónico o borde del tablero
///      para que los muebles se ubiquen de forma orgánica y apoyada.
/// 4. Afinidad temática:
///    - Los objetos decorativos corresponden estrictamente al [ZoneTheme] del caso.
class DecorativeFurnitureEvaluator {
  const DecorativeFurnitureEvaluator();

  /// Evalúa y determina los objetos decorativos visuales a colocar en el tablero.
  List<DecorativeFurnitureItem> evaluate({
    required int rows,
    required int columns,
    required List<ZoneData> zones,
    required Set<CellPosition> blockedCells,
    required Map<String, ui.Offset> zoneVisualCenters,
    required Map<String, ui.Rect> zoneRugRects,
    ZoneTheme? theme,
    required double cellWidth,
    required double cellHeight,
  }) {
    final result = <DecorativeFurnitureItem>[];

    // Mapa rápido de pertenencia de celda a zona para calcular muros
    final cellZoneMap = <CellPosition, String>{};
    for (final zone in zones) {
      for (final cell in zone.cells) {
        cellZoneMap[cell] = zone.id;
      }
    }

    for (final zone in zones) {
      // 1. Contar objetos lógicos ya presentes en la habitación
      final logicalObjectsInZone = zone.cells.where(blockedCells.contains).length;
      if (logicalObjectsInZone >= 2) {
        // La habitación ya cuenta con suficiente densidad de mobiliario
        continue;
      }

      final zoneCellCount = zone.cells.length;
      int targetDecorativeCount = 0;

      if (logicalObjectsInZone == 1) {
        // Si ya hay 1 objeto lógico:
        // Solo habitaciones grandes (>= 5 celdas) admiten 1 objeto decorativo adicional
        if (zoneCellCount >= 5) {
          targetDecorativeCount = 1;
        }
      } else {
        // logicalObjectsInZone == 0:
        if (zoneCellCount <= 2) {
          targetDecorativeCount = 0; // Habitación diminuta, suelo despejado
        } else if (zoneCellCount <= 4) {
          targetDecorativeCount = 1;
        } else {
          // 5 o más celdas: 1 o 2 decoraciones
          targetDecorativeCount = min(2, (zoneCellCount / 3).floor());
        }
      }

      if (targetDecorativeCount <= 0) continue;

      // 2. Identificar celda reservada para el nombre de la habitación
      CellPosition? watermarkCell;
      final visualCenter = zoneVisualCenters[zone.id];
      if (visualCenter != null && cellWidth > 0 && cellHeight > 0) {
        final col = (visualCenter.dx / cellWidth).floor().clamp(0, columns - 1);
        final row = (visualCenter.dy / cellHeight).floor().clamp(0, rows - 1);
        watermarkCell = CellPosition(row, col);
      }

      // 3. Rectángulo de alfombra si existe
      final rugRect = zoneRugRects[zone.id];

      // 4. Filtrar celdas elegibles
      final eligibleCells = <CellPosition>[];
      for (final cell in zone.cells) {
        // No en celda bloqueada
        if (blockedCells.contains(cell)) continue;

        // No en la celda del texto
        if (watermarkCell != null && cell == watermarkCell) continue;

        // No en celda solapada con alfombra
        if (rugRect != null && cellWidth > 0 && cellHeight > 0) {
          final cellRect = ui.Rect.fromLTWH(
            cell.col * cellWidth,
            cell.row * cellHeight,
            cellWidth,
            cellHeight,
          );
          if (rugRect.overlaps(cellRect)) continue;
        }

        eligibleCells.add(cell);
      }

      if (eligibleCells.isEmpty) continue;

      // 5. Puntuación de proximidad a muro para cada celda elegible
      // Un mueble se apoya preferentemente contra un muro (perímetro de habitación o borde de tablero)
      final scoredCells = eligibleCells.map((cell) {
        int wallScore = 0;
        final neighbors = [
          CellPosition(cell.row - 1, cell.col),
          CellPosition(cell.row + 1, cell.col),
          CellPosition(cell.row, cell.col - 1),
          CellPosition(cell.row, cell.col + 1),
        ];

        for (final n in neighbors) {
          // Borde del tablero es un muro
          if (n.row < 0 || n.row >= rows || n.col < 0 || n.col >= columns) {
            wallScore++;
          } else {
            // Límite con otra zona es un muro
            final otherZone = cellZoneMap[n];
            if (otherZone != null && otherZone != zone.id) {
              wallScore++;
            }
          }
        }

        return (cell: cell, wallScore: wallScore);
      }).toList();

      // Ordenar por wallScore descendente y luego por hash determinista
      scoredCells.sort((a, b) {
        if (b.wallScore != a.wallScore) {
          return b.wallScore.compareTo(a.wallScore);
        }
        final hashA = (a.cell.row * 37 + a.cell.col * 19) ^ zone.id.hashCode;
        final hashB = (b.cell.row * 37 + b.cell.col * 19) ^ zone.id.hashCode;
        return hashA.compareTo(hashB);
      });

      // 6. Asignar objetos temáticos
      final itemsToPlace = _pickThematicItems(
        zoneName: zone.name ?? '',
        theme: theme,
        count: min(targetDecorativeCount, scoredCells.length),
        zoneSeed: zone.id.hashCode,
      );

      for (int i = 0; i < itemsToPlace.length; i++) {
        result.add(
          DecorativeFurnitureItem(
            position: scoredCells[i].cell,
            objectId: itemsToPlace[i],
            zoneId: zone.id,
          ),
        );
      }
    }

    return result;
  }

  /// Selecciona una lista de identificadores temáticos distintos para una habitación.
  List<String> _pickThematicItems({
    required String zoneName,
    required ZoneTheme? theme,
    required int count,
    required int zoneSeed,
  }) {
    if (count <= 0) return const [];

    final lower = zoneName.toLowerCase();
    final candidates = <String>[];

    // 1. Museo / Archivo Histórico
    if (theme == ZoneTheme.museumArchive ||
        lower.contains('museo') ||
        lower.contains('galer') ||
        lower.contains('bóveda') ||
        lower.contains('boveda') ||
        lower.contains('egipcia') ||
        lower.contains('archivo') ||
        lower.contains('reliquia')) {
      if (lower.contains('egipcia')) {
        candidates.addAll(['obj_sarcofago', 'obj_anfora', 'obj_pedestal']);
      } else if (lower.contains('galer') || lower.contains('arte')) {
        candidates.addAll(['obj_caballete', 'obj_vitrina', 'obj_estatua']);
      } else if (lower.contains('bóveda') || lower.contains('boveda')) {
        candidates.addAll(['obj_vitrina', 'obj_baul', 'obj_pedestal']);
      } else if (lower.contains('archivo')) {
        candidates.addAll(['obj_librero', 'obj_vitrina', 'obj_escritorio']);
      } else if (lower.contains('restaura') || lower.contains('taller')) {
        candidates.addAll(['obj_caballete', 'obj_escritorio', 'obj_baul']);
      } else {
        candidates.addAll(['obj_pedestal', 'obj_anfora', 'obj_vitrina', 'obj_estatua']);
      }
    }
    // 2. Teatro / Ópera
    else if (theme == ZoneTheme.theaterOpera ||
        lower.contains('teatro') ||
        lower.contains('escenario') ||
        lower.contains('palco') ||
        lower.contains('platea') ||
        lower.contains('camerino') ||
        lower.contains('foso') ||
        lower.contains('ensayo')) {
      if (lower.contains('escenario')) {
        candidates.addAll(['obj_atril', 'obj_foco', 'obj_pedestal']);
      } else if (lower.contains('palco') || lower.contains('platea')) {
        candidates.addAll(['obj_silla_terciopelo', 'obj_columna', 'obj_lampara']);
      } else if (lower.contains('foso') || lower.contains('orquesta')) {
        candidates.addAll(['obj_atril', 'obj_silla_terciopelo']);
      } else if (lower.contains('camerino')) {
        candidates.addAll(['obj_silla_terciopelo', 'obj_armario', 'obj_lampara']);
      } else if (lower.contains('ensayo')) {
        candidates.addAll(['obj_atril', 'obj_silla_terciopelo', 'obj_librero']);
      } else {
        candidates.addAll(['obj_columna', 'obj_estatua', 'obj_silla_terciopelo']);
      }
    }
    // 3. Jardín Botánico / Invernadero
    else if (theme == ZoneTheme.botanicalGarden ||
        lower.contains('jard') ||
        lower.contains('botán') ||
        lower.contains('botan') ||
        lower.contains('rosaleda') ||
        lower.contains('orquíd') ||
        lower.contains('tropical') ||
        lower.contains('huerto') ||
        lower.contains('cobertizo') ||
        lower.contains('vivero') ||
        lower.contains('estanque')) {
      if (lower.contains('rosaleda') || lower.contains('orquíd') || lower.contains('vivero')) {
        candidates.addAll(['obj_maceta', 'obj_banco', 'obj_anfora']);
      } else if (lower.contains('tropical')) {
        candidates.addAll(['obj_maceta', 'obj_fuente', 'obj_banco']);
      } else if (lower.contains('huerto') || lower.contains('cobertizo')) {
        candidates.addAll(['obj_baul', 'obj_banco', 'obj_estante']);
      } else if (lower.contains('estanque')) {
        candidates.addAll(['obj_banco', 'obj_anfora', 'obj_fuente']);
      } else {
        candidates.addAll(['obj_maceta', 'obj_banco', 'obj_anfora']);
      }
    }
    // 4. Mansión Clásica / Default
    else {
      if (lower.contains('biblio') || lower.contains('despacho') || lower.contains('estudio')) {
        candidates.addAll(['obj_librero', 'obj_lampara', 'obj_sillon']);
      } else if (lower.contains('salón') || lower.contains('salon')) {
        candidates.addAll(['obj_sillon', 'obj_reloj', 'obj_estatua']);
      } else if (lower.contains('comedor')) {
        candidates.addAll(['obj_aparador', 'obj_silla', 'obj_reloj']);
      } else if (lower.contains('cocina')) {
        candidates.addAll(['obj_aparador', 'obj_baul']);
      } else if (lower.contains('dormitorio') || lower.contains('cuarto')) {
        candidates.addAll(['obj_sillon', 'obj_armario', 'obj_lampara']);
      } else if (lower.contains('juego')) {
        candidates.addAll(['obj_sillon', 'obj_reloj', 'obj_librero']);
      } else if (lower.contains('vestíbulo') || lower.contains('vestibulo')) {
        candidates.addAll(['obj_estatua', 'obj_reloj', 'obj_columna']);
      } else {
        candidates.addAll(['obj_sillon', 'obj_reloj', 'obj_librero', 'obj_estatua']);
      }
    }

    // Asegurar selección de elementos distintos
    final selected = <String>[];
    final available = List<String>.from(candidates);
    var seed = zoneSeed.abs();

    while (selected.length < count && available.isNotEmpty) {
      final index = seed % available.length;
      selected.add(available.removeAt(index));
      seed = (seed * 31 + 17).abs();
    }

    return selected;
  }
}
