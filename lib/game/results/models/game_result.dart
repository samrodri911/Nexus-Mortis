import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';

/// Representación inmutable y pura en Dart del resultado obtenido en una partida.
class GameResult {
  const GameResult({
    required this.caseId,
    required this.caseOrigin,
    required this.solved,
    required this.stars,
    required this.coinsEarned,
    required this.hintsUsed,
    required this.mistakes,
    required this.duration,
    required this.difficulty,
  });

  final String caseId;
  final CaseOrigin caseOrigin;
  final bool solved;
  final int stars;
  final int coinsEarned;
  final int hintsUsed;
  final int mistakes;
  final Duration duration;
  final PuzzleDifficulty difficulty;

  GameResult copyWith({
    String? caseId,
    CaseOrigin? caseOrigin,
    bool? solved,
    int? stars,
    int? coinsEarned,
    int? hintsUsed,
    int? mistakes,
    Duration? duration,
    PuzzleDifficulty? difficulty,
  }) {
    return GameResult(
      caseId: caseId ?? this.caseId,
      caseOrigin: caseOrigin ?? this.caseOrigin,
      solved: solved ?? this.solved,
      stars: stars ?? this.stars,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      mistakes: mistakes ?? this.mistakes,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      caseId: json['caseId'] as String,
      caseOrigin: CaseOrigin.values.firstWhere(
        (e) => e.name == json['caseOrigin'],
        orElse: () => CaseOrigin.campaign,
      ),
      solved: json['solved'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
      coinsEarned: json['coinsEarned'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      mistakes: json['mistakes'] as int? ?? 0,
      duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
      difficulty: PuzzleDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => PuzzleDifficulty.easy,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'caseOrigin': caseOrigin.name,
      'solved': solved,
      'stars': stars,
      'coinsEarned': coinsEarned,
      'hintsUsed': hintsUsed,
      'mistakes': mistakes,
      'durationMs': duration.inMilliseconds,
      'difficulty': difficulty.name,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameResult &&
          runtimeType == other.runtimeType &&
          caseId == other.caseId &&
          caseOrigin == other.caseOrigin &&
          solved == other.solved &&
          stars == other.stars &&
          coinsEarned == other.coinsEarned &&
          hintsUsed == other.hintsUsed &&
          mistakes == other.mistakes &&
          duration == other.duration &&
          difficulty == other.difficulty;

  @override
  int get hashCode =>
      caseId.hashCode ^
      caseOrigin.hashCode ^
      solved.hashCode ^
      stars.hashCode ^
      coinsEarned.hashCode ^
      hintsUsed.hashCode ^
      mistakes.hashCode ^
      duration.hashCode ^
      difficulty.hashCode;

  @override
  String toString() {
    return 'GameResult(caseId: $caseId, solved: $solved, stars: $stars, coinsEarned: $coinsEarned, hintsUsed: $hintsUsed, mistakes: $mistakes, duration: ${duration.inSeconds}s)';
  }
}
