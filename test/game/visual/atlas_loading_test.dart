import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/visual/models/sprite_region.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AtlasManager.instance.clear();
  });

  group('AtlasManager Unit Tests', () {
    test('manual registration and sprite caching', () async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, 100, 100));
      canvas.drawColor(const ui.Color(0xFFFFFFFF), ui.BlendMode.src);
      final picture = recorder.endRecording();
      final mockImage = await picture.toImage(100, 100);

      const testAtlas = TextureAtlas(
        id: 'mock_atlas',
        assetPath: 'assets/mock.png',
        regions: {
          'mock_item': SpriteRegion(
            name: 'mock_item',
            x: 10,
            y: 10,
            width: 20,
            height: 20,
          ),
        },
      );

      final loadedAtlas = LoadedAtlas(definition: testAtlas, image: mockImage);
      AtlasManager.instance.registerLoadedAtlas(loadedAtlas);

      expect(AtlasManager.instance.isLoaded('mock_atlas'), isTrue);
      expect(AtlasManager.instance.isLoaded('non_existent'), isFalse);

      final sprite = AtlasManager.instance.getSprite('mock_atlas', 'mock_item');
      expect(sprite, isNotNull);
      expect(sprite!.srcPosition.x, 10);
      expect(sprite.srcPosition.y, 10);
      expect(sprite.srcSize.x, 20);
      expect(sprite.srcSize.y, 20);

      // Caching: same sprite instance returned
      final spriteAgain = AtlasManager.instance.getSprite('mock_atlas', 'mock_item');
      expect(identical(sprite, spriteAgain), isTrue);

      // Clear clears cache
      AtlasManager.instance.clear();
      expect(AtlasManager.instance.isLoaded('mock_atlas'), isFalse);
    });

    test('loads real furniture_sheet.png and creates Flame Sprites for 7 items', () async {
      final loaded = await AtlasManager.instance.loadAtlas(FurnitureCatalog.kitchenAtlas);

      expect(loaded, isNotNull);
      expect(loaded.image.width, 1024);
      expect(loaded.image.height, 559);
      expect(AtlasManager.instance.isLoaded(FurnitureCatalog.kitchenAtlasId), isTrue);

      for (final entry in FurnitureCatalog.instance.allEntries) {
        final sprite = AtlasManager.instance.getSprite(entry.atlasId, entry.regionName);
        expect(sprite, isNotNull, reason: 'Sprite for ${entry.regionName} should be loaded');
        expect(sprite!.image, loaded.image);
        expect(sprite.srcSize.x, greaterThan(0));
        expect(sprite.srcSize.y, greaterThan(0));
      }
    });
  });
}
