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
  DecorationCatalog._();

  static final DecorationCatalog instance = DecorationCatalog._();

  final Map<String, DecorationCatalogEntry> _entries = {};

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
