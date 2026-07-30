import 'package:nexus_mortis/data/repositories/active_game_repository.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';

/// Orquesta la persistencia de la partida en curso.
class SaveGameService {
  SaveGameService(this._repository);

  final ActiveGameRepository _repository;

  /// Exporta el estado lógico actual del tablero y lo guarda en disco.
  Future<void> saveCurrentGame(String caseId, BoardController controller) async {
    final state = controller.exportGameState(caseId);
    await _repository.saveGame(state);
  }

  /// Carga la partida guardada (si existe).
  Future<ActiveGameState?> loadGame() async {
    return await _repository.loadGame();
  }

  /// Limpia la partida activa (se invoca al ganar o al abandonar el caso).
  Future<void> clearGame() async {
    await _repository.clearGame();
  }
}
