import 'dart:ui' as ui;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';

void main() {
  group('ZoneVisualTheme Tests', () {
    test('Asigna TileType coherente según la temática de la zona', () {
      final libraryTheme = ZoneVisualTheme.fromZoneName('Biblioteca Central', 0);
      expect(libraryTheme.tileType, equals(TileType.woodPlanks));
      expect(libraryTheme.archetype, equals(ZoneArchetype.library));

      final kitchenTheme = ZoneVisualTheme.fromZoneName('Cocina Antigua', 1);
      expect(kitchenTheme.tileType, equals(TileType.checkerboard));
      expect(kitchenTheme.archetype, equals(ZoneArchetype.kitchen));

      final gardenTheme = ZoneVisualTheme.fromZoneName('Patio de la Rosaleda', 2);
      expect(gardenTheme.tileType, equals(TileType.stone));
      expect(gardenTheme.archetype, equals(ZoneArchetype.garden));

      final labTheme = ZoneVisualTheme.fromZoneName('Laboratorio Óptico', 3);
      expect(labTheme.tileType, equals(TileType.classicTiles));
      expect(labTheme.archetype, equals(ZoneArchetype.laboratory));

      final loungeTheme = ZoneVisualTheme.fromZoneName('Salón de Fumadores', 4);
      expect(loungeTheme.tileType, equals(TileType.carpet));
      expect(loungeTheme.archetype, equals(ZoneArchetype.lounge));
    });

    test('renderFloorTexture renderiza los 5 TileTypes sin errores', () {
      for (final tileType in TileType.values) {
        final theme = ZoneVisualTheme(
          archetype: ZoneArchetype.lounge,
          displayName: 'Habitación Test',
          tintColor: const ui.Color(0xFFEFE6DC),
          accentColor: const ui.Color(0xFF9E6B38),
          tileType: tileType,
          icon: const ui.Color(0) == const ui.Color(0) ? Icons.meeting_room_rounded : Icons.home,
        );

        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        final bounds = const ui.Rect.fromLTWH(0, 0, 160, 160);
        final path = ui.Path()..addRect(bounds);

        expect(
          () => theme.renderFloorTexture(canvas, path, bounds, 80.0),
          returnsNormally,
          reason: 'Fallo al renderizar textura para $tileType',
        );

        final pic = recorder.endRecording();
        pic.dispose();
      }
    });

    test('renderRug dibuja alfombra con sombra y bordes en habitaciones aplicables', () {
      final bedroomTheme = ZoneVisualTheme.fromZoneName('Dormitorio Principal', 0);
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final bounds = const ui.Rect.fromLTWH(0, 0, 200, 200);

      expect(
        () => bedroomTheme.renderRug(canvas, bounds, 100, 100),
        returnsNormally,
      );

      final pic = recorder.endRecording();
      pic.dispose();
    });

    test('renderRoomWatermark procesa nombres simples, de 2 líneas y de 3 líneas sin errores', () {
      final names = [
        'ESTUDIO',
        'BIBLIOTECA CENTRAL',
        'SALA DE JUEGOS ANTIGUOS',
        'LABORATORIO DE CARTOGRAFÍA CELESTIAL',
      ];

      for (final name in names) {
        final theme = ZoneVisualTheme.fromZoneName(name, 0);
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        final bounds = const ui.Rect.fromLTWH(0, 0, 240, 240);
        final center = const ui.Offset(120, 120);

        expect(
          () => theme.renderRoomWatermark(
            canvas: canvas,
            visualCenter: center,
            roomBounds: bounds,
            cellWidth: 80.0,
            cellHeight: 80.0,
          ),
          returnsNormally,
          reason: 'Fallo al renderizar marca de agua de "$name"',
        );

        final pic = recorder.endRecording();
        pic.dispose();
      }
    });
  });
}
