import 'dart:ui' as ui;

import 'package:flame/sprite.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';

/// Gestor centralizado de carga y ciclo de vida de atlas de texturas.
///
/// Encargado de:
/// - Cargar imágenes de atlas desde los assets de Flutter ([rootBundle]).
/// - Decodificar a [ui.Image] de forma asíncrona y eficiente.
/// - Envolver en [LoadedAtlas] con caché integrada de [Sprite]s de Flame.
/// - Ofrecer fallback limpio y seguro si un asset no está disponible.
class AtlasManager {
  AtlasManager._();

  static final AtlasManager instance = AtlasManager._();

  final Map<String, LoadedAtlas> _loadedAtlases = {};
  final Map<String, Future<LoadedAtlas>> _loadingFutures = {};

  /// Carga y cachea un atlas de texturas a partir de su definición.
  /// Si el atlas ya está cargado o en proceso de carga, reutiliza la instancia existente.
  Future<LoadedAtlas> loadAtlas(TextureAtlas definition) async {
    if (_loadedAtlases.containsKey(definition.id)) {
      return _loadedAtlases[definition.id]!;
    }

    if (_loadingFutures.containsKey(definition.id)) {
      return _loadingFutures[definition.id]!;
    }

    final future = _loadAtlasInternal(definition);
    _loadingFutures[definition.id] = future;

    try {
      final loaded = await future;
      _loadedAtlases[definition.id] = loaded;
      return loaded;
    } finally {
      _loadingFutures.remove(definition.id);
    }
  }

  Future<LoadedAtlas> _loadAtlasInternal(TextureAtlas definition) async {
    final byteData = await rootBundle.load(definition.assetPath);
    final uint8List = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(uint8List);
    final frameInfo = await codec.getNextFrame();
    return LoadedAtlas(
      definition: definition,
      image: frameInfo.image,
    );
  }

  /// Retorna un atlas cargado previamente por su ID, o null si no ha sido cargado.
  LoadedAtlas? getAtlas(String atlasId) => _loadedAtlases[atlasId];

  /// Obtiene directamente un [Sprite] de Flame para un atlas y región dados.
  /// Retorna null si el atlas no está cargado o la región no existe en él.
  Sprite? getSprite(String atlasId, String regionName) {
    return _loadedAtlases[atlasId]?.getSprite(regionName);
  }

  /// Registra manualmente un [LoadedAtlas] (para pruebas unitarias o inyección dinámica).
  void registerLoadedAtlas(LoadedAtlas loadedAtlas) {
    _loadedAtlases[loadedAtlas.definition.id] = loadedAtlas;
  }

  /// Verifica si un atlas específico ya está cargado en memoria.
  bool isLoaded(String atlasId) => _loadedAtlases.containsKey(atlasId);

  /// Limpia la caché de atlas cargados.
  void clear() {
    _loadedAtlases.clear();
    _loadingFutures.clear();
  }
}
