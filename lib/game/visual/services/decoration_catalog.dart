import 'package:nexus_mortis/game/visual/models/decoration_catalog_entry.dart';

/// Catálogo visual de decoración secundaria para Nexus Mortis.
///
/// Este catálogo es **estrictamente presentacional**:
/// - NO crea ni modifica objetos lógicos, [CaseData], [CellData] ni [GroundTruth].
/// - Actúa exclusivamente como registro y mapeo de sprites decorativos secundarios
///   para enriquecer las habitaciones sin bloquear celdas.
/// - Si un sprite no está registrado, el sistema activa automáticamente el fallback
///   a [ArchitecturalFurnitureRenderer].
class DecorationCatalog {
  DecorationCatalog._() {
    _registerInitialEntries();
  }

  static final DecorationCatalog instance = DecorationCatalog._();

  final Map<String, DecorationCatalogEntry> _entries = {};

  void _registerInitialEntries() {
    // Jardín botánico (decorations_garden)
    register(const DecorationCatalogEntry(
      id: 'obj_fuente',
      atlasId: 'decorations_garden',
      regionName: 'garden_01',
      category: 'fountain',
      defaultScaleRatio: 0.78,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_banco',
      atlasId: 'decorations_garden',
      regionName: 'garden_03',
      category: 'bench',
      defaultScaleRatio: 0.72,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_maceta',
      atlasId: 'decorations_garden',
      regionName: 'garden_06',
      category: 'plant',
      defaultScaleRatio: 0.70,
    ));

    // Museo / Archivo (decorations_museum)
    register(const DecorationCatalogEntry(
      id: 'obj_estatua',
      atlasId: 'decorations_museum',
      regionName: 'museum_01',
      category: 'statue',
      defaultScaleRatio: 0.76,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_sarcofago',
      atlasId: 'decorations_museum',
      regionName: 'museum_05',
      category: 'relic',
      defaultScaleRatio: 0.78,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_anfora',
      atlasId: 'decorations_museum',
      regionName: 'museum_11',
      category: 'urn',
      defaultScaleRatio: 0.70,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_pedestal',
      atlasId: 'decorations_museum',
      regionName: 'museum_13',
      category: 'pedestal',
      defaultScaleRatio: 0.72,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_vitrina',
      atlasId: 'decorations_museum',
      regionName: 'museum_18',
      category: 'showcase',
      defaultScaleRatio: 0.75,
    ));
    register(const DecorationCatalogEntry(
      id: 'obj_caballete',
      atlasId: 'decorations_museum',
      regionName: 'museum_21',
      category: 'easel',
      defaultScaleRatio: 0.72,
    ));
  }

  /// Registra una nueva entrada en el catálogo de decoración.
  void register(DecorationCatalogEntry entry) {
    _entries[entry.id] = entry;
  }

  /// Obtiene una entrada del catálogo por su ID.
  DecorationCatalogEntry? getEntry(String id) => _entries[id];

  /// Verifica si existe una entrada con el ID especificado.
  bool hasEntry(String id) => _entries.containsKey(id);

  /// Lista de todas las entradas registradas.
  List<DecorationCatalogEntry> get allEntries => _entries.values.toList();

  /// Intenta resolver una entrada de decoración para un identificador de objeto.
  ///
  /// Si el identificador coincide con una entrada registrada, la retorna.
  /// De lo contrario retorna `null` para activar el fallback inmediato
  /// a [ArchitecturalFurnitureRenderer].
  DecorationCatalogEntry? findEntryForDecoration(String objectId) {
    if (hasEntry(objectId)) {
      return getEntry(objectId);
    }
    return null;
  }
}
