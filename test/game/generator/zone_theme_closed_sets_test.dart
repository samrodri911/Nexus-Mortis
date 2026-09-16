import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/mystery_generator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  group('ZoneTheme & Sets Cerrados — Validación Temática y Deductiva (V3.4)', () {
    const mysteryGen = MysteryGenerator();
    final puzzleGen = PuzzleGenerator();
    final solver = PuzzleSolver();
    const replay = HumanDeductionReplay();

    test('Cada GeneratedMystery pertenece estrictamente a un único ZoneTheme y a su set cerrado', () {
      for (final theme in ZoneTheme.values) {
        final mystery = mysteryGen.generate(42, 4, forcedTheme: theme);

        expect(mystery.theme, equals(theme));
        expect(mystery.zoneNames.length, equals(4));

        final allowedNames = theme.availableZoneNames.toSet();

        for (final name in mystery.zoneNames) {
          expect(allowedNames.contains(name), isTrue,
              reason: 'La habitación "$name" debe pertenecer exclusivamente al set de ${theme.name}');
          expect(name.startsWith('Área #'), isFalse);
          expect(name.startsWith('Zona #'), isFalse);
        }
      }
    });

    test('Nunca se mezclan nombres entre sets diferentes en 50 generaciones aleatorias', () {
      for (int seed = 100; seed < 150; seed++) {
        final mystery = mysteryGen.generate(seed, 4);
        final currentTheme = mystery.theme;

        final allowedNames = currentTheme.availableZoneNames.toSet();

        // Verificar que no contenga nombres de los otros 3 temas
        for (final otherTheme in ZoneTheme.values) {
          if (otherTheme == currentTheme) continue;
          for (final foreignName in otherTheme.availableZoneNames) {
            // A menos que un nombre sea compartido intencionalmente (como 'Vestíbulo' en mansión y teatro)
            if (!allowedNames.contains(foreignName)) {
              expect(mystery.zoneNames.contains(foreignName), isFalse,
                  reason: 'El caso del tema ${currentTheme.name} contiene "$foreignName" del tema ${otherTheme.name}');
            }
          }
        }
      }
    });

    test('Generador procedural produce casos completos con ZoneTheme válido y consistencia temática', () {
      final config = GeneratorConfig(
        rows: 4,
        columns: 4,
        suspectCount: 3,
        objectCount: 2,
        randomSeed: 2026,
        targetDifficulty: DifficultyLevel.easy,
        maxAttempts: 15,
      );

      final result = puzzleGen.generate(config);
      expect(result, isNotNull);

      final puzzle = result!.caseData;
      expect(puzzle.zoneTheme, isNotNull);

      final allowedSet = puzzle.zoneTheme!.availableZoneNames.toSet();
      for (final zone in puzzle.zones) {
        expect(allowedSet.contains(zone.name), isTrue,
            reason: 'La zona ${zone.name} debe pertenecer a ${puzzle.zoneTheme!.name}');
      }
    });

    test('Regresión Obligatoria: Solver == GroundTruth y HumanDeductionReplay == GroundTruth', () {
      final testSeeds = [101, 202, 303, 404];

      for (final seed in testSeeds) {
        final config = GeneratorConfig(
          rows: 4,
          columns: 4,
          suspectCount: 3,
          objectCount: 2,
          randomSeed: seed,
          targetDifficulty: DifficultyLevel.easy,
          maxAttempts: 20,
        );

        final result = puzzleGen.generate(config);
        if (result == null) continue;

        final puzzle = result.caseData;

        // 1. Verificación Matemática: Solver == GroundTruth
        final solverResult = solver.solve(puzzle);
        expect(solverResult.isUnique, isTrue);
        expect(solverResult.solutions.length, equals(1));

        final solvedPositions = solverResult.solutions.first.suspectPositions;
        for (final entry in puzzle.solution.suspectPositions.entries) {
          expect(solvedPositions[entry.key], equals(entry.value),
              reason: 'Solver debe coincidir exactamente con Ground Truth para ${entry.key}');
        }

        // 2. Verificación Deductiva Humana: HumanDeductionReplay == GroundTruth
        final replayResult = replay.simulate(puzzle, puzzle.clues);
        expect(replayResult.solved, isTrue,
            reason: 'El replay deductivo paso a paso debe resolver el caso');

        for (final entry in puzzle.solution.suspectPositions.entries) {
          expect(replayResult.finalPositions[entry.key], equals(entry.value),
              reason: 'Replay humano debe coincidir exactamente con Ground Truth para ${entry.key}');
        }
      }
    });
  });
}
