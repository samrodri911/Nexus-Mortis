/// Metadatos visuales de un elemento dentro del catálogo de decoración secundaria.
///
/// Este modelo es estrictamente presentacional y NO tiene relación alguna
/// con objetos lógicos del puzzle, bloqueos de celda ni reglas de deductibilidad.
class DecorationCatalogEntry {
  const DecorationCatalogEntry({
    required this.id,
    required this.atlasId,
    required this.regionName,
    this.category = 'decoration',
    this.defaultScaleRatio = 0.72,
  });

  /// Identificador único de la decoración en el catálogo visual (ej. 'vase_01').
  final String id;

  /// Identificador del atlas al que pertenece (ej. 'decorations_general').
  final String atlasId;

  /// Nombre de la región específica dentro del atlas.
  final String regionName;

  /// Categoría visual contextual (ej. 'plant', 'art', 'curiosity', 'prop').
  final String category;

  /// Proporción de ocupación por defecto respecto a tileSize (entre 0.65 y 0.80).
  final double defaultScaleRatio;
}
