import 'package:flame/game.dart';
import 'package:nexus_mortis/game/board/components/board_component.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

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
  NexusGame(this.caseData) : boardController = BoardController.fromCase(caseData);

  final CaseData caseData;
  final BoardController boardController;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(BoardComponent(
      controller: boardController,
      boardSize: size,
    ));
  }
}
