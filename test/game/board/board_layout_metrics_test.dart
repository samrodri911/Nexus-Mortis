import 'package:flame/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';

void main() {
  group('BoardLayoutMetrics Tests', () {
    test('Garantiza celdas cuadradas y proporciones exactas en 4x4', () {
      final metrics = BoardLayoutMetrics.calculate(
        availableWidth: 400,
        availableHeight: 600,
        rows: 4,
        cols: 4,
        padding: 0,
      );

      // En viewport 400x600 con 4x4, la anchura limita a 400/4 = 100
      expect(metrics.tileSize, equals(100.0));
      expect(metrics.boardWidth, equals(400.0));
      expect(metrics.boardHeight, equals(400.0));

      // Centrado vertical: (600 - 400) / 2 = 100
      expect(metrics.offsetX, equals(0.0));
      expect(metrics.offsetY, equals(100.0));

      // Posición de celdas
      expect(metrics.getCellPosition(0, 0), equals(Vector2(0, 100)));
      expect(metrics.getCellPosition(3, 3), equals(Vector2(300, 400)));
    });

    test('Garantiza celdas cuadradas y proporciones en tableros no cuadrados (5x4)', () {
      final metrics = BoardLayoutMetrics.calculate(
        availableWidth: 400,
        availableHeight: 600,
        rows: 5,
        cols: 4,
        padding: 0,
      );

      // Width per col = 400/4 = 100; Height per row = 600/5 = 120 -> tileSize = 100
      expect(metrics.tileSize, equals(100.0));
      expect(metrics.boardWidth, equals(400.0)); // 100 * 4
      expect(metrics.boardHeight, equals(500.0)); // 100 * 5

      // Centrado vertical: (600 - 500) / 2 = 50
      expect(metrics.offsetX, equals(0.0));
      expect(metrics.offsetY, equals(50.0));
    });

    test('Garantiza celdas cuadradas y centrado horizontal cuando la altura es la dimensión limitante', () {
      final metrics = BoardLayoutMetrics.calculate(
        availableWidth: 500,
        availableHeight: 300,
        rows: 5,
        cols: 5,
        padding: 0,
      );

      // Height per row = 300/5 = 60; Width per col = 500/5 = 100 -> tileSize = 60
      expect(metrics.tileSize, equals(60.0));
      expect(metrics.boardWidth, equals(300.0));
      expect(metrics.boardHeight, equals(300.0));

      // Centrado horizontal: (500 - 300) / 2 = 100
      expect(metrics.offsetX, equals(100.0));
      expect(metrics.offsetY, equals(0.0));
    });

    test('Comprueba que el tablero aumenta significativamente al liberar espacio vertical', () {
      // Simulación: Pistas abiertas (viewport altura reducida 250px)
      final withCluesOpen = BoardLayoutMetrics.calculate(
        availableWidth: 380,
        availableHeight: 250,
        rows: 4,
        cols: 4,
        padding: 6,
      );

      // Simulación: Pistas cerradas (viewport altura expandida 450px)
      final withCluesClosed = BoardLayoutMetrics.calculate(
        availableWidth: 380,
        availableHeight: 450,
        rows: 4,
        cols: 4,
        padding: 6,
      );

      // Al cerrar pistas, tileSize debe crecer significativamente
      expect(withCluesClosed.tileSize, greaterThan(withCluesOpen.tileSize));
      expect(withCluesClosed.boardWidth, greaterThan(withCluesOpen.boardWidth));
      expect(withCluesClosed.boardHeight, greaterThan(withCluesOpen.boardHeight));

      // En ambos casos, las celdas son cuadradas y están centradas
      expect(withCluesOpen.boardWidth, equals(withCluesOpen.tileSize * 4));
      expect(withCluesClosed.boardWidth, equals(withCluesClosed.tileSize * 4));
    });

    test('Comprueba tamaños mayores como 6x5 y 6x6', () {
      final m6x5 = BoardLayoutMetrics.calculate(
        availableWidth: 360,
        availableHeight: 480,
        rows: 6,
        cols: 5,
        padding: 0,
      );
      expect(m6x5.tileSize, equals(72.0)); // min(360/5 = 72, 480/6 = 80)
      expect(m6x5.boardWidth, equals(360.0));
      expect(m6x5.boardHeight, equals(432.0)); // 72 * 6
      expect(m6x5.offsetY, equals(24.0)); // (480 - 432) / 2

      final m6x6 = BoardLayoutMetrics.calculate(
        availableWidth: 360,
        availableHeight: 480,
        rows: 6,
        cols: 6,
        padding: 0,
      );
      expect(m6x6.tileSize, equals(60.0)); // min(360/6 = 60, 480/6 = 80)
      expect(m6x6.boardWidth, equals(360.0));
      expect(m6x6.boardHeight, equals(360.0));
      expect(m6x6.offsetY, equals(60.0));
    });
  });
}
