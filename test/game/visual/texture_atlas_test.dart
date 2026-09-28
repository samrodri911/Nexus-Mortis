import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/visual/models/sprite_region.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';

void main() {
  group('SpriteRegion & TextureAtlas Models', () {
    test('SpriteRegion calculates rect and aspectRatio correctly', () {
      const region = SpriteRegion(
        name: 'test_chair',
        x: 10,
        y: 20,
        width: 50,
        height: 100,
      );

      expect(region.name, 'test_chair');
      expect(region.x, 10);
      expect(region.y, 20);
      expect(region.width, 50);
      expect(region.height, 100);
      expect(region.rect, const Rect.fromLTWH(10, 20, 50, 100));
      expect(region.aspectRatio, 0.5);
    });

    test('TextureAtlas stores and retrieves regions accurately', () {
      const region1 = SpriteRegion(
        name: 'item_a',
        x: 0,
        y: 0,
        width: 64,
        height: 64,
      );
      const region2 = SpriteRegion(
        name: 'item_b',
        x: 64,
        y: 0,
        width: 128,
        height: 64,
      );

      const atlas = TextureAtlas(
        id: 'test_atlas',
        assetPath: 'assets/test.png',
        regions: {
          'item_a': region1,
          'item_b': region2,
        },
      );

      expect(atlas.id, 'test_atlas');
      expect(atlas.assetPath, 'assets/test.png');
      expect(atlas.containsRegion('item_a'), isTrue);
      expect(atlas.containsRegion('item_b'), isTrue);
      expect(atlas.containsRegion('item_c'), isFalse);
      expect(atlas.getRegion('item_a'), region1);
      expect(atlas.getRegion('item_c'), isNull);
    });
  });

  group('SpriteLayoutHelper', () {
    test('centers sprite strictly in cellRect', () {
      const cellRect = Rect.fromLTWH(100, 200, 80, 80);
      final dest = SpriteLayoutHelper.calculateDestRect(
        cellRect: cellRect,
        srcWidth: 50,
        srcHeight: 100,
        fillRatio: 0.75,
      );

      expect(dest.center.dx, closeTo(cellRect.center.dx, 0.001));
      expect(dest.center.dy, closeTo(cellRect.center.dy, 0.001));
    });

    test('strictly preserves aspect ratio of the source sprite', () {
      const cellRect = Rect.fromLTWH(0, 0, 100, 100);
      const srcW = 60.0;
      const srcH = 120.0;
      final expectedAspect = srcW / srcH; // 0.5

      final dest = SpriteLayoutHelper.calculateDestRect(
        cellRect: cellRect,
        srcWidth: srcW,
        srcHeight: srcH,
        fillRatio: 0.70,
      );

      final resultAspect = dest.width / dest.height;
      expect(resultAspect, closeTo(expectedAspect, 0.001));
    });

    test('enforces fill ratio strictly clamped between 0.65 and 0.80', () {
      const cellRect = Rect.fromLTWH(0, 0, 100, 100);

      // Ratio lower than 0.65 should be clamped to 0.65
      final destMin = SpriteLayoutHelper.calculateDestRect(
        cellRect: cellRect,
        srcWidth: 100,
        srcHeight: 100,
        fillRatio: 0.40,
      );
      expect(destMin.width, closeTo(65.0, 0.001));
      expect(destMin.height, closeTo(65.0, 0.001));

      // Ratio higher than 0.80 should be clamped to 0.80
      final destMax = SpriteLayoutHelper.calculateDestRect(
        cellRect: cellRect,
        srcWidth: 100,
        srcHeight: 100,
        fillRatio: 0.95,
      );
      expect(destMax.width, closeTo(80.0, 0.001));
      expect(destMax.height, closeTo(80.0, 0.001));
    });

    test('scales responsively across different tile sizes', () {
      for (final tileSize in [40.0, 60.0, 80.0, 120.0]) {
        final cellRect = Rect.fromLTWH(0, 0, tileSize, tileSize);
        final dest = SpriteLayoutHelper.calculateDestRect(
          cellRect: cellRect,
          srcWidth: 100,
          srcHeight: 50,
          fillRatio: 0.75,
        );

        expect(dest.width, closeTo(tileSize * 0.75, 0.001));
        expect(dest.height, closeTo(tileSize * 0.75 * 0.5, 0.001));
        expect(dest.center.dx, closeTo(tileSize / 2, 0.001));
        expect(dest.center.dy, closeTo(tileSize / 2, 0.001));
      }
    });
  });
}
