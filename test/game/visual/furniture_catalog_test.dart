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

    test('findEntryForLogicalObject resolves existing objects and falls back correctly', () {
      // Objetos lógicos reales que tienen sprite
      expect(catalog.findEntryForLogicalObject('obj_silla')?.id, 'chair_01');
      expect(catalog.findEntryForLogicalObject('silla_madera', label: 'Silla')?.id, 'chair_01');
      expect(catalog.findEntryForLogicalObject('obj_mesa')?.id, 'table_01');
      expect(catalog.findEntryForLogicalObject('mesa_comedor', label: 'Mesa')?.id, 'table_01');

      // Consulta directa por ID de catálogo
      expect(catalog.findEntryForLogicalObject('chair_01')?.id, 'chair_01');
      expect(catalog.findEntryForLogicalObject('table_01')?.id, 'table_01');
      expect(catalog.findEntryForLogicalObject('table_round_01')?.id, 'table_round_01');
      expect(catalog.findEntryForLogicalObject('cabinet_01')?.id, 'cabinet_01');
      expect(catalog.findEntryForLogicalObject('refrigerator_01')?.id, 'refrigerator_01');
      expect(catalog.findEntryForLogicalObject('stove_01')?.id, 'stove_01');
      expect(catalog.findEntryForLogicalObject('sink_01')?.id, 'sink_01');

      // Objetos sin correspondencia en los 7 sprites de prueba retornan null para activar fallback
      expect(catalog.findEntryForLogicalObject('obj_cama'), isNull);
      expect(catalog.findEntryForLogicalObject('obj_librero'), isNull);
      expect(catalog.findEntryForLogicalObject('obj_armario'), isNull);
      expect(catalog.findEntryForLogicalObject('obj_escritorio'), isNull);
      expect(catalog.findEntryForLogicalObject('obj_caja'), isNull);
      expect(catalog.findEntryForLogicalObject('obj_lampara'), isNull);
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
