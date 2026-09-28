import 'dart:ui' as ui;

import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:nexus_mortis/game/visual/models/sprite_region.dart';

/// Definición e índice de regiones de un atlas de texturas.
class TextureAtlas {
  const TextureAtlas({
    required this.id,
    required this.assetPath,
    required this.regions,
  });

  /// Identificador único del atlas (ej. 'furniture_kitchen').
  final String id;

  /// Ruta al asset de imagen (ej. 'assets/game/atlases/furniture/furniture_sheet.png').
  final String assetPath;

  /// Mapa de regiones indexadas por su nombre.
  final Map<String, SpriteRegion> regions;

  /// Retorna la región asociada al nombre, o null si no existe.
  SpriteRegion? getRegion(String name) => regions[name];

  /// Verifica si el atlas contiene una región específica.
  bool containsRegion(String name) => regions.containsKey(name);
}

/// Atlas cargado en memoria con su imagen decodificada y caché de Sprites de Flame.
class LoadedAtlas {
  LoadedAtlas({
    required this.definition,
    required this.image,
  });

  /// Definición geométrica del atlas.
  final TextureAtlas definition;

  /// Imagen decodificada en memoria.
  final ui.Image image;

  /// Caché interna de sprites de Flame ya instanciados.
  final Map<String, Sprite> _spriteCache = {};

  /// Obtiene o instancia el [Sprite] de Flame correspondiente a una región.
  /// Retorna null si la región no existe en la definición del atlas.
  Sprite? getSprite(String regionName) {
    if (_spriteCache.containsKey(regionName)) {
      return _spriteCache[regionName];
    }

    final region = definition.getRegion(regionName);
    if (region == null) return null;

    final sprite = Sprite(
      image,
      srcPosition: Vector2(region.x, region.y),
      srcSize: Vector2(region.width, region.height),
    );

    _spriteCache[regionName] = sprite;
    return sprite;
  }
}
