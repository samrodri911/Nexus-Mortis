import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/visual/models/floor_catalog_entry.dart';

/// Catálogo visual de suelos y texturas de habitación para Nexus Mortis.
///
/// Este catálogo es **estrictamente presentacional**:
/// - NO crea ni modifica zonas, tamaños de celda, bloqueos ni datos de gameplay.
/// - Conecta identificadores de suelos con texturas y garantiza fallback
///   inmediato e impecable a los patrones vectoriales de [TileType].
class FloorCatalog {
  FloorCatalog._() {
    _registerInitialEntries();
  }

  static final FloorCatalog instance = FloorCatalog._();

  final Map<String, FloorCatalogEntry> _entries = {};

  void _registerInitialEntries() {
    register(const FloorCatalogEntry(
      id: 'wood_parquet',
      displayName: 'Parquet de Madera',
      fallbackTileType: TileType.woodPlanks,
    ));
    register(const FloorCatalogEntry(
      id: 'wood_planks',
      displayName: 'Tablones de Roble',
      fallbackTileType: TileType.woodPlanks,
    ));
    register(const FloorCatalogEntry(
      id: 'tile_kitchen',
      displayName: 'Baldosa de Cocina',
      fallbackTileType: TileType.checkerboard,
    ));
    register(const FloorCatalogEntry(
      id: 'tile_checkerboard',
      displayName: 'Ajedrezado Blanco y Negro',
      fallbackTileType: TileType.checkerboard,
    ));
    register(const FloorCatalogEntry(
      id: 'stone_ancient',
      displayName: 'Piedra / Losa Maciza',
      fallbackTileType: TileType.stone,
    ));
    register(const FloorCatalogEntry(
      id: 'marble_hall',
      displayName: 'Mármol / Travertino Clásico',
      fallbackTileType: TileType.classicTiles,
    ));
    register(const FloorCatalogEntry(
      id: 'carpet_lounge',
      displayName: 'Moqueta de Salón',
      fallbackTileType: TileType.carpet,
    ));
  }

  /// Registra o actualiza una entrada en el catálogo de suelos.
  void register(FloorCatalogEntry entry) {
    _entries[entry.id] = entry;
  }

  /// Obtiene una entrada del catálogo por su ID.
  FloorCatalogEntry? getEntry(String id) => _entries[id];

  /// Comprueba si existe una entrada con el ID especificado.
  bool hasEntry(String id) => _entries.containsKey(id);

  /// Lista de todas las entradas registradas en el catálogo.
  List<FloorCatalogEntry> get allEntries => _entries.values.toList();

  /// Resuelve el [TileType] correspondiente a un [floorId].
  ///
  /// Si el [floorId] no está registrado, retorna [TileType.classicTiles] como fallback seguro.
  TileType resolveTileType(String floorId) {
    return _entries[floorId]?.fallbackTileType ?? TileType.classicTiles;
  }

  /// Retorna una entrada de catálogo representativa para un [TileType].
  FloorCatalogEntry getFloorForTileType(TileType type) {
    switch (type) {
      case TileType.woodPlanks:
        return _entries['wood_planks']!;
      case TileType.checkerboard:
        return _entries['tile_checkerboard']!;
      case TileType.stone:
        return _entries['stone_ancient']!;
      case TileType.classicTiles:
        return _entries['marble_hall']!;
      case TileType.carpet:
        return _entries['carpet_lounge']!;
    }
  }
}
