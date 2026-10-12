import 'package:nexus_mortis/game/visual/models/sprite_region.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/builtin_atlas_definitions.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';

/// Registro centralizado de definiciones de atlas de texturas para Nexus Mortis.
///
/// Responsabilidades:
/// - Registrar formalmente cada hoja de texturas con su ruta de assets y regiones.
/// - Facilitar la adición de nuevos atlas sin modificar código en múltiples archivos.
/// - Orquestar la precarga masiva segura (con try/catch) en [AtlasManager].
/// - Evitar que la ausencia de un asset bloquee la ejecución del juego.
class AtlasRegistry {
  AtlasRegistry._() {
    _registerDefaultAtlases();
  }

  static final AtlasRegistry instance = AtlasRegistry._();

  final Map<String, TextureAtlas> _definitions = {};

  void _registerDefaultAtlases() {
    // 1. Atlas de muebles de cocina
    registerAtlas(FurnitureCatalog.kitchenAtlas);

    // 2. Atlas temáticos de mobiliario
    registerAtlas(BuiltinAtlasDefinitions.bedroomAtlas);
    registerAtlas(BuiltinAtlasDefinitions.libraryAtlas);
    registerAtlas(BuiltinAtlasDefinitions.loungeAtlas);
    registerAtlas(BuiltinAtlasDefinitions.laboratoryAtlas);

    // 3. Atlas temáticos de decoración
    registerAtlas(BuiltinAtlasDefinitions.gardenAtlas);
    registerAtlas(BuiltinAtlasDefinitions.museumAtlas);
    registerAtlas(const TextureAtlas(
      id: 'decorations_general',
      assetPath: 'assets/game/atlases/decorations/decorations_general.png',
      regions: {},
    ));

    // 4. Definiciones de suelos y arquitectura preparadas para el futuro
    registerAtlas(const TextureAtlas(
      id: 'floors_general',
      assetPath: 'assets/game/atlases/floors/floors_sheet.png',
      regions: {},
    ));
    registerAtlas(const TextureAtlas(
      id: 'architecture_general',
      assetPath: 'assets/game/atlases/architecture/architecture_sheet.png',
      regions: {},
    ));
  }

  /// Registra o actualiza una definición de atlas.
  void registerAtlas(TextureAtlas atlas) {
    _definitions[atlas.id] = atlas;
  }

  /// Obtiene la definición de un atlas por su identificador.
  TextureAtlas? getAtlas(String id) => _definitions[id];

  /// Comprueba si existe un atlas registrado con el identificador dado.
  bool hasAtlas(String id) => _definitions.containsKey(id);

  /// Lista de todos los atlas registrados.
  List<TextureAtlas> get allAtlases => _definitions.values.toList();

  /// Registra o actualiza una región específica dentro de un atlas existente.
  void registerRegion(String atlasId, SpriteRegion region) {
    final existing = _definitions[atlasId];
    if (existing == null) return;

    final updatedRegions = Map<String, SpriteRegion>.from(existing.regions);
    updatedRegions[region.name] = region;

    _definitions[atlasId] = TextureAtlas(
      id: existing.id,
      assetPath: existing.assetPath,
      regions: updatedRegions,
    );
  }

  /// Precarga todos los atlas registrados en el [AtlasManager].
  ///
  /// Si algún archivo PNG aún no existe físicamente en los assets,
  /// la excepción se captura de forma silenciosa para garantizar
  /// que el juego inicie con fallback vectorial inmediato.
  Future<void> preloadAll(AtlasManager manager) async {
    for (final definition in _definitions.values) {
      if (definition.regions.isEmpty &&
          definition.id != FurnitureCatalog.kitchenAtlasId) {
        // No intentar precargar definiciones vacías de placeholders
        continue;
      }
      try {
        await manager.loadAtlas(definition);
      } catch (_) {
        // Fallback garantizado: no interrumpe el arranque del juego
      }
    }
  }
}
