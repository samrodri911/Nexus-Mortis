import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';

/// Calculador determinista y puro de estrellas y recompensas obtenidas.
class StarCalculator {
  const StarCalculator();

  /// Calcula el número de estrellas (0 a 3) en función del desempeño en la partida.
  int calculateStars({
    required bool solved,
    required PuzzleDifficulty difficulty,
    required int hintsUsed,
    required int mistakes,
    required Duration duration,
  }) {
    if (!solved) return 0;

    // 3 estrellas: resolución impecable (0 pistas y 0 errores).
    if (hintsUsed == 0 && mistakes == 0) {
      return 3;
    }

    // 2 estrellas: resolución con ayuda mínima (máx 1 pista y máx 2 errores).
    if (hintsUsed <= 1 && mistakes <= 2) {
      return 2;
    }

    // 1 estrella: caso resuelto con mayor nivel de ayuda o errores.
    return 1;
  }

  /// Calcula las monedas otorgadas de manera unificada y determinista.
  int calculateCoins({
    required bool solved,
    required PuzzleDifficulty difficulty,
    required int stars,
  }) {
    if (!solved) return 0;

    int baseCoins;
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        baseCoins = 50;
        break;
      case PuzzleDifficulty.medium:
        baseCoins = 100;
        break;
      case PuzzleDifficulty.hard:
        baseCoins = 150;
        break;
    }

    int starBonus;
    switch (stars) {
      case 3:
        starBonus = 50;
        break;
      case 2:
        starBonus = 25;
        break;
      default:
        starBonus = 0;
        break;
    }

    return baseCoins + starBonus;
  }
}
