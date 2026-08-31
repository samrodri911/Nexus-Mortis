import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/generator/services/clue_text_formatter.dart';

void main() {
  const formatter = ClueTextFormatter();

  const suspects = {'s_carlos': 'Carlos', 's_ana': 'Ana', 'victim': 'Víctima'};
  const objects = {'obj_fuente': 'fuente', 'obj_reloj': 'reloj'};
  const zones = {'z_invernadero': 'Invernadero', 'z_biblioteca': 'Biblioteca'};

  test('Formatea pistas en lenguaje natural sin exponer IDs técnicos', () {
    const clue1 = SpatialClueData(
      id: 'c1',
      text: '',
      relation: SpatialRelation.leftOf,
      suspectId: 's_carlos',
      targetId: 'obj_fuente',
    );

    const clue2 = SpatialClueData(
      id: 'c2',
      text: '',
      relation: SpatialRelation.inZone,
      suspectId: 's_ana',
      targetId: 'z_biblioteca',
    );

    const clue3 = SpatialClueData(
      id: 'c3',
      text: '',
      relation: SpatialRelation.sameRow,
      suspectId: 's_carlos',
      targetId: 'victim',
    );

    final text1 = formatter.format(
      clue: clue1,
      suspectNames: suspects,
      objectNames: objects,
      zoneNames: zones,
      victimId: 'victim',
    );

    final text2 = formatter.format(
      clue: clue2,
      suspectNames: suspects,
      objectNames: objects,
      zoneNames: zones,
      victimId: 'victim',
    );

    final text3 = formatter.format(
      clue: clue3,
      suspectNames: suspects,
      objectNames: objects,
      zoneNames: zones,
      victimId: 'victim',
    );

    expect(text1, equals('Carlos estaba al oeste de la fuente.'));
    expect(text2, equals('Ana se encontraba en la Biblioteca.'));
    expect(text3, equals('Carlos estaba en la misma fila que la víctima.'));

    expect(text1.contains('s_carlos'), isFalse);
    expect(text1.contains('obj_fuente'), isFalse);
  });
}
