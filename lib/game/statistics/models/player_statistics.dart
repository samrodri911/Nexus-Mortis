import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';

/// Modelo de dominio inmutable para las estadísticas acumuladas del jugador.
class PlayerStatistics {
  const PlayerStatistics({
    required this.puzzlesSolved,
    required this.totalPlayTime,
    required this.totalHintsUsed,
    required this.totalCoinsEarned,
    required this.totalStarsEarned,
    required this.campaignCasesSolved,
    required this.proceduralCasesSolved,
    required this.bestStarsPerCase,
  });

  factory PlayerStatistics.empty() {
    return const PlayerStatistics(
      puzzlesSolved: 0,
      totalPlayTime: Duration.zero,
      totalHintsUsed: 0,
      totalCoinsEarned: 0,
      totalStarsEarned: 0,
      campaignCasesSolved: 0,
      proceduralCasesSolved: 0,
      bestStarsPerCase: {},
    );
  }

  final int puzzlesSolved;
  final Duration totalPlayTime;
  final int totalHintsUsed;
  final int totalCoinsEarned;
  final int totalStarsEarned;
  final int campaignCasesSolved;
  final int proceduralCasesSolved;
  final Map<String, int> bestStarsPerCase;

  /// Retorna una nueva instancia acumulando los datos del resultado de una partida resuelta.
  PlayerStatistics copyWithResult(GameResult result) {
    if (!result.solved) return this;

    final newBestStars = Map<String, int>.from(bestStarsPerCase);
    final previousStars = newBestStars[result.caseId] ?? 0;
    if (result.stars > previousStars) {
      newBestStars[result.caseId] = result.stars;
    }

    final isCampaign = result.caseOrigin == CaseOrigin.campaign;

    return PlayerStatistics(
      puzzlesSolved: puzzlesSolved + 1,
      totalPlayTime: totalPlayTime + result.duration,
      totalHintsUsed: totalHintsUsed + result.hintsUsed,
      totalCoinsEarned: totalCoinsEarned + result.coinsEarned,
      totalStarsEarned: totalStarsEarned + result.stars,
      campaignCasesSolved: isCampaign ? campaignCasesSolved + 1 : campaignCasesSolved,
      proceduralCasesSolved: !isCampaign ? proceduralCasesSolved + 1 : proceduralCasesSolved,
      bestStarsPerCase: newBestStars,
    );
  }

  PlayerStatistics copyWith({
    int? puzzlesSolved,
    Duration? totalPlayTime,
    int? totalHintsUsed,
    int? totalCoinsEarned,
    int? totalStarsEarned,
    int? campaignCasesSolved,
    int? proceduralCasesSolved,
    Map<String, int>? bestStarsPerCase,
  }) {
    return PlayerStatistics(
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalStarsEarned: totalStarsEarned ?? this.totalStarsEarned,
      campaignCasesSolved: campaignCasesSolved ?? this.campaignCasesSolved,
      proceduralCasesSolved: proceduralCasesSolved ?? this.proceduralCasesSolved,
      bestStarsPerCase: bestStarsPerCase ?? this.bestStarsPerCase,
    );
  }
}
