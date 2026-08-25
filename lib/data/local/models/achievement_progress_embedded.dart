import 'package:isar/isar.dart';

part 'achievement_progress_embedded.g.dart';

/// Modelo de base de datos embebido para el progreso de un logro.
@embedded
class AchievementProgressEmbedded {
  late String achievementId;

  late int currentValue;

  late bool isUnlocked;

  DateTime? unlockedAt;
}
