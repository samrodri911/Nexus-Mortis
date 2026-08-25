import 'package:isar/isar.dart';

part 'statistics_entity.g.dart';

/// Modelo de base de datos Isar para almacenar las estadísticas agregadas del jugador.
@collection
class StatisticsEntity {
  /// ID fijo en 0 para mantener un único registro global de estadísticas.
  Id id = 0;

  late int puzzlesSolved;

  late int totalPlayTimeSeconds;

  late int totalHintsUsed;

  late int totalCoinsEarned;

  late int totalStarsEarned;

  late int campaignCasesSolved;

  late int proceduralCasesSolved;

  /// Mapa de ID de caso a mejores estrellas obtenidas, serializado en JSON.
  late String bestStarsJson;
}
