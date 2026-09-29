import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/visual/models/decoration_catalog_entry.dart';
import 'package:nexus_mortis/game/visual/services/decoration_catalog.dart';

void main() {
  group('DecorationCatalog', () {
    final catalog = DecorationCatalog.instance;

    test('can register and retrieve entries', () {
      const entry = DecorationCatalogEntry(
        id: 'plant_fern_01',
        atlasId: 'decorations_plants',
        regionName: 'fern_01',
        category: 'plant',
        defaultScaleRatio: 0.70,
      );

      catalog.register(entry);

      expect(catalog.hasEntry('plant_fern_01'), isTrue);
      expect(catalog.getEntry('plant_fern_01'), equals(entry));
      expect(catalog.allEntries.contains(entry), isTrue);
    });

    test('findEntryForDecoration returns entry if registered, null otherwise', () {
      const entry = DecorationCatalogEntry(
        id: 'curiosity_globe',
        atlasId: 'decorations_mansion',
        regionName: 'globe_01',
      );
      catalog.register(entry);

      expect(catalog.findEntryForDecoration('curiosity_globe'), equals(entry));
      expect(catalog.findEntryForDecoration('unregistered_dec_xyz'), isNull);
    });

    test('entry scale ratio default is within required bounds [0.65, 0.80]', () {
      const entry = DecorationCatalogEntry(
        id: 'test_default_scale',
        atlasId: 'atlas_test',
        regionName: 'region_test',
      );
      expect(entry.defaultScaleRatio, greaterThanOrEqualTo(0.65));
      expect(entry.defaultScaleRatio, lessThanOrEqualTo(0.80));
    });
  });
}
