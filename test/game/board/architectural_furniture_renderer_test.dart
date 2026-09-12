import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/components/architectural_furniture_renderer.dart';

void main() {
  group('ArchitecturalFurnitureRenderer Tests', () {
    const renderer = ArchitecturalFurnitureRenderer();

    test('Renderiza todos los tipos de objetos lógicos sin errores', () {
      final objectIds = [
        'obj_cama_01',
        'obj_silla_01',
        'obj_mesa_redonda',
        'obj_escritorio_caoba',
        'obj_librero_antiguo',
        'obj_armario_roble',
        'obj_lampara_pie',
        'obj_caja_fuerte',
        'obj_nevera_vintage',
        'obj_fregadero_acero',
        'obj_desconocido_fallback',
      ];

      for (final objId in objectIds) {
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);

        expect(
          () => renderer.render(
            canvas: canvas,
            objectId: objId,
            objectLabel: 'Mueble Test',
            cellRect: const ui.Rect.fromLTWH(0, 0, 60, 60),
            tileSize: 60,
          ),
          returnsNormally,
          reason: 'Fallo al renderizar $objId con tamaño 60x60',
        );

        final picture = recorder.endRecording();
        picture.dispose();
      }
    });

    test('Maneja etiquetas nulas o vacías y celdas pequeñas correctamente', () {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // Con label nula y tamaño pequeño (<42px para omitir microetiqueta)
      expect(
        () => renderer.render(
          canvas: canvas,
          objectId: 'obj_cama',
          objectLabel: null,
          cellRect: const ui.Rect.fromLTWH(0, 0, 36, 36),
          tileSize: 36,
        ),
        returnsNormally,
      );

      // Con label vacía
      expect(
        () => renderer.render(
          canvas: canvas,
          objectId: 'obj_mesa',
          objectLabel: '',
          cellRect: const ui.Rect.fromLTWH(0, 0, 80, 80),
          tileSize: 80,
        ),
        returnsNormally,
      );

      final picture = recorder.endRecording();
      picture.dispose();
    });
  });
}
