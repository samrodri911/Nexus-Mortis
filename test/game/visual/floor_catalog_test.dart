import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/visual/models/floor_catalog_entry.dart';
import 'package:nexus_mortis/game/visual/services/floor_catalog.dart';

void main() {
  group('FloorCatalog', () {
    final catalog = FloorCatalog.instance;

    test('initial entries are pre-registered', () {
      expect(catalog.allEntries, isNotEmpty);
      expect(catalog.hasEntry('wood_parquet'), isTrue);
      expect(catalog.hasEntry('wood_planks'), isTrue);
      expect(catalog.hasEntry('tile_kitchen'), isTrue);
      expect(catalog.hasEntry('tile_checkerboard'), isTrue);
      expect(catalog.hasEntry('stone_ancient'), isTrue);
      expect(catalog.hasEntry('marble_hall'), isTrue);
      expect(catalog.hasEntry('carpet_lounge'), isTrue);
    });

    test('each pre-registered entry has valid fallbackTileType', () {
      for (final entry in catalog.allEntries) {
        expect(TileType.values.contains(entry.fallbackTileType), isTrue);
        expect(entry.displayName, isNotEmpty);
      }
    });

    test('resolveTileType returns correct fallback', () {
      expect(catalog.resolveTileType('wood_parquet'), equals(TileType.woodPlanks));
      expect(catalog.resolveTileType('tile_kitchen'), equals(TileType.checkerboard));
      expect(catalog.resolveTileType('stone_ancient'), equals(TileType.stone));
      expect(catalog.resolveTileType('marble_hall'), equals(TileType.classicTiles));
      expect(catalog.resolveTileType('carpet_lounge'), equals(TileType.carpet));
    });

    test('resolveTileType returns safe default fallback for unknown floor', () {
      expect(catalog.resolveTileType('unknown_floor_xyz'), equals(TileType.classicTiles));
    });

    test('getFloorForTileType returns matching entry for every TileType', () {
      for (final type in TileType.values) {
        final entry = catalog.getFloorForTileType(type);
        expect(entry, isNotNull);
        expect(entry.fallbackTileType, equals(type));
      }
    });

    test('can register and retrieve custom floor entry', () {
      const custom = FloorCatalogEntry(
        id: 'custom_bamboo',
        displayName: 'Bambú Pálido',
        fallbackTileType: TileType.woodPlanks,
        atlasId: 'floors_asian',
        regionName: 'bamboo_01',
      );
      catalog.register(custom);

      expect(catalog.hasEntry('custom_bamboo'), isTrue);
      final retrieved = catalog.getEntry('custom_bamboo');
      expect(retrieved, isNotNull);
      expect(retrieved!.displayName, equals('Bambú Pálido'));
      expect(retrieved.hasSprite, isTrue);
      expect(catalog.resolveTileType('custom_bamboo'), equals(TileType.woodPlanks));
    });
  });
}
