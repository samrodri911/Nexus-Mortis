import 'package:isar/isar.dart';

part 'active_game_entity.g.dart';

/// Modelo de base de datos para almacenar el estado de la partida en curso.
@collection
class ActiveGameEntity {
  /// ID fijo en 0, ya que solo puede haber una partida en curso a la vez.
  Id id = 0;

  /// ID del caso que se está jugando.
  late String caseId;

  /// Serialización JSON de la grilla de celdas.
  /// Se usa JSON para no complicar el esquema Isar con anidamientos profundos
  /// de listas y conjuntos que no requieren búsquedas individuales.
  late String stateJson;

  /// Fecha y hora en la que se guardó.
  late DateTime savedAt;
}
