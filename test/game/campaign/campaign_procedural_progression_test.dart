import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/difficulty/models/level_policy.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  group('Campaña Procedural Continua y Progresión Gradual de Dificultad (Niveles 0..49)', () {
    late PuzzleSolver solver;
    late HumanDeductionReplay replay;
    late CaseIntegrityValidator validator;
    late DifficultyAnalyzer analyzer;
    late PuzzleGenerator generator;

    setUp(() {
      solver = PuzzleSolver();
      replay = const HumanDeductionReplay();
      validator = CaseIntegrityValidator(solver: solver, simulator: replay);
      analyzer = DifficultyAnalyzer(solver);
      generator = PuzzleGenerator(solver: solver, analyzer: analyzer);
    });

    test('Nivel 0 es 100% procedural, accesible, determinista y de dificultad baja', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(
        campaignCaseRepository: repo,
        puzzleGenerator: generator,
        validator: validator,
        analyzer: analyzer,
        replay: replay,
      );

      await campaignService.ensureBatchAvailable(PlayerProgress.empty());
      final allCases = await campaignService.getAvailableCases();

      expect(allCases.isNotEmpty, isTrue);
      final level0Case = allCases.first;

      expect(level0Case.id, equals('case_001'));
      expect(level0Case.boardRows, equals(4));
      expect(level0Case.boardColumns, equals(4));
      expect(level0Case.suspects.length, equals(3)); // 2 inocentes + 1 víctima

      // Verificación de integridad estricta
      final valRes = validator.validateDetailed(level0Case);
      expect(valRes.isValid, isTrue, reason: 'Nivel 0 debe ser estrictamente válido: ${valRes.details}');

      // Simulación deductiva humana
      final simRes = replay.simulate(level0Case, level0Case.clues);
      expect(simRes.solved, isTrue);
      expect(simRes.requiresGuessing, isFalse);
      expect(simRes.victimCandidateCells, equals(1));
      expect(simRes.victimCandidateRooms, equals(1));

      // Dificultad baja calibrada
      final score = analyzer.calculateScore(level0Case, simResult: simRes);
      expect(score, inInclusiveRange(20, 42));
    });

    test('Generación de campaña por lotes y progresión suave de dificultad en niveles 0..49', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(
        campaignCaseRepository: repo,
        puzzleGenerator: generator,
        validator: validator,
        analyzer: analyzer,
        replay: replay,
      );

      // Generar 5 lotes de 10 casos cada uno (total 50 casos: Niveles 0..49)
      for (int batch = 0; batch < 5; batch++) {
        final cases = await campaignService.getAvailableCases();
        // Simular progreso completando hasta el último caso disponible
        final completed = {
          for (final c in cases)
            c.id: CaseProgress(caseId: c.id, completed: true, starsEarned: 3),
        };
        await campaignService.ensureBatchAvailable(PlayerProgress(coins: 100, totalStars: 100, completedCases: completed));
      }

      final allCases = await campaignService.getAvailableCases();
      expect(allCases.length, equals(50));

      final scores = <int>[];

      for (int i = 0; i < allCases.length; i++) {
        final caseData = allCases[i];
        final policy = LevelPolicy.forLevel(i);

        // 1. Verificar dimensiones y conteo de entidades según bloques
        expect(caseData.boardRows, equals(policy.rows), reason: 'Nivel $i filas');
        expect(caseData.boardColumns, equals(policy.columns), reason: 'Nivel $i columnas');
        expect(caseData.suspects.length, equals(policy.suspectCount), reason: 'Nivel $i sospechosos');
        expect(caseData.placedObjects.length, equals(policy.objectCount), reason: 'Nivel $i objetos');
        expect(caseData.globalRules.length, equals(1), reason: 'Nivel $i debe tener exactamente 1 regla global activa');
        expect(caseData.globalRules.first.text.isNotEmpty, isTrue, reason: 'Nivel $i texto de regla global');

        // 2. Validación de Integridad Dual Estricta
        final valRes = validator.validateDetailed(caseData);
        expect(valRes.isValid, isTrue, reason: 'Nivel $i inválido: ${valRes.details}');

        // 3. Simulación humana y métricas deductivas
        final simRes = replay.simulate(caseData, caseData.clues);
        expect(simRes.solved, isTrue, reason: 'Nivel $i no resoluble por HumanReplay');
        expect(simRes.requiresGuessing, isFalse, reason: 'Nivel $i requirió guessing');
        expect(simRes.victimCandidateCells, equals(1), reason: 'Nivel $i víctima ambiguo en celdas');
        expect(simRes.victimCandidateRooms, equals(1), reason: 'Nivel $i víctima ambiguo en habitaciones');
        expect(simRes.killerDeductionUnique, isTrue, reason: 'Nivel $i asesino no unívoco');

        // 4. Invariante de escena del crimen
        final victimPos = caseData.solution.suspectPositions[caseData.victimId]!;
        final killerPos = caseData.solution.suspectPositions[caseData.killerId]!;
        final victimZone = caseData.zones.firstWhere((z) => z.cells.contains(victimPos));
        expect(victimZone.cells.contains(killerPos), isTrue, reason: 'Nivel $i: asesino debe estar en la zona de la víctima');

        // 5. Score deductivo dentro de tolerancia de política
        final score = analyzer.calculateScore(caseData, simResult: simRes);
        scores.add(score);

        expect(
          score,
          inInclusiveRange(policy.minDifficultyScore, policy.maxDifficultyScore),
          reason: 'Nivel $i: score $score fuera de rango [${policy.minDifficultyScore}..${policy.maxDifficultyScore}]',
        );

        // 6. Verificación de continuidad (sin saltos bruscos)
        if (i > 0) {
          final prevScore = scores[i - 1];
          final delta = (score - prevScore).abs();
          expect(delta, lessThanOrEqualTo(policy.maxDeltaFromPrevious + 1),
              reason: 'Nivel $i: salto de score demasiado brusco de $prevScore a $score (delta: $delta)');
        }
      }

      // 7. Auditoría y reporte de uso activo de Pistas Generales
      int casesWithGlobalRules = 0;
      int totalGlobalRulesCount = 0;
      int totalDomainReductionByGlobalRules = 0;

      for (int i = 0; i < allCases.length; i++) {
        final caseData = allCases[i];
        if (caseData.globalRules.isNotEmpty) {
          casesWithGlobalRules++;
          totalGlobalRulesCount += caseData.globalRules.length;
          final sim = replay.simulate(caseData, caseData.clues);
          final gSteps = sim.trace.where((s) => s.sourceType == DeductionSourceType.globalRule);
          for (final s in gSteps) {
            totalDomainReductionByGlobalRules += s.reductionAmount;
          }
        }
      }

      print('═══════════════════════════════════════════════════════════════════════════════');
      print('REPORTE DE AUDITORÍA — PISTAS GENERALES EN CAMPAÑA PROCEDURAL (50 NIVELES)');
      print('═══════════════════════════════════════════════════════════════════════════════');
      print('Total de Casos Evaluados: 50');
      print('Casos con Pistas Generales Activas: $casesWithGlobalRules (${(casesWithGlobalRules / 50 * 100).toStringAsFixed(1)}%)');
      print('Total de Pistas Generales Generadas: $totalGlobalRulesCount');
      print('Reducción Total de Candidatos por Pistas Generales: $totalDomainReductionByGlobalRules');
      print('Promedio de Reducción por Pista General: ${(totalDomainReductionByGlobalRules / (totalGlobalRulesCount > 0 ? totalGlobalRulesCount : 1)).toStringAsFixed(2)} candidatos');
      print('═══════════════════════════════════════════════════════════════════════════════');

      // La tendencia general de los scores debe ser ascendente en promedio
      final firstBlockAvg = scores.take(10).reduce((a, b) => a + b) / 10;
      final lastBlockAvg = scores.skip(40).take(10).reduce((a, b) => a + b) / 10;
      expect(lastBlockAvg, greaterThan(firstBlockAvg), reason: 'El último bloque debe tener mayor dificultad promedio que el primero');
    });
  });
}
