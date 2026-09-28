import 'package:nexus_mortis/game/visual/models/furniture_catalog_entry.dart';
import 'package:nexus_mortis/game/visual/models/sprite_region.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';

/// Catálogo visual de mobiliario para Nexus Mortis.
///
/// Este catálogo es **estrictamente presentacional**:
/// - NO crea ni modifica objetos lógicos, [CaseData], [CellData] ni [GroundTruth].
/// - Actúa exclusivamente como registro y mapeo de sprites visuales para renderizado.
class FurnitureCatalog {
  FurnitureCatalog._() {
    _registerInitialEntries();
  }

  static final FurnitureCatalog instance = FurnitureCatalog._();

  /// Identificador canónico del atlas de muebles de cocina.
  static const String kitchenAtlasId = 'furniture_kitchen';

  /// Ruta al asset de la hoja de texturas de cocina.
  static const String kitchenAtlasPath =
      'assets/game/atlases/furniture/furniture_sheet.png';

  /// Definición explícita y documentada de las 7 regiones de prueba en [kitchenAtlasPath].
  ///
  /// Dimensiones totales de la imagen fuente: 1024 × 559 píxeles (RGBA).
  static const TextureAtlas kitchenAtlas = TextureAtlas(
    id: kitchenAtlasId,
    assetPath: kitchenAtlasPath,
    regions: {
      // 1. Silla de comedor con cojín (vista top-down 2.5D)
      'chair_01': SpriteRegion(
        name: 'chair_01',
        x: 769.0,
        y: 302.0,
        width: 53.0,
        height: 109.0,
      ),
      // 2. Mesa cuadrada de madera
      'table_01': SpriteRegion(
        name: 'table_01',
        x: 231.0,
        y: 316.0,
        width: 99.0,
        height: 81.0,
      ),
      // 3. Mesa redonda de comedor
      'table_round_01': SpriteRegion(
        name: 'table_round_01',
        x: 413.0,
        y: 305.0,
        width: 106.0,
        height: 102.0,
      ),
      // 4. Alacena / armario de cocina en roble
      'cabinet_01': SpriteRegion(
        name: 'cabinet_01',
        x: 247.0,
        y: 149.0,
        width: 67.0,
        height: 132.0,
      ),
      // 5. Nevera moderna de acero inoxidable
      'refrigerator_01': SpriteRegion(
        name: 'refrigerator_01',
        x: 912.0,
        y: 12.0,
        width: 71.0,
        height: 124.0,
      ),
      // 6. Cocina eléctrica con horno
      'stove_01': SpriteRegion(
        name: 'stove_01',
        x: 55.0,
        y: 437.0,
        width: 74.0,
        height: 108.0,
      ),
      // 7. Fregadero con grifo cromado
      'sink_01': SpriteRegion(
        name: 'sink_01',
        x: 592.0,
        y: 434.0,
        width: 92.0,
        height: 111.0,
      ),
    },
  );

  final Map<String, FurnitureCatalogEntry> _entries = {};

  void _registerInitialEntries() {
    register(const FurnitureCatalogEntry(
      id: 'chair_01',
      atlasId: kitchenAtlasId,
      regionName: 'chair_01',
      category: 'chair',
      defaultScaleRatio: 0.70,
    ));
    register(const FurnitureCatalogEntry(
      id: 'table_01',
      atlasId: kitchenAtlasId,
      regionName: 'table_01',
      category: 'table',
      defaultScaleRatio: 0.75,
    ));
    register(const FurnitureCatalogEntry(
      id: 'table_round_01',
      atlasId: kitchenAtlasId,
      regionName: 'table_round_01',
      category: 'table',
      defaultScaleRatio: 0.75,
    ));
    register(const FurnitureCatalogEntry(
      id: 'cabinet_01',
      atlasId: kitchenAtlasId,
      regionName: 'cabinet_01',
      category: 'cabinet',
      defaultScaleRatio: 0.75,
    ));
    register(const FurnitureCatalogEntry(
      id: 'refrigerator_01',
      atlasId: kitchenAtlasId,
      regionName: 'refrigerator_01',
      category: 'appliance',
      defaultScaleRatio: 0.75,
    ));
    register(const FurnitureCatalogEntry(
      id: 'stove_01',
      atlasId: kitchenAtlasId,
      regionName: 'stove_01',
      category: 'appliance',
      defaultScaleRatio: 0.75,
    ));
    register(const FurnitureCatalogEntry(
      id: 'sink_01',
      atlasId: kitchenAtlasId,
      regionName: 'sink_01',
      category: 'plumbing',
      defaultScaleRatio: 0.75,
    ));
  }

  /// Registra una nueva entrada en el catálogo.
  void register(FurnitureCatalogEntry entry) {
    _entries[entry.id] = entry;
  }

  /// Obtiene una entrada del catálogo por su ID.
  FurnitureCatalogEntry? getEntry(String id) => _entries[id];

  /// Verifica si existe una entrada con el ID especificado.
  bool hasEntry(String id) => _entries.containsKey(id);

  /// Lista de todas las entradas registradas.
  List<FurnitureCatalogEntry> get allEntries => _entries.values.toList();

  /// Resuelve una representación visual opcional de sprite a partir del identificador
  /// de un objeto lógico existente, manteniendo total compatibilidad con el sistema actual.
  FurnitureCatalogEntry? findEntryForLogicalObject(String objectId) {
    final lower = objectId.toLowerCase();
    if (lower.contains('nevera') || lower.contains('frigor') || lower.contains('fridge')) {
      return getEntry('refrigerator_01');
    }
    if (lower.contains('fregadero') || lower.contains('lavabo') || lower.contains('sink')) {
      return getEntry('sink_01');
    }
    if (lower.contains('cocina') || lower.contains('horno') || lower.contains('stove')) {
      return getEntry('stove_01');
    }
    if (lower.contains('aparador') || lower.contains('alacena') || lower.contains('cabinet')) {
      return getEntry('cabinet_01');
    }
    if (lower.contains('mesa') && !lower.contains('noche')) {
      return lower.contains('redond') ? getEntry('table_round_01') : getEntry('table_01');
    }
    if (lower.contains('silla') || lower.contains('chair')) {
      return getEntry('chair_01');
    }
    return getEntry(objectId);
  }
}
