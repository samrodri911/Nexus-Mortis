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
    // Rango estricto exigido: 65% a 80% de la celda
    final effectiveRatio = fillRatio.clamp(0.65, 0.80);
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
}
