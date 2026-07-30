import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';

/// Define las operaciones de persistencia de la partida en curso (Auto-Save).
abstract class ActiveGameRepository {
  /// Guarda el estado de la partida activa actual.
  Future<void> saveGame(ActiveGameState state);

  /// Carga el estado de la partida activa, si existe.
  Future<ActiveGameState?> loadGame();

  /// Elimina la partida activa guardada (se llama al ganar o al abandonar).
  Future<void> clearGame();
}
