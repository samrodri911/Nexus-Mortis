import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/results/services/star_calculator.dart';

void main() {
  const calculator = StarCalculator();

  group('StarCalculator', () {
    test('Retorna 0 estrellas si el puzzle no fue resuelto', () {
      final stars = calculator.calculateStars(
        solved: false,
        difficulty: PuzzleDifficulty.easy,
        hintsUsed: 0,
        mistakes: 0,
        duration: const Duration(minutes: 1),
      );
      expect(stars, 0);

      final coins = calculator.calculateCoins(
        solved: false,
        difficulty: PuzzleDifficulty.easy,
        stars: stars,
      );
      expect(coins, 0);
    });

    test('Otorga 3 estrellas si 0 pistas y 0 errores', () {
      final stars = calculator.calculateStars(
        solved: true,
        difficulty: PuzzleDifficulty.medium,
        hintsUsed: 0,
        mistakes: 0,
        duration: const Duration(minutes: 2),
      );
      expect(stars, 3);

      final coins = calculator.calculateCoins(
        solved: true,
        difficulty: PuzzleDifficulty.medium,
        stars: stars,
      );
      // Base medium = 100 + bonus 3 estrellas (50) = 150
      expect(coins, 150);
    });

    test('Otorga 2 estrellas si 1 pista y 0 errores', () {
      final stars = calculator.calculateStars(
        solved: true,
        difficulty: PuzzleDifficulty.easy,
        hintsUsed: 1,
        mistakes: 0,
        duration: const Duration(minutes: 1),
      );
      expect(stars, 2);

      final coins = calculator.calculateCoins(
        solved: true,
        difficulty: PuzzleDifficulty.easy,
        stars: stars,
      );
      // Base easy = 50 + bonus 2 estrellas (25) = 75
      expect(coins, 75);
    });

    test('Otorga 2 estrellas si 0 pistas y 2 errores', () {
      final stars = calculator.calculateStars(
        solved: true,
        difficulty: PuzzleDifficulty.hard,
        hintsUsed: 0,
        mistakes: 2,
        duration: const Duration(minutes: 3),
      );
      expect(stars, 2);

      final coins = calculator.calculateCoins(
        solved: true,
        difficulty: PuzzleDifficulty.hard,
        stars: stars,
      );
      // Base hard = 150 + bonus 2 estrellas (25) = 175
      expect(coins, 175);
    });

    test('Otorga 1 estrella si > 1 pista o > 2 errores', () {
      final stars1 = calculator.calculateStars(
        solved: true,
        difficulty: PuzzleDifficulty.hard,
        hintsUsed: 2,
        mistakes: 0,
        duration: const Duration(minutes: 5),
      );
      expect(stars1, 1);

      final stars2 = calculator.calculateStars(
        solved: true,
        difficulty: PuzzleDifficulty.hard,
        hintsUsed: 0,
        mistakes: 3,
        duration: const Duration(minutes: 5),
      );
      expect(stars2, 1);

      final coins = calculator.calculateCoins(
        solved: true,
        difficulty: PuzzleDifficulty.hard,
        stars: 1,
      );
      // Base hard = 150 + bonus 1 estrella (0) = 150
      expect(coins, 150);
    });
  });
}
