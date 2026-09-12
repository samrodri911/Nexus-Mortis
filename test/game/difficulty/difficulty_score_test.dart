import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/in_memory_campaign_case_repository.dart';
import 'package:nexus_mortis/game/difficulty/difficulty_analyzer.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/puzzles/services/case_campaign_service.dart';
import 'package:nexus_mortis/game/puzzles/validation/human_deduction_replay.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  group('Progressive Difficulty & Block Sizing System', () {
    test('Generación de lote procedural produce casos con score creciente suave', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: repo);

      await campaignService.ensureBatchAvailable(PlayerProgress.empty());
      final allCases = await campaignService.getAvailableCases();

      expect(allCases.length, 10);

      final analyzer = DifficultyAnalyzer(PuzzleSolver());
      const replay = HumanDeductionReplay();
      final scores = allCases.map((c) {
        final sim = replay.simulate(c, c.clues);
        return analyzer.calculateScore(c, simResult: sim);
      }).toList();

      // Verificar que todos los scores están en el rango válido 10..100
      for (int i = 0; i < scores.length; i++) {
        expect(scores[i], inInclusiveRange(10, 100), reason: 'Caso procedural $i tiene score fuera de rango: ${scores[i]}');
      }

      // Verificar que entre niveles procedurales consecutivos no existen saltos extremos
      for (int i = 0; i < scores.length - 1; i++) {
        final step = (scores[i + 1] - scores[i]).abs();
        expect(step, lessThanOrEqualTo(10), reason: 'Salto brusco de dificultad entre caso procedural $i (${scores[i]}) y caso ${i + 1} (${scores[i + 1]})');
      }
    });

    test('Sizing de cuadrícula respeta la política de bloques de ~10 niveles', () async {
      final repo = InMemoryCampaignCaseRepository();
      final campaignService = CaseCampaignService(campaignCaseRepository: repo);

      await campaignService.ensureBatchAvailable(PlayerProgress.empty());
      final cases = await campaignService.getAvailableCases();

      // Niveles 0..9 (índices 0..9) deben ser 4x4 con 3 sospechosos
      for (int i = 0; i < 10; i++) {
        final c = cases[i];
        expect(c.boardRows, equals(4), reason: 'Caso ${i + 1} debe ser 4x4');
        expect(c.boardColumns, equals(4), reason: 'Caso ${i + 1} debe ser 4x4');
        expect(c.suspects.length, equals(3), reason: 'Caso ${i + 1} debe tener 3 sospechosos');
      }
    });
  });
}
