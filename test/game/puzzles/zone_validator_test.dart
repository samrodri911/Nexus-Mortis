import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/utils/zone_validator.dart';

void main() {
  group('ZoneValidator Tests', () {
    test('Valida correctamente una partición perfecta y contigua de 3x3 en 2 zonas', () {
      final zones = [
        const ZoneData(
          id: 'z1',
          name: 'Zona 1',
          cells: [
            CellPosition(0, 0),
            CellPosition(0, 1),
            CellPosition(0, 2),
            CellPosition(1, 0),
          ],
        ),
        const ZoneData(
          id: 'z2',
          name: 'Zona 2',
          cells: [
            CellPosition(1, 1),
            CellPosition(1, 2),
            CellPosition(2, 0),
            CellPosition(2, 1),
            CellPosition(2, 2),
          ],
        ),
      ];

      expect(ZoneValidator.validateZones(3, 3, zones), isTrue);
    });

    test('Rechaza zonas si falta alguna celda del tablero (hueco)', () {
      final zones = [
        const ZoneData(
          id: 'z1',
          cells: [
            CellPosition(0, 0),
            CellPosition(0, 1),
          ],
        ),
      ];

      expect(ZoneValidator.validateZones(2, 2, zones), isFalse);
    });

    test('Rechaza zonas con celdas solapadas en múltiples zonas', () {
      final zones = [
        const ZoneData(
          id: 'z1',
          cells: [
            CellPosition(0, 0),
            CellPosition(0, 1),
          ],
        ),
        const ZoneData(
          id: 'z2',
          cells: [
            CellPosition(0, 1),
            CellPosition(1, 0),
            CellPosition(1, 1),
          ],
        ),
      ];

      expect(ZoneValidator.validateZones(2, 2, zones), isFalse);
    });

    test('Rechaza zonas no contiguas (celdas desconectadas ortogonalmente)', () {
      final zones = [
        const ZoneData(
          id: 'z1',
          cells: [
            CellPosition(0, 0),
            CellPosition(1, 1),
          ],
        ),
        const ZoneData(
          id: 'z2',
          cells: [
            CellPosition(0, 1),
            CellPosition(1, 0),
          ],
        ),
      ];

      expect(ZoneValidator.validateZones(2, 2, zones), isFalse);
    });

    test('Rechaza zonas con IDs duplicados', () {
      final zones = [
        const ZoneData(
          id: 'z1',
          cells: [
            CellPosition(0, 0),
            CellPosition(0, 1),
          ],
        ),
        const ZoneData(
          id: 'z1',
          cells: [
            CellPosition(1, 0),
            CellPosition(1, 1),
          ],
        ),
      ];

      expect(ZoneValidator.validateZones(2, 2, zones), isFalse);
    });
  });
}
