import 'package:nexus_mortis/game/achievements/models/achievement_condition_type.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_definition.dart';

/// Catálogo declarativo de logros iniciales de Nexus Mortis.
class DefaultAchievements {
  DefaultAchievements._();

  static const List<AchievementDefinition> all = [
    AchievementDefinition(
      id: 'first_case',
      title: 'Primer Caso',
      description: 'Resuelve tu primer caso de investigación.',
      iconName: 'search',
      conditionType: AchievementConditionType.puzzlesSolved,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: 'solve_3_cases',
      title: 'Detective Novato',
      description: 'Resuelve 3 casos exitosamente.',
      iconName: 'badge',
      conditionType: AchievementConditionType.puzzlesSolved,
      targetValue: 3,
    ),
    AchievementDefinition(
      id: 'solve_10_cases',
      title: 'Mente Brillante',
      description: 'Resuelve 10 casos de investigación.',
      iconName: 'psychology',
      conditionType: AchievementConditionType.puzzlesSolved,
      targetValue: 10,
    ),
    AchievementDefinition(
      id: 'first_3_stars',
      title: 'Perfección',
      description: 'Obtén 3 estrellas en un caso.',
      iconName: 'star',
      conditionType: AchievementConditionType.threeStarsCase,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: 'master_stars',
      title: 'Constelación',
      description: 'Acumula un total de 15 estrellas.',
      iconName: 'auto_awesome',
      conditionType: AchievementConditionType.starsEarned,
      targetValue: 15,
    ),
    AchievementDefinition(
      id: 'no_hints',
      title: 'Intuición Pura',
      description: 'Resuelve un caso sin utilizar pistas.',
      iconName: 'lightbulb',
      conditionType: AchievementConditionType.noHintsUsed,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: 'campaign_complete',
      title: 'Caso Cerrado',
      description: 'Completa todos los casos de la campaña.',
      iconName: 'military_tech',
      conditionType: AchievementConditionType.campaignComplete,
      targetValue: 1,
    ),
    AchievementDefinition(
      id: 'first_procedural',
      title: 'Territorio Desconocido',
      description: 'Resuelve tu primer caso procedimental.',
      iconName: 'explore',
      conditionType: AchievementConditionType.proceduralSolved,
      targetValue: 1,
    ),
  ];
}
