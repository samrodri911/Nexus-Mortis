import 'package:flutter/painting.dart';

/// Configuración visual centralizada y paleta temática para las zonas del tablero.
abstract final class ZoneVisualConfig {
  /// Colores distintivos de alto contraste para las zonas (estilo noir / detective elegante).
  static const List<Color> zoneColors = [
    Color(0xFF8A4FFF), // Púrpura amatista
    Color(0xFF00B4D8), // Azul cian / zafiro
    Color(0xFFFFB703), // Ámbar dorado
    Color(0xFF06D6A0), // Esmeralda / menta
    Color(0xFFFF006E), // Carmesí
    Color(0xFF9B5DE5), // Lavanda
    Color(0xFF48CAE4), // Turquesa
    Color(0xFFF72585), // Magenta neón
  ];

  /// Obtiene el color correspondiente a un índice de zona de forma cíclica y segura.
  static Color getColorForIndex(int index) {
    if (index < 0) return zoneColors[0];
    return zoneColors[index % zoneColors.length];
  }
}
