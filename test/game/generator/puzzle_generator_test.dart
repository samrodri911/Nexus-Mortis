import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/generator/models/generator_catalog.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/generator/services/solution_generator.dart';

void main() {
  group('SolutionGenerator', () {
    test('generateSolution crea posiciones válidas y únicas', () {
      final generator = SolutionGenerator(Random(42));
      final suspects = GeneratorCatalog.suspects.take(2).toList();
      final objects = GeneratorCatalog.objects.take(1).toList();

      final result = generator.generateSolution(
        rows: 2,
        columns: 2,
        suspects: suspects,
        objects: objects,
      );

      expect(result.solution.suspectPositions.length, 2);
      expect(result.objectPositions.length, 1);
      
      final allPos = [
        ...result.solution.suspectPositions.values,
        ...result.objectPositions.values,
      ];
      final uniquePos = allPos.map((e) => '${e.row},${e.col}').toSet();
      expect(uniquePos.length, 3);
    });

    test('generateSolution lanza ArgumentError si no hay espacio', () {
      final generator = SolutionGenerator(Random(42));
      final suspects = GeneratorCatalog.suspects.take(4).toList();
      final objects = GeneratorCatalog.objects.take(2).toList();

      expect(
        () => generator.generateSolution(
          rows: 2,
          columns: 2, // Solo caben 4 celdas en total
          suspects: suspects,
          objects: objects,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PuzzleGenerator', () {
    test('generate crea un puzzle válido y determinista dada una semilla', () {
      final generator = PuzzleGenerator();
      final config = GeneratorConfig(
        rows: 3,
        columns: 3,
        suspectCount: 3,
        objectCount: 2,
        randomSeed: 12345,
      );

      final result1 = generator.generate(config);
      final result2 = generator.generate(config);

      expect(result1, isNotNull);
      expect(result2, isNotNull);
      
      // Validar reproducibilidad
      expect(result1!.caseData.clues.length, result2!.caseData.clues.length);
      expect(
        result1.caseData.solution.suspectPositions, 
        result2.caseData.solution.suspectPositions,
      );

      // Validar algunas propiedades
      expect(result1.caseData.suspects.length, 3);
      expect(result1.caseData.placedObjects.length, 2);
      // El pruning debe reducir la cantidad de pistas a un conjunto menor o igual al total
      expect(result1.caseData.clues.length, greaterThan(0));
    });

    test('generate retorna null si es imposible físicamente', () {
      final generator = PuzzleGenerator();
      final config = GeneratorConfig(
        rows: 2,
        columns: 2,
        suspectCount: 4,
        objectCount: 2,
      );

      final result = generator.generate(config);
      expect(result, isNull);
    });
  });
}
