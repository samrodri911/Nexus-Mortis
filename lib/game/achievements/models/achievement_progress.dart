/// Estado inmutable del progreso y desbloqueo de un logro.
class AchievementProgress {
  const AchievementProgress({
    required this.achievementId,
    required this.currentValue,
    required this.isUnlocked,
    this.unlockedAt,
  });

  final String achievementId;
  final int currentValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementProgress copyWith({
    String? achievementId,
    int? currentValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
