import 'dart:math';

import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/generator/models/generator_catalog.dart';

/// Selecciona un subconjunto aleatorio de sospechosos y objetos del catálogo.
class ObjectPlacer {
  const ObjectPlacer(this._random);

  final Random _random;

  List<SuspectData> selectSuspects(int count) {
    if (count > GeneratorCatalog.suspects.length) {
      throw ArgumentError('Cannot select more suspects than available.');
    }
    final shuffled = List<SuspectData>.from(GeneratorCatalog.suspects)
      ..shuffle(_random);
    return shuffled.take(count).toList();
  }

  List<ObjectData> selectObjects(int count) {
    if (count > GeneratorCatalog.objects.length) {
      throw ArgumentError('Cannot select more objects than available.');
    }
    final shuffled = List<ObjectData>.from(GeneratorCatalog.objects)
      ..shuffle(_random);
    return shuffled.take(count).toList();
  }
}
