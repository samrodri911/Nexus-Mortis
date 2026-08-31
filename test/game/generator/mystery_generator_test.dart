import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/generator/services/mystery_generator.dart';

void main() {
  const mysteryGen = MysteryGenerator();

  test('Genera premisa y nombres de zonas deterministas según semilla', () {
    final m1 = mysteryGen.generate(12345, 3);
    final m2 = mysteryGen.generate(12345, 3);

    expect(m1.title, equals(m2.title));
    expect(m1.description, equals(m2.description));
    expect(m1.zoneNames, equals(m2.zoneNames));
    expect(m1.zoneNames.length, equals(3));
    expect(m1.title.isNotEmpty, isTrue);
    expect(m1.description.isNotEmpty, isTrue);
  });
}
