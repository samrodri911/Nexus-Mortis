/// Estados de validación del tablero y del caso.
enum ValidationStatus {
  /// El tablero aún tiene celdas sin asignar ni descartar con X.
  incomplete,

  /// El tablero tiene progreso parcial pero aún no está completo.
  partial,

  /// El tablero completo contiene contradicciones lógicas con las pistas o posiciones incorrectas.
  invalid,

  /// El tablero está 100% resuelto y verificado; listo para la fase de acusación del asesino.
  readyForKiller,

  /// El caso fue completado con éxito (tablero resuelto + asesino correcto).
  solved,
}
