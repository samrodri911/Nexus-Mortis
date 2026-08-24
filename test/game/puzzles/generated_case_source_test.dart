import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/generated_case_metadata.dart';
import 'package:nexus_mortis/game/puzzles/services/case_identity_factory.dart';
import 'package:nexus_mortis/game/puzzles/sources/generated_case_source.dart';

void main() {
  group('GeneratedCaseSource', () {
    test('generateNew and reconstructCase produce identical puzzles', () async {
      final source = GeneratedCaseSource();
      final identityFactory = const CaseIdentityFactory();

      final config = GeneratorConfig(
        rows: 3,
        columns: 3,
        suspectCount: 3,
        objectCount: 2,
        randomSeed: 999, // Semilla fija
      );

      // Generar nuevo
      final newCase = source.generateNew(config, identityFactory);

      expect(newCase.id, 'procedural_999');
      expect(newCase.origin, CaseOrigin.procedural);
      
      final cluesCount = newCase.clues.length;

      // Reconstruir
      final metadata = GeneratedCaseMetadata(
        rows: 3,
        columns: 3,
        suspects: 3,
        objects: 2,
        difficulty: config.targetDifficulty ?? DifficultyLevel.medium,
        seed: 999,
      );

      final reconstructedCase = await source.reconstructCase(newCase.id, metadata);

      expect(reconstructedCase, isNotNull);
      expect(reconstructedCase!.id, newCase.id);
      expect(reconstructedCase.clues.length, cluesCount);
      expect(
        reconstructedCase.solution.suspectPositions, 
        newCase.solution.suspectPositions,
      );
    });
  });
}
