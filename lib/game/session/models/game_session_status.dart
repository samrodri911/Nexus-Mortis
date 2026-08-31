/// Estados del ciclo de vida de una sesión de juego.
enum GameSessionStatus {
  /// La sesión aún no ha iniciado.
  notStarted,

  /// La partida está activa e interactuable en el tablero.
  playing,

  /// La partida se encuentra pausada (por ejemplo, app en background).
  paused,

  /// El tablero ha sido resuelto con éxito y se espera la acusación del asesino.
  awaitingKiller,

  /// El caso ha sido completado y validado con éxito tras acertar al asesino.
  solved,

  /// La partida fue descartada/abandonada por el jugador.
  abandoned,
}
