import 'dart:math';
import 'dart:ui';

/// Utilidad para el cálculo responsive y geométrico del renderizado de sprites en celdas.
class SpriteLayoutHelper {
  const SpriteLayoutHelper._();

  /// Calcula el [Rect] de destino centrado estrictamente en [cellRect]
  /// y escalado proporcionalmente según [fillRatio] (acotado entre 0.65 y 0.80).
  ///
  /// - Conserva la relación de aspecto original ([srcWidth] / [srcHeight]).
  /// - Queda estrictamente centrado en `cellRect.center`.
  /// - Se adapta responsivemente a `tileSize` (`cellRect.width`).
  /// - Nunca utiliza dimensiones fijas ni artificiales.
  static Rect calculateDestRect({
    required Rect cellRect,
    required double srcWidth,
    required double srcHeight,
    double fillRatio = 0.72,
  }) {
    if (srcWidth <= 0 || srcHeight <= 0) return cellRect;

    final tileSize = cellRect.width;
    // Límite máximo del 80% exigido, permitiendo escalas inferiores para props menores
    final effectiveRatio = fillRatio.clamp(0.20, 0.80);
    final maxDim = tileSize * effectiveRatio;

    // Escala uniforme que preserva la proporción del sprite
    final scale = maxDim / max(srcWidth, srcHeight);
    final destW = srcWidth * scale;
    final destH = srcHeight * scale;

    return Rect.fromCenter(
      center: cellRect.center,
      width: destW,
      height: destH,
    );
  }

  /// Calcula el [Rect] de la elipse de sombra de contacto en la base del sprite.
  ///
  /// - Situada cerca de la base del mueble ([destRect.bottom]).
  /// - Centrada en el eje horizontal respecto a [destRect].
  /// - Más pequeña que el ancho del sprite (~75%) y aplanada (~25% del ancho de sombra).
  /// - Confinada con seguridad dentro de [cellRect] para no invadir celdas colindantes.
  static Rect calculateContactShadowRect({
    required Rect destRect,
    required Rect cellRect,
  }) {
    final maxAllowedW = cellRect.width * 0.76;
    final shadowW = (destRect.width * 0.75).clamp(8.0, maxAllowedW);
    final maxAllowedH = cellRect.height * 0.22;
    final shadowH = (shadowW * 0.26).clamp(3.0, maxAllowedH);

    final maxCenterY = cellRect.bottom - (shadowH * 0.55);
    final minCenterY = cellRect.top + (shadowH * 0.55);
    final idealCenterY = destRect.bottom - (shadowH * 0.35);
    final centerY = idealCenterY.clamp(minCenterY, maxCenterY);

    return Rect.fromCenter(
      center: Offset(destRect.center.dx, centerY),
      width: shadowW,
      height: shadowH,
    );
  }

  /// Determina si un objeto representa mobiliario o utilería apoyada en el suelo
  /// que requiera sombra de contacto arquitectónica.
  static bool shouldHaveContactShadow(String objectId, {String? category}) {
    final lowerId = objectId.toLowerCase();
    final lowerCat = category?.toLowerCase() ?? '';

    // Elementos murales, planos o textiles sin sombra de contacto
    if (lowerId.contains('alfombra') ||
        lowerId.contains('rug') ||
        lowerId.contains('cuadro') ||
        lowerId.contains('painting') ||
        lowerId.contains('foco') ||
        lowerCat == 'floor' ||
        lowerCat == 'wall') {
      return false;
    }

    return true;
  }
}
