import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/visual/models/furniture_catalog_entry.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';

void main() {
  group('FurnitureCatalog Tests', () {
    final catalog = FurnitureCatalog.instance;

    test('registers exactly the 7 required test items', () {
      final entries = catalog.allEntries;
      expect(entries.length, 7);

      final ids = entries.map((e) => e.id).toSet();
      expect(
        ids,
        containsAll([
          'chair_01',
          'table_01',
          'table_round_01',
          'cabinet_01',
          'refrigerator_01',
          'stove_01',
          'sink_01',
        ]),
      );
    });

    test('all 7 test items have valid regions in kitchenAtlas within 1024x559', () {
      const atlas = FurnitureCatalog.kitchenAtlas;
      expect(atlas.assetPath, 'assets/game/atlases/furniture/furniture_sheet.png');

      const maxSheetWidth = 1024.0;
      const maxSheetHeight = 559.0;

      for (final entry in catalog.allEntries) {
        final region = atlas.getRegion(entry.regionName);
        expect(region, isNotNull, reason: 'Region ${entry.regionName} must exist in kitchenAtlas');

        expect(region!.x, greaterThanOrEqualTo(0));
        expect(region.y, greaterThanOrEqualTo(0));
        expect(region.width, greaterThan(0));
        expect(region.height, greaterThan(0));
        expect(region.x + region.width, lessThanOrEqualTo(maxSheetWidth),
            reason: '${entry.regionName} exceeds atlas width');
        expect(region.y + region.height, lessThanOrEqualTo(maxSheetHeight),
            reason: '${entry.regionName} exceeds atlas height');

        expect(entry.defaultScaleRatio, greaterThanOrEqualTo(0.65));
        expect(entry.defaultScaleRatio, lessThanOrEqualTo(0.80));
      }
    });

    test('findEntryForLogicalObject resolves representations correctly', () {
      expect(catalog.findEntryForLogicalObject('nevera')?.id, 'refrigerator_01');
      expect(catalog.findEntryForLogicalObject('Nevera de acero')?.id, 'refrigerator_01');
      expect(catalog.findEntryForLogicalObject('fregadero_cocina')?.id, 'sink_01');
      expect(catalog.findEntryForLogicalObject('cocina_gas')?.id, 'stove_01');
      expect(catalog.findEntryForLogicalObject('horno_electrico')?.id, 'stove_01');
      expect(catalog.findEntryForLogicalObject('alacena_roble')?.id, 'cabinet_01');
      expect(catalog.findEntryForLogicalObject('mesa_comedor')?.id, 'table_01');
      expect(catalog.findEntryForLogicalObject('mesa_redonda')?.id, 'table_round_01');
      expect(catalog.findEntryForLogicalObject('silla_madera')?.id, 'chair_01');

      // Unrelated or unmapped object returns null or direct match if registered
      expect(catalog.findEntryForLogicalObject('sarcofago'), isNull);
      expect(catalog.findEntryForLogicalObject('vitrina'), isNull);
    });

    test('register permits adding new entries without side-effects', () {
      const newEntry = FurnitureCatalogEntry(
        id: 'test_lamp',
        atlasId: FurnitureCatalog.kitchenAtlasId,
        regionName: 'test_lamp_region',
        category: 'lighting',
        defaultScaleRatio: 0.70,
      );

      catalog.register(newEntry);
      expect(catalog.hasEntry('test_lamp'), isTrue);
      expect(catalog.getEntry('test_lamp')?.category, 'lighting');
    });
  });
}
