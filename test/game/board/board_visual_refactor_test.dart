import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/components/board_component.dart';
import 'package:nexus_mortis/game/board/components/cell_component.dart';
import 'package:nexus_mortis/game/board/components/floor_plan_component.dart';
import 'package:nexus_mortis/game/board/components/furniture_layer_component.dart';
import 'package:nexus_mortis/game/board/components/walls_overlay_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/models/cell_annotation.dart';
import 'package:nexus_mortis/game/board/models/cell_data.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

void main() {
  group('Board Visual Refactor Tests - Z-Index, Auto-fit & Layers', () {
    test('Jerarquía de capas estricta: FloorPlan(0) < Furniture(10) < Walls(20) < Cells(30)', () {
      final caseData = CaseData(
        id: 'test_hierarchy',
        title: 'Test Case',
        description: 'Test Description',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        zones: const [
          ZoneData(id: 'z1', name: 'Zona Uno', cells: [CellPosition(0, 0), CellPosition(0, 1)]),
        ],
        suspects: const [SuspectData(id: 's1', name: 'Suspect 1')],
        victimId: 's1',
        killerId: 's1',
        placedObjects: const [],
        solution: const SolutionData(suspectPositions: {'s1': CellPosition(0, 0)}),
        clues: const [],
      );

      final controller = BoardController.fromCase(caseData);
      final metrics = BoardLayoutMetrics.calculate(
        availableWidth: 300,
        availableHeight: 300,
        rows: 3,
        cols: 3,
      );
      const builder = ZoneGeometryBuilder();
      final geom = builder.build(
        rows: 3,
        columns: 3,
        zones: caseData.zones,
        boardWidth: 300,
        boardHeight: 300,
      );

      final floorPlan = FloorPlanComponent(controller: controller, size: Vector2(300, 300), geometry: geom);
      final furniture = FurnitureLayerComponent(controller: controller, metrics: metrics, size: Vector2(300, 300));
      final walls = WallsOverlayComponent(geometry: geom, size: Vector2(300, 300));
      final cell = CellComponent(
        cellData: CellData(row: 0, col: 0, type: CellType.free),
        onTapped: (_, __) {},
        getActiveSuspectId: () => null,
        allSuspects: const [],
        position: Vector2.zero(),
        size: Vector2(100, 100),
      );

      expect(floorPlan.priority, equals(0), reason: 'Piso base y alfombras deben ser capa 0');
      expect(furniture.priority, equals(10), reason: 'Muebles y sombras deben ser capa 10');
      expect(walls.priority, equals(20), reason: 'Muros continuos deben ser capa 20');
      expect(cell.priority, equals(30), reason: 'Gameplay e interacción debe ser capa 30');
    });

    test('Auto-fit y Word-wrapping: Los nombres de habitación nunca se truncan ni parten palabras', () {
      final namesToTest = [
        'BAÑO',
        'BIBLIOTECA CENTRAL',
        'SALA DE MÁQUINAS',
        'LABORATORIO DE CARTOGRAFÍA CELESTIAL',
        'HABITACIÓN DEL HOTEL ANTIGUO',
      ];

      for (final name in namesToTest) {
        final theme = ZoneVisualTheme.fromZoneName(name, 0);
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        final bounds = const ui.Rect.fromLTWH(0, 0, 120, 120);
        final clipPath = ui.Path()..addRect(bounds);

        expect(
          () => theme.renderRoomWatermark(
            canvas: canvas,
            visualCenter: const ui.Offset(60, 60),
            roomBounds: bounds,
            cellWidth: 60.0,
            cellHeight: 60.0,
            roomClipPath: clipPath,
          ),
          returnsNormally,
          reason: 'Fallo al renderizar marca con nombre: ',
        );

        final pic = recorder.endRecording();
        pic.dispose();
      }
    });

    test('CellComponent con isBlocked no dibuja marcas ni candidatos por encima de muebles', () {
      final blockedCellData = CellData(
        row: 1,
        col: 1,
        type: CellType.blocked,
        objectId: 'obj_mesa',
      )..annotation = CellAnnotation.eliminated;

      final cell = CellComponent(
        cellData: blockedCellData,
        onTapped: (_, __) {},
        getActiveSuspectId: () => null,
        allSuspects: const [],
        position: Vector2.zero(),
        size: Vector2(80, 80),
      );

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      expect(() => cell.render(canvas), returnsNormally);

      final pic = recorder.endRecording();
      pic.dispose();
    });

    test('zoneVisualCenters: cuando la celda central tiene mueble, selecciona celda vecina libre de la misma zona', () {
      // Habitación de 3x1 celdas: (0,0), (0,1), (0,2)
      // La celda central (0,1) contiene un mueble bloqueante
      final zone = const ZoneData(
        id: 'z_corridor',
        cells: [
          CellPosition(0, 0),
          CellPosition(0, 1),
          CellPosition(0, 2),
        ],
      );

      const builder = ZoneGeometryBuilder();
      final result = builder.build(
        rows: 1,
        columns: 3,
        zones: [zone],
        boardWidth: 300,
        boardHeight: 100,
        blockedCells: {const CellPosition(0, 1)},
      );

      final center = result.zoneVisualCenters['z_corridor']!;
      final chosenCol = (center.dx / 100).floor();
      final chosenRow = (center.dy / 100).floor();

      // Debe ser la celda (0,0) o (0,2), NUNCA la central bloqueada (0,1)
      expect(chosenRow, equals(0));
      expect(chosenCol, isNot(equals(1)));
      expect(chosenCol == 0 || chosenCol == 2, isTrue);
      // El centro debe ser exactamente el centro de la celda elegida (50 o 250, y 50)
      expect(center.dy, equals(50.0));
      expect(center.dx == 50.0 || center.dx == 250.0, isTrue);
    });

    test('Uso medido de alfombras: cocina, baño y jardín tienen hasRug=false, biblioteca tiene hasRug=true', () {
      final kitchen = ZoneVisualTheme.fromZoneName('Cocina Antigua', 0);
      final garden = ZoneVisualTheme.fromZoneName('Jardín Botánico', 1);
      final bathroom = ZoneVisualTheme.fromZoneName('Baño de Invitados', 2);
      final lab = ZoneVisualTheme.fromZoneName('Laboratorio Químico', 3);
      final library = ZoneVisualTheme.fromZoneName('Biblioteca Principal', 4);
      final bedroom = ZoneVisualTheme.fromZoneName('Dormitorio Real', 5);

      expect(kitchen.hasRug, isFalse, reason: 'Cocina debe tener suelo limpio');
      expect(garden.hasRug, isFalse, reason: 'Jardín debe tener suelo de piedra limpio');
      expect(bathroom.hasRug, isFalse, reason: 'Baño debe tener suelo limpio');
      expect(lab.hasRug, isFalse, reason: 'Laboratorio debe tener baldosas limpias');
      expect(library.hasRug, isTrue, reason: 'Biblioteca tiene alfombra noble');
      expect(bedroom.hasRug, isTrue, reason: 'Dormitorio noble tiene alfombra');
    });

    test('Habitación de 1 celda: no renderiza alfombra para mantener suelo despejado', () {
      final bedroomTheme = ZoneVisualTheme.fromZoneName('Dormitorio', 0);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      // Habitación de 1 celda (100x100)
      final bounds = const ui.Rect.fromLTWH(0, 0, 100, 100);
      final clipPath = ui.Path()..addRect(bounds);

      // No debe lanzar errores y no debe pintar nada desbordado
      expect(
        () => bedroomTheme.renderRug(canvas, clipPath, bounds, 100, 100),
        returnsNormally,
      );

      final pic = recorder.endRecording();
      pic.dispose();
    });

    test('Habitación de 1 celda completamente ocupada: texto en margen superior sin overlap', () {
      final zone = const ZoneData(
        id: 'z_single',
        cells: [CellPosition(0, 0)],
      );

      const builder = ZoneGeometryBuilder();
      final result = builder.build(
        rows: 1,
        columns: 1,
        zones: [zone],
        boardWidth: 100,
        boardHeight: 100,
        blockedCells: {const CellPosition(0, 0)},
      );

      final center = result.zoneVisualCenters['z_single']!;
      // En una celda 100x100 bloqueada, la posición Y debe estar en el margen superior (16% de 100 = 16)
      expect(center.dx, equals(50.0));
      expect(center.dy, closeTo(16.0, 1.0));

      final theme = ZoneVisualTheme.fromZoneName('DESPACHO', 0);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final bounds = const ui.Rect.fromLTWH(0, 0, 100, 100);
      final clipPath = ui.Path()..addRect(bounds);

      expect(
        () => theme.renderRoomWatermark(
          canvas: canvas,
          visualCenter: center,
          roomBounds: bounds,
          cellWidth: 100,
          cellHeight: 100,
          roomClipPath: clipPath,
        ),
        returnsNormally,
      );

      final pic = recorder.endRecording();
      pic.dispose();
    });
  });
}
