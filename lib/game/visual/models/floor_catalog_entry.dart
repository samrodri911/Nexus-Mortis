import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';

/// Metadatos visuales de un tipo de suelo dentro del catálogo de suelos.
///
/// Este modelo es estrictamente presentacional y NO afecta en absoluto la lógica del puzzle.
/// Si un sprite o atlas no está disponible, se utiliza [fallbackTileType] para renderizado
/// vectorial limpio con Canvas.
class FloorCatalogEntry {
  const FloorCatalogEntry({
    required this.id,
    required this.displayName,
    required this.fallbackTileType,
    this.atlasId,
    this.regionName,
  });

  /// Identificador único del suelo (ej. 'wood_parquet', 'tile_checkerboard').
  final String id;

  /// Nombre legible del suelo para herramientas de inspección o depuración.
  final String displayName;

  /// Tipo de baldosa/suelo vectorial de respaldo (TileType).
  final TileType fallbackTileType;

  /// Identificador opcional de atlas si cuenta con sprite/textura de imagen.
  final String? atlasId;

  /// Nombre de la región específica dentro del atlas de suelos.
  final String? regionName;

  /// Indica si la entrada cuenta con una textura de sprite asociada.
  bool get hasSprite => atlasId != null && regionName != null;
}
