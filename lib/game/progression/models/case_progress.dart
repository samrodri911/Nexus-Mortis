/// Representa el progreso del jugador en un caso específico.
class CaseProgress {
  const CaseProgress({
    required this.caseId,
    required this.completed,
    required this.starsEarned,
  });

  final String caseId;
  final bool completed;
  final int starsEarned;

  factory CaseProgress.fromJson(Map<String, dynamic> json) {
    return CaseProgress(
      caseId: json['caseId'] as String,
      completed: json['completed'] as bool? ?? false,
      starsEarned: json['starsEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'completed': completed,
      'starsEarned': starsEarned,
    };
  }
}
