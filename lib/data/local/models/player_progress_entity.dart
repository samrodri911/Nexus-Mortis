import 'package:isar/isar.dart';
import 'package:nexus_mortis/data/local/models/case_progress_embedded.dart';

part 'player_progress_entity.g.dart';

/// Modelo de base de datos principal para el progreso del jugador.
@collection
class PlayerProgressEntity {
  /// ID fijo en 0, ya que solo guardamos el progreso de un jugador global.
  Id id = 0;

  /// Monedas acumuladas.
  late int coins;

  /// Estrellas acumuladas.
  late int totalStars;

  /// Lista embebida de casos completados.
  List<CaseProgressEmbedded> completedCases = [];
}
