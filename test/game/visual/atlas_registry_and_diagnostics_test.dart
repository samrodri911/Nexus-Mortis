import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/visual/models/sprite_region.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/atlas_registry.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';

void main() {
  group('AtlasRegistry & Diagnostics Tests', () {
    test('AtlasRegistry pre-registra los atlas por defecto', () {
      final registry = AtlasRegistry.instance;
      expect(registry.hasAtlas(FurnitureCatalog.kitchenAtlasId), isTrue);
      expect(registry.hasAtlas('decorations_general'), isTrue);
      expect(registry.hasAtlas('floors_general'), isTrue);
      expect(registry.hasAtlas('architecture_general'), isTrue);
    });

    test('AtlasRegistry permite registrar nuevos atlas y regiones dinámicamente', () {
      final registry = AtlasRegistry.instance;
      const testAtlas = TextureAtlas(
        id: 'test_custom_atlas',
        assetPath: 'assets/game/atlases/furniture/custom_sheet.png',
        regions: {
          'sample_01': SpriteRegion(name: 'sample_01', x: 0, y: 0, width: 32, height: 32),
        },
      );
      registry.registerAtlas(testAtlas);

      expect(registry.hasAtlas('test_custom_atlas'), isTrue);
      expect(registry.getAtlas('test_custom_atlas')?.containsRegion('sample_01'), isTrue);

      // Añadir una nueva región dinámicamente
      const sample2 = SpriteRegion(name: 'sample_02', x: 32, y: 0, width: 32, height: 32);
      registry.registerRegion('test_custom_atlas', sample2);
      expect(registry.getAtlas('test_custom_atlas')?.containsRegion('sample_02'), isTrue);
    });

    test('AtlasValidationResult diagnostica correctamente un atlas geométricamente válido', () async {
      // Crear una imagen simulada en memoria de 1024x559 px
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 1024, 559), ui.Paint());
      final image = await recorder.endRecording().toImage(1024, 559);

      final loadedAtlas = LoadedAtlas(
        definition: FurnitureCatalog.kitchenAtlas,
        image: image,
      );

      final diag = loadedAtlas.validate();
      expect(diag.isValid, isTrue);
      expect(diag.errors, isEmpty);
      expect(diag.validRegions.length, equals(7));
      expect(diag.imageWidth, equals(1024.0));
      expect(diag.imageHeight, equals(559.0));
    });

    test('AtlasValidationResult detecta regiones fuera de los límites de la imagen', () async {
      // Imagen de solo 100x100 px con regiones que la superan
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 100, 100), ui.Paint());
      final image = await recorder.endRecording().toImage(100, 100);

      const faultyAtlas = TextureAtlas(
        id: 'faulty_test_atlas',
        assetPath: 'dummy.png',
        regions: {
          'out_of_bounds': SpriteRegion(name: 'out_of_bounds', x: 80, y: 80, width: 50, height: 50),
          'negative_coords': SpriteRegion(name: 'negative_coords', x: -5, y: 10, width: 20, height: 20),
          'zero_dimension': SpriteRegion(name: 'zero_dimension', x: 10, y: 10, width: 0, height: 20),
          'valid_one': SpriteRegion(name: 'valid_one', x: 10, y: 10, width: 20, height: 20),
        },
      );

      final loaded = LoadedAtlas(definition: faultyAtlas, image: image);
      final diag = loaded.validate();

      expect(diag.isValid, isFalse);
      expect(diag.errors.length, equals(3));
      expect(diag.errors.any((e) => e.contains('out_of_bounds')), isTrue);
      expect(diag.errors.any((e) => e.contains('negative_coords')), isTrue);
      expect(diag.errors.any((e) => e.contains('zero_dimension')), isTrue);
      expect(diag.validRegions, contains('valid_one'));
    });

    test('AtlasManager.validateAtlas devuelve el diagnóstico o null si no está cargado', () async {
      final manager = AtlasManager.instance;
      expect(manager.validateAtlas('non_existent_id'), isNull);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 50, 50), ui.Paint());
      final image = await recorder.endRecording().toImage(50, 50);

      const atlasDef = TextureAtlas(
        id: 'test_validate_manager',
        assetPath: 'test.png',
        regions: {
          'r1': SpriteRegion(name: 'r1', x: 0, y: 0, width: 20, height: 20),
        },
      );
      manager.registerLoadedAtlas(LoadedAtlas(definition: atlasDef, image: image));

      final result = manager.validateAtlas('test_validate_manager');
      expect(result, isNotNull);
      expect(result!.isValid, isTrue);
      expect(result.validRegions, contains('r1'));
    });
  });
}
