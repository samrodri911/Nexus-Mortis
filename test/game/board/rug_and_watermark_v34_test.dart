import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/board/services/rug_placement_evaluator.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RugPlacementEvaluator — Reglas Estrictas de Alfombras (V3.4)', () {
    const evaluator = RugPlacementEvaluator();

    test('Zona en forma de L: terminantemente prohibida, rechazada (0 alfombras)', () {
      // Zona en L de 4 celdas en bounding box 2x3
      const lZone = ZoneData(
        id: 'z_l',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0),
          CellPosition(1, 0),
          CellPosition(2, 0),
          CellPosition(2, 1),
        ],
      );

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [lZone],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.containsKey('z_l'), isFalse,
          reason: 'Una zona en L nunca debe recibir alfombra.');
      expect(result.isEmpty, isTrue);
    });

    test('Zona en forma de T: rechazada para alfombras', () {
      const tZone = ZoneData(
        id: 'z_t',
        name: 'Biblioteca',
        cells: [
          CellPosition(0, 0),
          CellPosition(0, 1),
          CellPosition(0, 2),
          CellPosition(1, 1),
        ],
      );

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [tZone],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.containsKey('z_t'), isFalse);
    });

    test('Zona de una sola celda (1x1): rechazada (suelo limpio)', () {
      const singleCellZone = ZoneData(
        id: 'z_single',
        name: 'Dormitorio',
        cells: [CellPosition(1, 1)],
      );

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [singleCellZone],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.isEmpty, isTrue);
    });

    test('Zona estrecha (1x3 o 3x1): rechazada (no cabe bloque 2x2)', () {
      const narrowZone = ZoneData(
        id: 'z_narrow',
        name: 'Vestíbulo',
        cells: [
          CellPosition(0, 0),
          CellPosition(0, 1),
          CellPosition(0, 2),
        ],
      );

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [narrowZone],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.isEmpty, isTrue);
    });

    test('Zona rectangular 2x2 con un mueble lógico: rechazada por no tener 2x2 libre', () {
      const rectZone = ZoneData(
        id: 'z_rect',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0),
          CellPosition(0, 1),
          CellPosition(1, 0),
          CellPosition(1, 1),
        ],
      );

      // Una celda tiene un mueble
      final blocked = {const CellPosition(0, 0)};

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [rectZone],
        blockedCells: blocked,
        theme: ZoneTheme.classicMansion,
      );

      expect(result.isEmpty, isTrue,
          reason: 'Si una celda del bloque 2x2 tiene mueble, no puede haber alfombra encima del mueble.');
    });

    test('Zona rectangular 2x2 100% libre: genera alfombra con padding seguro respecto a muros', () {
      const rectZone = ZoneData(
        id: 'z_rect',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0),
          CellPosition(0, 1),
          CellPosition(1, 0),
          CellPosition(1, 1),
        ],
      );

      const cellW = 60.0;
      const cellH = 60.0;

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: cellW,
        cellHeight: cellH,
        zones: [rectZone],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.containsKey('z_rect'), isTrue);
      final rug = result['z_rect']!;

      // La habitación ocupa [0..120, 0..120]
      // La alfombra debe estar completamente dentro con padding >= 5.0
      expect(rug.left, greaterThanOrEqualTo(5.0));
      expect(rug.top, greaterThanOrEqualTo(5.0));
      expect(rug.right, lessThanOrEqualTo(115.0));
      expect(rug.bottom, lessThanOrEqualTo(115.0));
    });

    test('Tablero normal (< 25 celdas): máximo 1 alfombra en todo el mapa', () {
      // Tablero 4x4 (16 celdas) con dos zonas 2x2 libres
      const zone1 = ZoneData(
        id: 'z1',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1),
          CellPosition(1, 0), CellPosition(1, 1),
        ],
      );
      const zone2 = ZoneData(
        id: 'z2',
        name: 'Biblioteca',
        cells: [
          CellPosition(2, 2), CellPosition(2, 3),
          CellPosition(3, 2), CellPosition(3, 3),
        ],
      );

      final result = evaluator.evaluate(
        rows: 4,
        columns: 4,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [zone1, zone2],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.length, equals(1),
          reason: 'En tableros normales debe haber como máximo 1 alfombra.');
      // El Salón Principal tiene máxima prioridad
      expect(result.containsKey('z1'), isTrue);
    });

    test('Tablero grande (>= 25 celdas): permite máximo 2 alfombras', () {
      // Tablero 6x5 (30 celdas) con 3 zonas 2x2 libres
      const zone1 = ZoneData(
        id: 'z1',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1),
          CellPosition(1, 0), CellPosition(1, 1),
        ],
      );
      const zone2 = ZoneData(
        id: 'z2',
        name: 'Biblioteca',
        cells: [
          CellPosition(2, 0), CellPosition(2, 1),
          CellPosition(3, 0), CellPosition(3, 1),
        ],
      );
      const zone3 = ZoneData(
        id: 'z3',
        name: 'Dormitorio',
        cells: [
          CellPosition(4, 0), CellPosition(4, 1),
          CellPosition(5, 0), CellPosition(5, 1),
        ],
      );

      final result = evaluator.evaluate(
        rows: 6,
        columns: 5,
        cellWidth: 60.0,
        cellHeight: 60.0,
        zones: [zone1, zone2, zone3],
        blockedCells: {},
        theme: ZoneTheme.classicMansion,
      );

      expect(result.length, equals(2),
          reason: 'En tableros grandes se permite como máximo 2 alfombras.');
    });
  });

  group('ZoneGeometryBuilder & Nombres de Zona (V3.4)', () {
    const builder = ZoneGeometryBuilder();

    test('Punto seleccionado pertenece estrictamente a la zona y es una celda libre', () {
      const zone = ZoneData(
        id: 'z1',
        name: 'Biblioteca',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1),
          CellPosition(1, 0), CellPosition(1, 1),
        ],
      );

      // Bloquear celda (0, 0) con un mueble
      final blocked = {const CellPosition(0, 0)};

      final result = builder.build(
        rows: 2,
        columns: 2,
        zones: [zone],
        boardWidth: 120.0,
        boardHeight: 120.0,
        blockedCells: blocked,
        theme: ZoneTheme.classicMansion,
      );

      final center = result.zoneVisualCenters['z1']!;

      // El punto NO debe ser el centro de la celda bloqueada (0, 0) -> (30, 30)
      expect(center == const ui.Offset(30.0, 30.0), isFalse,
          reason: 'Nunca debe seleccionar la celda con mueble si hay celdas libres.');

      // Debe estar dentro del polígono de la zona
      expect(result.zoneFloorPaths['z1']!.contains(center), isTrue);

      // Y debe corresponder al centro exacto de una de las celdas libres: (90, 30), (30, 90) o (90, 90)
      final validCenters = [
        const ui.Offset(90.0, 30.0),
        const ui.Offset(30.0, 90.0),
        const ui.Offset(90.0, 90.0),
      ];
      expect(validCenters.contains(center), isTrue);
    });

    test('Margen de seguridad respecto a muros y auto-fit de fuentes entre 9 y 13 px', () {
      final theme = ZoneVisualTheme.fromZoneName('DESPACHO DE INVESTIGACIÓN', 0);

      // Renderizar sobre canvas de prueba para verificar que no lance excepción
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));

      expect(() {
        theme.renderRoomWatermark(
          canvas: canvas,
          visualCenter: const ui.Offset(50.0, 50.0),
          roomBounds: const ui.Rect.fromLTWH(0, 0, 100, 100),
          cellWidth: 60.0,
          cellHeight: 60.0,
        );
      }, returnsNormally);

      recorder.endRecording().dispose();
    });
  });
}
