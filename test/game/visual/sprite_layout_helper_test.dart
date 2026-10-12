import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';

void main() {
  group('SpriteLayoutHelper Tests', () {
    const cell = Rect.fromLTWH(100, 200, 80, 80);

    test('calculateDestRect never exceeds 80% of tileSize', () {
      final destSquare = SpriteLayoutHelper.calculateDestRect(
        cellRect: cell,
        srcWidth: 100,
        srcHeight: 100,
        fillRatio: 0.95, // Excede el 80% solicitado
      );

      expect(destSquare.width, closeTo(64.0, 0.001)); // 80 * 0.80 = 64
      expect(destSquare.height, closeTo(64.0, 0.001));
      expect(destSquare.center, equals(cell.center));
    });

    test('calculateDestRect supports smaller scales down to 20%', () {
      final destSmall = SpriteLayoutHelper.calculateDestRect(
        cellRect: cell,
        srcWidth: 50,
        srcHeight: 50,
        fillRatio: 0.40,
      );

      expect(destSmall.width, closeTo(32.0, 0.001)); // 80 * 0.40 = 32
      expect(destSmall.height, closeTo(32.0, 0.001));
      expect(destSmall.center, equals(cell.center));
    });

    test('calculateDestRect preserves aspect ratio for tall and wide sprites', () {
      // Tall sprite: 50x100
      final tall = SpriteLayoutHelper.calculateDestRect(
        cellRect: cell,
        srcWidth: 50,
        srcHeight: 100,
        fillRatio: 0.80,
      );
      expect(tall.height, closeTo(64.0, 0.001));
      expect(tall.width, closeTo(32.0, 0.001));
      expect(tall.center, equals(cell.center));

      // Wide sprite: 100x50
      final wide = SpriteLayoutHelper.calculateDestRect(
        cellRect: cell,
        srcWidth: 100,
        srcHeight: 50,
        fillRatio: 0.80,
      );
      expect(wide.width, closeTo(64.0, 0.001));
      expect(wide.height, closeTo(32.0, 0.001));
      expect(wide.center, equals(cell.center));
    });

    test('calculateContactShadowRect is positioned at the base and within cell', () {
      final dest = SpriteLayoutHelper.calculateDestRect(
        cellRect: cell,
        srcWidth: 80,
        srcHeight: 100,
        fillRatio: 0.75,
      );

      final shadow = SpriteLayoutHelper.calculateContactShadowRect(
        destRect: dest,
        cellRect: cell,
      );

      expect(shadow.center.dx, equals(dest.center.dx));
      expect(shadow.width, lessThan(dest.width));
      expect(shadow.width, greaterThan(0));
      expect(shadow.height, greaterThan(0));

      // Debe estar estrictamente dentro de la celda
      expect(shadow.left, greaterThanOrEqualTo(cell.left));
      expect(shadow.right, lessThanOrEqualTo(cell.right));
      expect(shadow.top, greaterThanOrEqualTo(cell.top));
      expect(shadow.bottom, lessThanOrEqualTo(cell.bottom));
    });

    test('shouldHaveContactShadow distinguishes floor furniture from wall/flat items', () {
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_mesa'), isTrue);
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_silla'), isTrue);
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_banco'), isTrue);
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_fuente'), isTrue);
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_alfombra'), isFalse);
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_cuadro'), isFalse);
      expect(SpriteLayoutHelper.shouldHaveContactShadow('obj_foco'), isFalse);
    });
  });
}
