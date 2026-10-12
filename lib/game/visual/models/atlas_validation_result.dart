/// Resultado del diagnóstico y validación técnica de un atlas de texturas.
///
/// Permite detectar:
/// - Dimensiones no válidas de la imagen base.
/// - Regiones fuera de los límites geométricos de la imagen.
/// - Regiones vacías, con coordenadas negativas o dimensiones no positivas.
/// - Regiones inusualmente pequeñas o sospechosas.
class AtlasValidationResult {
  const AtlasValidationResult({
    required this.atlasId,
    required this.imageWidth,
    required this.imageHeight,
    required this.errors,
    required this.warnings,
    required this.validRegions,
  });

  /// Identificador del atlas diagnosticado.
  final String atlasId;

  /// Ancho real de la imagen decodificada en píxeles.
  final double imageWidth;

  /// Alto real de la imagen decodificada en píxeles.
  final double imageHeight;

  /// Errores críticos que impiden el renderizado correcto de sprites.
  final List<String> errors;

  /// Advertencias que no impiden el renderizado pero señalan posibles desajustes.
  final List<String> warnings;

  /// Lista de nombres de regiones que pasaron todas las validaciones geométricas.
  final List<String> validRegions;

  /// Indica si el atlas no contiene ningún error geométrico.
  bool get isValid => errors.isEmpty;

  /// Cantidad total de regiones evaluadas.
  int get totalRegions => validRegions.length + errors.length;

  /// Resumen textual del diagnóstico para inspección rápida.
  String get summary {
    if (isValid) {
      final warnText = warnings.isEmpty ? '' : ' (${warnings.length} advertencias)';
      return '$atlasId: ${validRegions.length} regiones válidas • ${imageWidth.toInt()}×${imageHeight.toInt()} px$warnText';
    } else {
      return '$atlasId: ${errors.length} errores detectados en $totalRegions regiones';
    }
  }
}
