import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/data/repositories/achievement_repository.dart';
import 'package:nexus_mortis/game/achievements/definitions/default_achievements.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_condition_type.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_definition.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';
import 'package:nexus_mortis/game/statistics/models/player_statistics.dart';

/// Servicio encargado de evaluar y persistir el desbloqueo de logros.
class AchievementService {
  AchievementService(
    this._repository, {
    this.definitions = DefaultAchievements.all,
    Map<String, AchievementProgress>? initialProgress,
  }) {
    achievementsNotifier = ValueNotifier<Map<String, AchievementProgress>>(
      initialProgress ?? {},
    );
  }

  final AchievementRepository _repository;
  final List<AchievementDefinition> definitions;
  late final ValueNotifier<Map<String, AchievementProgress>> achievementsNotifier;

  Map<String, AchievementProgress> get progressMap => achievementsNotifier.value;

  /// Retorna si un logro específico está desbloqueado.
  bool isUnlocked(String achievementId) {
    return progressMap[achievementId]?.isUnlocked ?? false;
  }

  /// Procesa el resultado de una partida y las estadísticas del jugador, evaluando y
  /// desbloqueando logros declarativos. Retorna los logros desbloqueados en esta llamada.
  Future<List<AchievementDefinition>> processResult({
    required GameResult result,
    required PlayerStatistics statistics,
    required PlayerProgress playerProgress,
    List<CaseData> campaignCases = const [],
  }) async {
    final effectiveCampaignCases =
        campaignCases.isNotEmpty ? campaignCases : CaseRegistry.cases;

    final updatedMap = Map<String, AchievementProgress>.from(progressMap);
    final newlyUnlocked = <AchievementDefinition>[];
    final changedProgresses = <AchievementProgress>[];

    for (final def in definitions) {
      final existing = updatedMap[def.id] ??
          AchievementProgress(
            achievementId: def.id,
            currentValue: 0,
            isUnlocked: false,
          );

      // Si ya estaba desbloqueado, permanece desbloqueado
      if (existing.isUnlocked) {
        continue;
      }

      int currentVal = existing.currentValue;
      bool isMet = false;

      switch (def.conditionType) {
        case AchievementConditionType.puzzlesSolved:
          currentVal = statistics.puzzlesSolved;
          isMet = currentVal >= def.targetValue;
          break;

        case AchievementConditionType.starsEarned:
          currentVal = statistics.totalStarsEarned;
          isMet = currentVal >= def.targetValue;
          break;

        case AchievementConditionType.threeStarsCase:
          if (result.solved && result.stars == 3) {
            currentVal = 1;
            isMet = true;
          }
          break;

        case AchievementConditionType.noHintsUsed:
          if (result.solved && result.hintsUsed == 0) {
            currentVal = 1;
            isMet = true;
          }
          break;

        case AchievementConditionType.campaignComplete:
          final campaignIds = effectiveCampaignCases.map((c) => c.id).toSet();
          final completedCampaignIds = playerProgress.completedCases.keys
              .where((id) => campaignIds.contains(id))
              .toSet();
          currentVal = completedCampaignIds.length;
          isMet = campaignIds.isNotEmpty && completedCampaignIds.length == campaignIds.length;
          break;

        case AchievementConditionType.proceduralSolved:
          currentVal = statistics.proceduralCasesSolved;
          isMet = currentVal >= def.targetValue;
          break;
      }

      final updatedProgress = existing.copyWith(
        currentValue: currentVal,
        isUnlocked: isMet,
        unlockedAt: isMet ? DateTime.now() : existing.unlockedAt,
      );

      updatedMap[def.id] = updatedProgress;
      changedProgresses.add(updatedProgress);

      if (isMet) {
        newlyUnlocked.add(def);
      }
    }

    if (changedProgresses.isNotEmpty) {
      achievementsNotifier.value = updatedMap;
      await _repository.saveAll(changedProgresses);
    }

    return newlyUnlocked;
  }
}
