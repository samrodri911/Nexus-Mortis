import 'dart:convert';
import 'package:nexus_mortis/data/local/models/statistics_entity.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';

/// Mapeador entre [PlayerStatistics] del dominio y [StatisticsEntity] de Isar.
class StatisticsMapper {
  StatisticsMapper._();

  static PlayerStatistics toDomain(StatisticsEntity entity) {
    Map<String, int> bestStars = {};
    if (entity.bestStarsJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(entity.bestStarsJson) as Map<String, dynamic>;
        bestStars = decoded.map((k, v) => MapEntry(k, v as int));
      } catch (_) {}
    }

    return PlayerStatistics(
      puzzlesSolved: entity.puzzlesSolved,
      totalPlayTime: Duration(seconds: entity.totalPlayTimeSeconds),
      totalHintsUsed: entity.totalHintsUsed,
      totalCoinsEarned: entity.totalCoinsEarned,
      totalStarsEarned: entity.totalStarsEarned,
      campaignCasesSolved: entity.campaignCasesSolved,
      proceduralCasesSolved: entity.proceduralCasesSolved,
      bestStarsPerCase: bestStars,
    );
  }

  static StatisticsEntity toEntity(PlayerStatistics domain) {
    final entity = StatisticsEntity()
      ..id = 0
      ..puzzlesSolved = domain.puzzlesSolved
      ..totalPlayTimeSeconds = domain.totalPlayTime.inSeconds
      ..totalHintsUsed = domain.totalHintsUsed
      ..totalCoinsEarned = domain.totalCoinsEarned
      ..totalStarsEarned = domain.totalStarsEarned
      ..campaignCasesSolved = domain.campaignCasesSolved
      ..proceduralCasesSolved = domain.proceduralCasesSolved
      ..bestStarsJson = jsonEncode(domain.bestStarsPerCase);

    return entity;
  }
}
