import 'package:nexus_mortis/data/local/models/case_progress_embedded.dart';
import 'package:nexus_mortis/data/local/models/player_progress_entity.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';

/// Convierte datos entre la capa de Dominio (PlayerProgress) y la capa Local/Isar (PlayerProgressEntity).
class PlayerProgressMapper {
  PlayerProgressMapper._();

  /// Convierte Entity (Isar) a Dominio.
  static PlayerProgress toDomain(PlayerProgressEntity entity) {
    final Map<String, CaseProgress> casesMap = {};
    for (final c in entity.completedCases) {
      casesMap[c.caseId] = CaseProgress(
        caseId: c.caseId,
        completed: c.completed,
        starsEarned: c.starsEarned,
      );
    }

    return PlayerProgress(
      coins: entity.coins,
      totalStars: entity.totalStars,
      completedCases: casesMap,
    );
  }

  /// Convierte Dominio a Entity (Isar).
  static PlayerProgressEntity toEntity(PlayerProgress domain) {
    final entity = PlayerProgressEntity()
      ..id = 0
      ..coins = domain.coins
      ..totalStars = domain.totalStars;

    final List<CaseProgressEmbedded> embeddedList = [];
    domain.completedCases.forEach((key, value) {
      final embedded = CaseProgressEmbedded()
        ..caseId = value.caseId
        ..completed = value.completed
        ..starsEarned = value.starsEarned;
      embeddedList.add(embedded);
    });

    entity.completedCases = embeddedList;
    return entity;
  }
}
