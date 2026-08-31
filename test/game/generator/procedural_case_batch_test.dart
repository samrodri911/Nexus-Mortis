import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/local/mappers/case_data_mapper.dart';
import 'package:nexus_mortis/data/local/models/campaign_case_entity.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  final solver = PuzzleSolver();
  final validator = CaseIntegrityValidator(solver: solver);
  final generator = PuzzleGenerator(solver: solver);

  group('Procedural Case Quality & Batch Validation Tests', () {
    test('Genera un lote de casos procedimentales y verifica integridad, solución única y persistencia', () async {
      final repo = InMemoryCampaignCaseRepository();
      final _ = CaseCampaignService(
        campaignCaseRepository: repo,
        puzzleGenerator: generator,
        validator: validator,
      );

      // Generar 15 casos procedimentales con diferentes semillas y configuraciones
      for (int i = 1; i <= 15; i++) {
        final seed = 100000 + i * 777;
        final config = GeneratorConfig(
          rows: 4,
          columns: 4,
          suspectCount: 3,
          objectCount: 2,
          randomSeed: seed,
        );

        final result = generator.generate(config);
        expect(result, isNotNull, reason: 'El generador debe producir un caso para la semilla \$seed');

        final caseData = result!.caseData;

        // 1. Integridad general
        expect(validator.validate(caseData), isTrue, reason: 'El caso \$i debe pasar CaseIntegrityValidator');

        // 2. Calidad de pistas
        expect(caseData.clues.isNotEmpty, isTrue);
        for (final clue in caseData.clues) {
          expect(clue.text.trim().isNotEmpty, isTrue, reason: 'Pista \${clue.id} no debe tener texto vacío');
          expect(clue.text.contains('suspect_'), isFalse, reason: 'Pista no debe contener IDs técnicos');
          expect(clue.text.contains('obj_'), isFalse, reason: 'Pista no debe contener IDs técnicos');
          expect(clue.text.contains('z_'), isFalse, reason: 'Pista no debe contener IDs técnicos');
        }

        // 3. Calidad de zonas y narrativa
        expect(caseData.title.isNotEmpty, isTrue);
        expect(caseData.description.isNotEmpty, isTrue);
        expect(caseData.zones.isNotEmpty, isTrue);

        // 4. Regla de asesinato
        final victimPos = caseData.solution.suspectPositions[caseData.victimId]!;
        final killerPos = caseData.solution.suspectPositions[caseData.killerId]!;
        final zoneMap = {
          for (final z in caseData.zones)
            for (final c in z.cells) c: z.id,
        };

        expect(zoneMap[victimPos], equals(zoneMap[killerPos]), reason: 'Víctima y asesino deben compartir zona');

        // 5. Persistencia y Round-trip en Repositorio
        final entity = CampaignCaseEntity()
          ..caseId = 'case_p_\$i'
          ..caseIndex = i
          ..title = caseData.title
          ..description = caseData.description
          ..difficulty = caseData.difficulty.name
          ..seed = seed
          ..rows = caseData.boardRows
          ..columns = caseData.boardColumns
          ..suspects = caseData.suspects.length
          ..objects = caseData.placedObjects.length
          ..caseJson = jsonEncode(CaseDataMapper.toJson(caseData));

        await repo.saveCases([entity]);

        final loadedEntities = await repo.getAllCases();
        final loadedEntity = loadedEntities.firstWhere((e) => e.caseId == 'case_p_\$i');
        final restoredCase = CaseDataMapper.fromJson(jsonDecode(loadedEntity.caseJson!) as Map<String, dynamic>);

        expect(restoredCase.title, equals(caseData.title));
        expect(restoredCase.clues.length, equals(caseData.clues.length));
        for (int cIdx = 0; cIdx < caseData.clues.length; cIdx++) {
          expect(restoredCase.clues[cIdx].text, equals(caseData.clues[cIdx].text));
        }
        expect(restoredCase.solution.suspectPositions, equals(caseData.solution.suspectPositions));
      }
    }, timeout: const Timeout(Duration(seconds: 120)));
  });
}
