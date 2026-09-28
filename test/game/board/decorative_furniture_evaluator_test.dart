import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/services/decorative_furniture_evaluator.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DecorativeFurnitureEvaluator Tests (V3.5)', () {
    const evaluator = DecorativeFurnitureEvaluator();

    test('Habitación pequeña (<= 2 celdas) nunca recibe mobiliario decorativo', () {
      const smallZone = ZoneData(
        id: 'z_small',
        name: 'Vestíbulo',
        cells: [CellPosition(0, 0), CellPosition(0, 1)],
      );

      final items = evaluator.evaluate(
        rows: 4,
        columns: 4,
        zones: [smallZone],
        blockedCells: {},
        zoneVisualCenters: {'z_small': const ui.Offset(30, 30)},
        zoneRugRects: {},
        theme: ZoneTheme.classicMansion,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      expect(items, isEmpty, reason: 'Habitaciones de 2 o menos celdas deben permanecer despejadas');
    });

    test('Habitación con >= 2 objetos lógicos nunca recibe decoraciones adicionales', () {
      const largeZone = ZoneData(
        id: 'z_large',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
          CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
        ],
      );

      // Bloquear 2 celdas con objetos lógicos
      final blocked = {const CellPosition(0, 0), const CellPosition(1, 2)};

      final items = evaluator.evaluate(
        rows: 4,
        columns: 4,
        zones: [largeZone],
        blockedCells: blocked,
        zoneVisualCenters: {'z_large': const ui.Offset(90, 90)},
        zoneRugRects: {},
        theme: ZoneTheme.classicMansion,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      expect(items, isEmpty, reason: 'Si ya hay 2 objetos lógicos, no se satura con decoraciones');
    });

    test('Habitación con 1 objeto lógico en sala grande (>= 5 celdas) recibe como máximo 1 decoración', () {
      const largeZone = ZoneData(
        id: 'z_gallery',
        name: 'Galería de Arte',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
          CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
        ],
      );

      final blocked = {const CellPosition(0, 0)};

      final items = evaluator.evaluate(
        rows: 4,
        columns: 4,
        zones: [largeZone],
        blockedCells: blocked,
        zoneVisualCenters: {'z_gallery': const ui.Offset(90, 90)},
        zoneRugRects: {},
        theme: ZoneTheme.museumArchive,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      expect(items.length, equals(1), reason: 'Una sala grande con 1 objeto lógico recibe exactamente 1 decoración adicional');
      expect(items.first.zoneId, equals('z_gallery'));
      expect(blocked.contains(items.first.position), isFalse, reason: 'Nunca sobre celda bloqueada');
    });

    test('Nunca coloca mobiliario decorativo sobre celdas bloqueadas ni sobre el nombre de zona', () {
      const zone = ZoneData(
        id: 'z_study',
        name: 'Biblioteca',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1),
          CellPosition(1, 0), CellPosition(1, 1),
        ],
      );

      // Celda (0,0) tiene nombre de zona en pixel (30, 30)
      final visualCenters = {'z_study': const ui.Offset(30.0, 30.0)};
      // Celda (0,1) está bloqueada por objeto lógico
      final blocked = {const CellPosition(0, 1)};

      final items = evaluator.evaluate(
        rows: 2,
        columns: 2,
        zones: [zone],
        blockedCells: blocked,
        zoneVisualCenters: visualCenters,
        zoneRugRects: {},
        theme: ZoneTheme.classicMansion,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      for (final item in items) {
        expect(item.position, isNot(equals(const CellPosition(0, 0))),
            reason: 'No debe coincidir con la celda del texto de la habitación');
        expect(item.position, isNot(equals(const CellPosition(0, 1))),
            reason: 'No debe coincidir con celda bloqueada');
      }
    });

    test('Nunca coloca mobiliario decorativo sobre una alfombra existente', () {
      const zone = ZoneData(
        id: 'z_mansion',
        name: 'Salón Principal',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
          CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
        ],
      );

      // Alfombra en el bloque 2x2 izquierdo: x=[0..120], y=[0..120] -> celdas (0,0), (0,1), (1,0), (1,1)
      final rugRects = {'z_mansion': const ui.Rect.fromLTWH(6.0, 6.0, 108.0, 108.0)};

      final items = evaluator.evaluate(
        rows: 2,
        columns: 3,
        zones: [zone],
        blockedCells: {},
        zoneVisualCenters: {'z_mansion': const ui.Offset(150.0, 30.0)}, // celda (0, 2)
        zoneRugRects: rugRects,
        theme: ZoneTheme.classicMansion,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      for (final item in items) {
        final cellRect = ui.Rect.fromLTWH(item.position.col * 60.0, item.position.row * 60.0, 60.0, 60.0);
        expect(rugRects['z_mansion']!.overlaps(cellRect), isFalse,
            reason: 'El mueble decorativo no debe superponerse a la alfombra');
      }
    });

    test('Afinidad temática estricta por set temático', () {
      const museumZone = ZoneData(
        id: 'z_mus',
        name: 'Galería de Arte',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
          CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
        ],
      );

      final museumItems = evaluator.evaluate(
        rows: 2,
        columns: 3,
        zones: [museumZone],
        blockedCells: {},
        zoneVisualCenters: {},
        zoneRugRects: {},
        theme: ZoneTheme.museumArchive,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      final validMuseumObjects = {'obj_caballete', 'obj_vitrina', 'obj_estatua', 'obj_pedestal', 'obj_anfora', 'obj_sarcofago'};
      for (final item in museumItems) {
        expect(validMuseumObjects.contains(item.objectId), isTrue,
            reason: 'Objeto "${item.objectId}" debe pertenecer a la temática de Museo');
      }

      const theaterZone = ZoneData(
        id: 'z_theat',
        name: 'Escenario',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
          CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
        ],
      );

      final theaterItems = evaluator.evaluate(
        rows: 2,
        columns: 3,
        zones: [theaterZone],
        blockedCells: {},
        zoneVisualCenters: {},
        zoneRugRects: {},
        theme: ZoneTheme.theaterOpera,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      final validTheaterObjects = {'obj_atril', 'obj_foco', 'obj_pedestal', 'obj_silla_terciopelo', 'obj_columna', 'obj_lampara'};
      for (final item in theaterItems) {
        expect(validTheaterObjects.contains(item.objectId), isTrue,
            reason: 'Objeto "${item.objectId}" debe pertenecer a la temática de Teatro/Ópera');
      }
    });

    test('Determinismo absoluto: múltiples evaluaciones producen resultados idénticos', () {
      const zoneA = ZoneData(
        id: 'z_a',
        name: 'Rosaleda',
        cells: [
          CellPosition(0, 0), CellPosition(0, 1),
          CellPosition(1, 0), CellPosition(1, 1),
        ],
      );

      final run1 = evaluator.evaluate(
        rows: 2,
        columns: 2,
        zones: [zoneA],
        blockedCells: {},
        zoneVisualCenters: {'z_a': const ui.Offset(30, 30)},
        zoneRugRects: {},
        theme: ZoneTheme.botanicalGarden,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      final run2 = evaluator.evaluate(
        rows: 2,
        columns: 2,
        zones: [zoneA],
        blockedCells: {},
        zoneVisualCenters: {'z_a': const ui.Offset(30, 30)},
        zoneRugRects: {},
        theme: ZoneTheme.botanicalGarden,
        cellWidth: 60.0,
        cellHeight: 60.0,
      );

      expect(run1.length, equals(run2.length));
      for (int i = 0; i < run1.length; i++) {
        expect(run1[i].position, equals(run2[i].position));
        expect(run1[i].objectId, equals(run2[i].objectId));
      }
    });
  });
}
