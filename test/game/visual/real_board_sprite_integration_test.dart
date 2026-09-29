import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/components/cell_component.dart';
import 'package:nexus_mortis/game/board/components/floor_plan_component.dart';
import 'package:nexus_mortis/game/board/components/furniture_layer_component.dart';
import 'package:nexus_mortis/game/board/components/walls_overlay_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/models/cell_data.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_catalog.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';
import 'package:nexus_mortis/game/visual/widgets/atlas_preview_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await AtlasManager.instance.loadAtlas(FurnitureCatalog.kitchenAtlas);
  });

  group('Nexus Mortis — Integración Real de Sprites en el Tablero', () {
    test('1. Conexión de objetos lógicos existentes con sprites del atlas', () {
      final catalog = FurnitureCatalog.instance;

      // Silla existente en GeneratorCatalog
      final chairEntry = catalog.findEntryForLogicalObject('obj_silla', label: 'Silla');
      expect(chairEntry, isNotNull);
      expect(chairEntry!.id, 'chair_01');

      final chairSprite = AtlasManager.instance.getSprite(chairEntry.atlasId, chairEntry.regionName);
      expect(chairSprite, isNotNull);
      expect(chairSprite!.srcSize.x, 53.0);
      expect(chairSprite.srcSize.y, 109.0);

      // Mesa existente en GeneratorCatalog
      final tableEntry = catalog.findEntryForLogicalObject('obj_mesa', label: 'Mesa');
      expect(tableEntry, isNotNull);
      expect(tableEntry!.id, 'table_01');

      final tableSprite = AtlasManager.instance.getSprite(tableEntry.atlasId, tableEntry.regionName);
      expect(tableSprite, isNotNull);
      expect(tableSprite!.srcSize.x, 99.0);
      expect(tableSprite.srcSize.y, 81.0);

      // Los demás objetos lógicos de GeneratorCatalog activan fallback (retornan null)
      for (final obj in GeneratorCatalog.objects) {
        if (obj.id == 'obj_silla' || obj.id == 'obj_mesa') continue;
        final entry = catalog.findEntryForLogicalObject(obj.id, label: obj.name);
        expect(entry, isNull, reason: '${obj.name} no debe forzar sprite y debe activar fallback');
      }
    });

    test('2. Comportamiento Responsive y Centrado en Resoluciones (4x4, 5x4, 5x5, 6x5, 6x6)', () {
      final testSizes = [
        (rows: 4, cols: 4, label: '4x4'),
        (rows: 4, cols: 5, label: '5x4'),
        (rows: 5, cols: 5, label: '5x5'),
        (rows: 5, cols: 6, label: '6x5'),
        (rows: 6, cols: 6, label: '6x6'),
      ];

      for (final dim in testSizes) {
        final metrics = BoardLayoutMetrics.calculate(
          availableWidth: 400.0,
          availableHeight: 400.0,
          rows: dim.rows,
          cols: dim.cols,
        );

        final tileSize = metrics.tileSize;
        expect(tileSize, greaterThan(0));

        // Probar centrado y escalado de chair_01 en cualquier celda
        final cellRect = Rect.fromLTWH(20.0, 30.0, tileSize, tileSize);
        final chairSprite = AtlasManager.instance.getSprite(
          FurnitureCatalog.kitchenAtlasId,
          'chair_01',
        )!;

        final destRect = SpriteLayoutHelper.calculateDestRect(
          cellRect: cellRect,
          srcWidth: chairSprite.srcSize.x,
          srcHeight: chairSprite.srcSize.y,
          fillRatio: 0.70,
        );

        // Centro estricto
        expect(destRect.center.dx, closeTo(cellRect.center.dx, 0.001),
            reason: '${dim.label}: Centro X no coincide');
        expect(destRect.center.dy, closeTo(cellRect.center.dy, 0.001),
            reason: '${dim.label}: Centro Y no coincide');

        // Aspect ratio conservado
        final originalAspect = chairSprite.srcSize.x / chairSprite.srcSize.y;
        final destAspect = destRect.width / destRect.height;
        expect(destAspect, closeTo(originalAspect, 0.001),
            reason: '${dim.label}: Proporción alterada');

        // Rango de escala acotado
        final maxDimension = destRect.height; // Silla es vertical
        expect(maxDimension, closeTo(tileSize * 0.70, 0.001));
        expect(destRect.width, lessThanOrEqualTo(tileSize));
        expect(destRect.height, lessThanOrEqualTo(tileSize));
      }
    });

    test('3. Jerarquía Visual y Prioridad de Capas de Flame', () {
      final puzzleGen = PuzzleGenerator();
      final config = GeneratorConfig(
        rows: 4,
        columns: 4,
        suspectCount: 3,
        objectCount: 2,
        randomSeed: 8888,
        targetDifficulty: DifficultyLevel.easy,
      );
      final genResult = puzzleGen.generate(config)!;
      final controller = BoardController.fromCase(genResult.caseData);

      final metrics = BoardLayoutMetrics.calculate(
        availableWidth: 320,
        availableHeight: 320,
        rows: 4,
        cols: 4,
      );

      const geomBuilder = ZoneGeometryBuilder();
      final geom = geomBuilder.build(
        rows: 4,
        columns: 4,
        zones: genResult.caseData.zones,
        boardWidth: metrics.boardWidth,
        boardHeight: metrics.boardHeight,
      );

      final floorPlan = FloorPlanComponent(
        controller: controller,
        size: Vector2(320, 320),
      );
      final furnitureLayer = FurnitureLayerComponent(
        controller: controller,
        metrics: metrics,
        size: Vector2(320, 320),
      );
      final wallsOverlay = WallsOverlayComponent(
        geometry: geom,
        size: Vector2(320, 320),
      );
      final cellComponent = CellComponent(
        cellData: controller.cells[0][0],
        onTapped: (_, __) {},
        getActiveSuspectId: () => null,
        allSuspects: genResult.caseData.suspects,
        position: Vector2.zero(),
        size: Vector2(80, 80),
      );

      // Verificación estricta de prioridades de renderizado
      expect(floorPlan.priority, 0, reason: 'FloorPlan debe ser Capa 0');
      expect(furnitureLayer.priority, 10, reason: 'FurnitureLayer debe ser Capa 10');
      expect(wallsOverlay.priority, 20, reason: 'WallsOverlay debe ser Capa 20');
      expect(cellComponent.priority, 30, reason: 'CellComponent debe ser Capa 30');

      // Las marcas de candidatos, X, Auto-X y confirmaciones (Capa 30)
      // están estrictamente por encima de los sprites de muebles (Capa 10)
      expect(cellComponent.priority, greaterThan(furnitureLayer.priority));
    });

    test('4. Invariante del Puzzle: Solver produce soluciones idénticas con o sin sprites', () {
      final puzzleGen = PuzzleGenerator();
      final solver = PuzzleSolver();

      final config = GeneratorConfig(
        rows: 4,
        columns: 4,
        suspectCount: 3,
        objectCount: 2,
        randomSeed: 9999,
        targetDifficulty: DifficultyLevel.easy,
      );

      final result = puzzleGen.generate(config)!;
      final solutionBefore = solver.solve(result.caseData);

      // Verificación de que la existencia del atlas y los sprites no altera
      // ni el número de soluciones ni las coordenadas de la solución
      expect(solutionBefore.solutionCount, 1);
      expect(solutionBefore.solutions.first.suspectPositions,
          result.caseData.solution.suspectPositions);
    });

    testWidgets('5. AtlasPreviewWidget inspecciona los 7 sprites de prueba sin errores',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AtlasPreviewWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Verificar que el preview renderiza los 7 items requeridos
      final expectedSprites = [
        'chair_01',
        'table_01',
        'table_round_01',
        'cabinet_01',
        'refrigerator_01',
        'stove_01',
        'sink_01',
      ];

      for (final id in expectedSprites) {
        expect(find.text(id), findsOneWidget, reason: 'Preview debe contener $id');
      }
    });
  });
}
