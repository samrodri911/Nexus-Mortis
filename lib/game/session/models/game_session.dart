import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/session/models/game_session_status.dart';

/// Representación inmutable de la sesión de juego en memoria.
class GameSession {
  const GameSession({
    required this.caseId,
    required this.origin,
    required this.status,
    required this.startedAt,
    this.lastResumedAt,
    this.pausedAt,
    this.completedAt,
  });

  final String caseId;
  final CaseOrigin origin;
  final GameSessionStatus status;
  final DateTime startedAt;
  final DateTime? lastResumedAt;
  final DateTime? pausedAt;
  final DateTime? completedAt;

  GameSession copyWith({
    String? caseId,
    CaseOrigin? origin,
    GameSessionStatus? status,
    DateTime? startedAt,
    DateTime? lastResumedAt,
    DateTime? pausedAt,
    DateTime? completedAt,
  }) {
    return GameSession(
      caseId: caseId ?? this.caseId,
      origin: origin ?? this.origin,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      lastResumedAt: lastResumedAt ?? this.lastResumedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
