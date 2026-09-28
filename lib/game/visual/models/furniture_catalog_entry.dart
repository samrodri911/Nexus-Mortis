/// Metadatos visuales de un elemento dentro del catálogo de mobiliario.
///
/// Este modelo es estrictamente presentacional y NO tiene relación alguna
/// con objetos lógicos del puzzle, bloqueos de celda ni reglas de deductibilidad.
class FurnitureCatalogEntry {
  const FurnitureCatalogEntry({
    required this.id,
    required this.atlasId,
    required this.regionName,
    this.category = 'kitchen',
    this.defaultScaleRatio = 0.72,
  });

  /// Identificador único del mueble en el catálogo visual (ej. 'chair_01').
  final String id;

  /// Identificador del atlas al que pertenece (ej. 'furniture_kitchen').
  final String atlasId;

  /// Nombre de la región específica dentro del atlas.
  final String regionName;

  /// Categoría visual contextual (ej. 'chair', 'table', 'cabinet', 'appliance').
  final String category;

  /// Proporción de ocupación por defecto respecto a tileSize (entre 0.65 y 0.80).
  final double defaultScaleRatio;
}
