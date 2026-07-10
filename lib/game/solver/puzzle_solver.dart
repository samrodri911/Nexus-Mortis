import 'package:nexus_mortis/game/clues/evaluators/clue_evaluation_result.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/solver/heuristics/variable_ordering.dart';
import 'package:nexus_mortis/game/solver/models/assignment_state.dart';
import 'package:nexus_mortis/game/solver/models/solver_result.dart';

/// Motor de resolución CSP (Constraint Satisfaction Problem) para Nexus Mortis.
///
/// Implementa Backtracking con:
/// - MRV (Minimum Remaining Values) via [VariableOrdering].
/// - Forward Checking: propaga restricciones de colisión tras cada asignación.
/// - Poda temprana: abandona ramas donde una pista ya está `unsatisfied`.
/// - Detección de unicidad: detiene la búsqueda al alcanzar [maxSolutions].
///
/// Es completamente agnóstico de la UI, BoardController y PlayerBoardState.
/// Solo opera sobre [CaseData], [SpatialClueData] y [ClueEvaluator].
class PuzzleSolver {
  PuzzleSolver({
    ClueEvaluator? clueEvaluator,
    VariableOrdering? ordering,
  })  : _clueEvaluator =
            clueEvaluator ?? const ClueEvaluator(SpatialClueEvaluator()),
        _ordering = ordering ?? const VariableOrdering();

  final ClueEvaluator _clueEvaluator;
  final VariableOrdering _ordering;

  /// Resuelve el puzzle descrito en [caseData].
  ///
  /// [maxSolutions] controla cuántas soluciones buscar antes de detenerse.
  /// Usar `maxSolutions: 2` permite detectar unicidad sin recorrer el árbol
  /// completo:
  /// - 0 soluciones → puzzle imposible.
  /// - 1 solución  → puzzle válido y único.
  /// - 2 soluciones → puzzle ambiguo.
  SolverResult solve(CaseData caseData, {int maxSolutions = 2}) {
    // ── Preparación del entorno ──────────────────────────────────────────────

    final suspectIds = caseData.suspects.map((s) => s.id).toList();
    final clues = caseData.clues;

    // Mapa de posiciones fijas de objetos para la evaluación de pistas.
    final objectPositions = <String, CellPosition>{};
    for (final obj in caseData.placedObjects) {
      objectPositions[obj.object.id] = obj.position;
    }

    // Conjunto de celdas ocupadas por objetos físicos (no disponibles).
    final blockedCells = objectPositions.values.toSet();

    // ── Dominio inicial ──────────────────────────────────────────────────────
    // Generar todas las celdas libres del tablero.
    final allFreeCells = <CellPosition>[];
    for (int r = 0; r < caseData.boardRows; r++) {
      for (int c = 0; c < caseData.boardColumns; c++) {
        final pos = CellPosition(r, c);
        if (!blockedCells.contains(pos)) {
          allFreeCells.add(pos);
        }
      }
    }

    // Todos los sospechosos parten con el mismo dominio inicial.
    final initialDomains = <String, List<CellPosition>>{
      for (final id in suspectIds) id: List.of(allFreeCells),
    };

    // ── Búsqueda ─────────────────────────────────────────────────────────────
    final solutions = <SolutionData>[];
    var visitedNodes = 0;

    _backtrack(
      state: const AssignmentState({}),
      unassigned: suspectIds,
      domains: initialDomains,
      clues: clues,
      objectPositions: objectPositions,
      solutions: solutions,
      visitedNodes: (count) => visitedNodes = count,
      visitedNodesMutable: _MutableInt(0),
      maxSolutions: maxSolutions,
    );

    // Recuperar el conteo real de nodos visitados desde el objeto mutable.
    // (El closure no puede capturar un int directamente en Dart.)

    return SolverResult(
      solutionCount: solutions.length,
      solutions: solutions,
      visitedNodes: visitedNodes,
    );
  }

  // ── Backtracking recursivo ────────────────────────────────────────────────

  /// Retorna true si se debe detener la búsqueda (se alcanzó [maxSolutions]).
  bool _backtrack({
    required AssignmentState state,
    required List<String> unassigned,
    required Map<String, List<CellPosition>> domains,
    required List<SpatialClueData> clues,
    required Map<String, CellPosition> objectPositions,
    required List<SolutionData> solutions,
    required void Function(int) visitedNodes,
    required _MutableInt visitedNodesMutable,
    required int maxSolutions,
  }) {
    visitedNodesMutable.value++;
    visitedNodes(visitedNodesMutable.value);

    // ── Caso base: todos los sospechosos han sido asignados ──────────────────
    if (unassigned.isEmpty) {
      // Verificar que todas las pistas sean satisfechas (validación final).
      if (_allCluesSatisfied(state.assignments, clues, objectPositions)) {
        solutions.add(SolutionData(suspectPositions: Map.of(state.assignments)));
      }
      return solutions.length >= maxSolutions;
    }

    // ── MRV: elegir el sospechoso con el dominio más pequeño ─────────────────
    final suspectId = _ordering.pickNext(unassigned, domains);
    final remainingUnassigned =
        unassigned.where((id) => id != suspectId).toList();
    final domain = domains[suspectId] ?? [];

    // ── Probar cada posición del dominio ──────────────────────────────────────
    for (final position in domain) {
      // Forward Checking: la posición no puede estar ya ocupada.
      if (state.occupiedPositions.contains(position)) continue;

      // Extender la asignación.
      final newState = state.extend(suspectId, position);

      // ── Poda Temprana: verificar pistas afectadas inmediatamente ──────────
      if (_hasUnsatisfiedClue(newState.assignments, clues, objectPositions)) {
        continue; // Esta rama muere aquí.
      }

      // ── Forward Checking: actualizar dominios de los no asignados ─────────
      final prunedDomains = _forwardCheck(
        remainingUnassigned,
        domains,
        position, // La posición recién asignada debe excluirse.
      );

      // Si algún sospechoso queda sin posiciones posibles, poda inmediata.
      if (prunedDomains == null) continue;

      // ── Recursar ──────────────────────────────────────────────────────────
      final shouldStop = _backtrack(
        state: newState,
        unassigned: remainingUnassigned,
        domains: prunedDomains,
        clues: clues,
        objectPositions: objectPositions,
        solutions: solutions,
        visitedNodes: visitedNodes,
        visitedNodesMutable: visitedNodesMutable,
        maxSolutions: maxSolutions,
      );

      if (shouldStop) return true;
    }

    return false;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Retorna true si existe alguna pista explícitamente `unsatisfied`
  /// dado el estado de asignación actual.
  ///
  /// Las pistas `unknown` (sospechosos aún no asignados) se ignoran.
  bool _hasUnsatisfiedClue(
    Map<String, CellPosition> assignments,
    List<SpatialClueData> clues,
    Map<String, CellPosition> objectPositions,
  ) {
    for (final clue in clues) {
      final result = _clueEvaluator.evaluate(clue, assignments, objectPositions);
      if (result == ClueEvaluationResult.unsatisfied) return true;
    }
    return false;
  }

  /// Retorna true si todas las pistas están `satisfied`.
  bool _allCluesSatisfied(
    Map<String, CellPosition> assignments,
    List<SpatialClueData> clues,
    Map<String, CellPosition> objectPositions,
  ) {
    for (final clue in clues) {
      final result = _clueEvaluator.evaluate(clue, assignments, objectPositions);
      if (result != ClueEvaluationResult.satisfied) return false;
    }
    return true;
  }

  /// Forward Checking: elimina [occupiedPosition] de todos los dominios
  /// de sospechosos aún sin asignar.
  ///
  /// Retorna null si algún sospechoso queda con dominio vacío (poda).
  /// Retorna los nuevos dominios si todos siguen viables.
  Map<String, List<CellPosition>>? _forwardCheck(
    List<String> unassigned,
    Map<String, List<CellPosition>> currentDomains,
    CellPosition occupiedPosition,
  ) {
    final pruned = <String, List<CellPosition>>{};

    for (final id in unassigned) {
      final domain = currentDomains[id] ?? [];
      final filtered =
          domain.where((pos) => pos != occupiedPosition).toList();

      if (filtered.isEmpty) return null; // Poda: dominio vacío.

      pruned[id] = filtered;
    }

    return pruned;
  }
}

/// Entero mutable para poder capturar el contador de nodos en el closure.
class _MutableInt {
  _MutableInt(this.value);
  int value;
}
