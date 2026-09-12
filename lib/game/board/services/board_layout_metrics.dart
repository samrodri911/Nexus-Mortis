import 'dart:math';
import 'package:flame/extensions.dart';

/// Métricas matemáticas puras para el cálculo de escala, cuadrícula cuadrada y centrado del tablero.
class BoardLayoutMetrics {
  const BoardLayoutMetrics({
    required this.tileSize,
    required this.boardWidth,
    required this.boardHeight,
    required this.offsetX,
    required this.offsetY,
    required this.rows,
    required this.cols,
  });

  /// Tamaño uniforme (ancho y alto) de cada celda: `tileWidth == tileHeight == tileSize`.
  final double tileSize;

  /// Ancho total del tablero (`tileSize * cols`).
  final double boardWidth;

  /// Alto total del tablero (`tileSize * rows`).
  final double boardHeight;

  /// Desplazamiento horizontal para centrar el tablero en el viewport disponible.
  final double offsetX;

  /// Desplazamiento vertical para centrar el tablero en el viewport disponible.
  final double offsetY;

  final int rows;
  final int cols;

  /// Calcula las métricas del tablero garantizando celdas cuadradas y centrado perfecto.
  factory BoardLayoutMetrics.calculate({
    required double availableWidth,
    required double availableHeight,
    required int rows,
    required int cols,
    double padding = 6.0,
  }) {
    if (rows <= 0 || cols <= 0) {
      throw ArgumentError('Las filas y columnas deben ser mayores que cero.');
    }

    final usableWidth = max(0.0, availableWidth - (padding * 2));
    final usableHeight = max(0.0, availableHeight - (padding * 2));

    // Cuadrados perfectos: la dimensión limitante define el tamaño de cada celda
    final tileSize = min(usableWidth / cols, usableHeight / rows);

    final boardWidth = tileSize * cols;
    final boardHeight = tileSize * rows;

    // Centrado geométrico en el área disponible
    final offsetX = (availableWidth - boardWidth) / 2;
    final offsetY = (availableHeight - boardHeight) / 2;

    return BoardLayoutMetrics(
      tileSize: tileSize,
      boardWidth: boardWidth,
      boardHeight: boardHeight,
      offsetX: offsetX,
      offsetY: offsetY,
      rows: rows,
      cols: cols,
    );
  }

  /// Retorna la posición física `Vector2(x, y)` de una celda específica en el viewport del juego.
  Vector2 getCellPosition(int row, int col) {
    return Vector2(
      offsetX + (col * tileSize),
      offsetY + (row * tileSize),
    );
  }
}
