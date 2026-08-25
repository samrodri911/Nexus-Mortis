import 'package:nexus_mortis/game/achievements/models/achievement_condition_type.dart';

/// Definición declarativa de un logro dentro del juego.
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.conditionType,
    this.targetValue = 1,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementConditionType conditionType;
  final int targetValue;
}
