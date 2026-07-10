import 'package:flame/game.dart';
import 'package:nexus_mortis/game/board/components/board_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Motor principal del juego Nexus Mortis.
///
/// Responsable de inicializar el estado del tablero y montar
/// los componentes Flame a partir de un [CaseData].
/// Expone [boardController] para que la capa Flutter pueda
/// interactuar con la lógica del juego.
class NexusGame extends FlameGame {
  /// El juego exige ahora un [CaseData] inmutable como fuente de verdad.
  /// El controlador se crea en el constructor para que esté disponible
  /// inmediatamente, antes de que [onLoad] sea invocado por Flame.
  NexusGame(this.caseData) : boardController = BoardController.fromCase(caseData) {
    // 1. Extraer posiciones fijas de los objetos
    final Map<String, CellPosition> objectPositions = {};
    for (final obj in caseData.placedObjects) {
      objectPositions[obj.object.id] = obj.position;
    }

    // 2. Instanciar servicio inyectando el motor de evaluación
    validationService = ValidationService(
      solution: caseData.solution,
      clues: caseData.clues,
      objectPositions: objectPositions,
      clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()),
    );

    // Escuchar los cambios del tablero y actualizar el estado de validación.
    boardController.version.addListener(_onBoardChanged);
    // Evaluar inicialmente
    _onBoardChanged();
  }

  final CaseData caseData;
  final BoardController boardController;
  late final ValidationService validationService;

  /// Notificador que expone el estado actual de la validación del puzzle.
  /// La UI lo puede escuchar para detectar cuándo el puzzle ha sido resuelto.
  final ValueNotifier<ValidationStatus> puzzleStatus =
      ValueNotifier(ValidationStatus.incomplete);

  void _onBoardChanged() {
    final state = boardController.exportPlayerState();
    final result = validationService.validate(state);
    
    // Solo notificar si cambió, aunque ValueNotifier ya lo hace, es buena práctica.
    if (puzzleStatus.value != result.status) {
      puzzleStatus.value = result.status;
    }
  }

  /// Método de depuración para probar el sistema de validación
  /// sin necesidad de UI conectada.
  void debugValidatePuzzle() {
    final state = boardController.exportPlayerState();
    final result = validationService.validate(state);
    
    // ignore: avoid_print
    print('--- VALIDATION DEBUG ---');
    // ignore: avoid_print
    print(result.toString());
    // ignore: avoid_print
    print('------------------------');
  }

  /// Método de depuración para ejecutar el solver sobre el caso actual
  /// e imprimir el resultado en consola.
  void debugSolveDemoCase() {
    final solver = PuzzleSolver();
    final result = solver.solve(caseData, maxSolutions: 2);

    // ignore: avoid_print
    print('--- SOLVER DEBUG ---');
    // ignore: avoid_print
    print('Solutions: ${result.solutionCount}');
    // ignore: avoid_print
    print('Visited nodes: ${result.visitedNodes}');
    for (final solution in result.solutions) {
      solution.suspectPositions.forEach((id, pos) {
        // ignore: avoid_print
        print('  $id -> $pos');
      });
    }
    // ignore: avoid_print
    print('--------------------');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(BoardComponent(
      controller: boardController,
      boardSize: size,
    ));
  }
}
