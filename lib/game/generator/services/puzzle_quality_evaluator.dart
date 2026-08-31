import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';

/// Evaluador multidimensional de calidad y solvabilidad deductiva humana para puzzles de Nexus Mortis.
class PuzzleQualityEvaluator {
  const PuzzleQualityEvaluator([this._simulator = const PuzzleSimulator()]);
  final PuzzleSimulator _simulator;

  /// Retorna un puntaje de calidad (0 a 100).
  /// Si el puzzle no puede ser resuelto humanamente con determinación exacta (candidateCount == 1),
  /// o si depende de adivinación / branching, el puntaje es 0 (Rechazo absoluto).
  int evaluate(CaseData caseData, List<SpatialClueData> clues) {
    final result = _simulator.simulate(caseData, clues);

    // Criterio de rechazo estricto: cero grados de libertad para todos los personajes y la víctima
    if (!result.solved ||
        result.stuck ||
        result.requiresGuessing ||
        !result.killerDeductionUnique ||
        result.victimCandidateCells != 1 ||
        result.victimCandidateRooms != 1 ||
        result.domainSizes.values.any((v) => v != 1)) {
      return 0; // Puzzle inválido para el jugador humano
    }

    // Máximo 1 regla global permitida por caso
    if (caseData.globalRules.length > 1) {
      return 0;
    }

    // Si hay regla global, verificar que fuera estrictamente necesaria (no redundante)
    if (caseData.globalRules.isNotEmpty) {
      final baseSim = _simulator.simulate(caseData.copyWith(globalRules: const []), clues);
      if (baseSim.victimCandidateCells == 1 && baseSim.victimCandidateRooms == 1) {
        return 0; // Regla redundante e innecesaria (Rechazo absoluto)
      }
    }

    int score = 100;

    // 1. Formato canónico: Exactamente 1 tarjeta por sospechoso + 1 tarjeta de víctima
    final expectedCards = caseData.suspects.length;
    if (clues.length != expectedCards) {
      score -= (clues.length - expectedCards).abs() * 15;
    }

    // 2. Protocolo de víctima: Debe resolverse por descarte Murdoku
    if (result.victimSolvedByExhaustion) {
      score += 5;
    }

    // 3. Profundidad de la cadena deductiva (pasos lógicos)
    final targetSteps = _getTargetSteps(caseData.difficulty);
    if (result.steps > targetSteps + 4) {
      score -= (result.steps - targetSteps) * 4;
    } else if (result.steps < targetSteps - 1) {
      score -= (targetSteps - result.steps) * 4;
    }

    return score.clamp(1, 100).toInt();
  }

  /// Determina si el caso cumple los estándares de calidad para ser entregado al jugador.
  bool isAcceptable(CaseData caseData, List<SpatialClueData> clues) {
    final result = _simulator.simulate(caseData, clues);
    if (!result.solved ||
        result.stuck ||
        result.requiresGuessing ||
        !result.killerDeductionUnique ||
        result.domainSizes.values.any((v) => v != 1)) {
      return false;
    }

    final score = evaluate(caseData, clues);
    final threshold = _getThreshold(caseData.difficulty);
    return score >= threshold;
  }

  int _getTargetSteps(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 3;
      case PuzzleDifficulty.medium:
        return 5;
      case PuzzleDifficulty.hard:
        return 7;
    }
  }

  int _getThreshold(PuzzleDifficulty difficulty) {
    switch (difficulty) {
      case PuzzleDifficulty.easy:
        return 50;
      case PuzzleDifficulty.medium:
        return 60;
      case PuzzleDifficulty.hard:
        return 70;
    }
  }
}
