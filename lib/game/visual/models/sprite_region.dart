import 'dart:ui';

/// Define un área rectangular en píxeles dentro de un atlas de texturas.
class SpriteRegion {
  const SpriteRegion({
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Identificador único de la región dentro de su atlas.
  final String name;

  /// Coordenada X del borde izquierdo en píxeles.
  final double x;

  /// Coordenada Y del borde superior en píxeles.
  final double y;

  /// Ancho de la región en píxeles.
  final double width;

  /// Alto de la región en píxeles.
  final double height;

  /// Rectángulo delimitador de la región en el espacio de la imagen fuente.
  Rect get rect => Rect.fromLTWH(x, y, width, height);

  /// Relación de aspecto (ancho / alto).
  double get aspectRatio => height > 0 ? width / height : 1.0;

  @override
  String toString() => 'SpriteRegion($name: x=$x, y=$y, w=$width, h=$height)';
}
