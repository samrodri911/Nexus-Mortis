import 'package:nexus_mortis/game/progression/models/case_progress.dart';

/// Contenedor global del progreso del jugador en el metajuego.
///
/// Mantenido inmutable. Cada cambio genera una nueva instancia para
/// facilitar la reactividad con ValueNotifier.
class PlayerProgress {
  const PlayerProgress({
    required this.coins,
    required this.totalStars,
    required this.completedCases,
  });

  /// Constructor inicial para un jugador nuevo.
  factory PlayerProgress.empty() {
    return const PlayerProgress(
      coins: 500, // 500 monedas iniciales para la demo/testing.
      totalStars: 0,
      completedCases: {},
    );
  }

  final int coins;
  final int totalStars;
  final Map<String, CaseProgress> completedCases;

  /// Retorna una nueva instancia con las recompensas aplicadas.
  PlayerProgress copyWithCompletion({
    required String caseId,
    required int earnedCoins,
    required int earnedStars,
  }) {
    final newCases = Map<String, CaseProgress>.from(completedCases);
    
    // Si ya estaba completado, podríamos sobreescribir las estrellas si son más,
    // pero por ahora simplificamos a guardarlo.
    newCases[caseId] = CaseProgress(
      caseId: caseId,
      completed: true,
      starsEarned: earnedStars,
    );

    return PlayerProgress(
      coins: coins + earnedCoins,
      totalStars: totalStars + earnedStars,
      completedCases: newCases,
    );
  }

  /// Retorna una nueva instancia restando monedas (para comprar pistas).
  PlayerProgress copyWithSpend(int amount) {
    return PlayerProgress(
      coins: coins - amount,
      totalStars: totalStars,
      completedCases: completedCases,
    );
  }

  /// Retorna una nueva instancia añadiendo monedas extras (recompensas, etc).
  PlayerProgress copyWithAdd(int amount) {
    return PlayerProgress(
      coins: coins + amount,
      totalStars: totalStars,
      completedCases: completedCases,
    );
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final casesMap = json['completedCases'] as Map<String, dynamic>? ?? {};
    final completedCases = <String, CaseProgress>{};
    
    casesMap.forEach((key, value) {
      completedCases[key] = CaseProgress.fromJson(value as Map<String, dynamic>);
    });

    return PlayerProgress(
      coins: json['coins'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      completedCases: completedCases,
    );
  }

  Map<String, dynamic> toJson() {
    final casesMap = <String, dynamic>{};
    completedCases.forEach((key, value) {
      casesMap[key] = value.toJson();
    });

    return {
      'coins': coins,
      'totalStars': totalStars,
      'completedCases': casesMap,
    };
  }
}
