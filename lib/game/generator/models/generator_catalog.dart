import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';

/// Catálogo estático de entidades disponibles para el generador.
/// Esto asegura que los puzzles generados usen identificadores y nombres
/// consistentes con el resto del juego (por ejemplo, para cargar assets).
class GeneratorCatalog {
  const GeneratorCatalog._();

  static const List<SuspectData> suspects = [
    SuspectData(id: 'suspect_juan', name: 'Juan'),
    SuspectData(id: 'suspect_ana', name: 'Ana'),
    SuspectData(id: 'suspect_carlos', name: 'Carlos'),
    SuspectData(id: 'suspect_maria', name: 'María'),
    SuspectData(id: 'suspect_pedro', name: 'Pedro'),
    SuspectData(id: 'suspect_sofia', name: 'Sofía'),
    SuspectData(id: 'suspect_lucia', name: 'Lucía'),
    SuspectData(id: 'suspect_diego', name: 'Diego'),
  ];

  static const List<ObjectData> objects = [
    ObjectData(id: 'obj_cama', name: 'Cama'),
    ObjectData(id: 'obj_silla', name: 'Silla'),
    ObjectData(id: 'obj_mesa', name: 'Mesa'),
    ObjectData(id: 'obj_escritorio', name: 'Escritorio'),
    ObjectData(id: 'obj_librero', name: 'Librero'),
    ObjectData(id: 'obj_caja', name: 'Caja'),
    ObjectData(id: 'obj_lampara', name: 'Lámpara'),
    ObjectData(id: 'obj_armario', name: 'Armario'),
  ];
}
