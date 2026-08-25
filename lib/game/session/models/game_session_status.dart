/// Estados del ciclo de vida de una sesión de juego.
enum GameSessionStatus {
  /// La sesión aún no ha iniciado.
  notStarted,

  /// La partida está activa e interactuable.
  playing,

  /// La partida se encuentra pausada (por ejemplo, app en background).
  paused,

  /// El caso ha sido resuelto y validado con éxito.
  solved,

  /// La partida fue descartada/abandonada por el jugador.
  abandoned,
}
