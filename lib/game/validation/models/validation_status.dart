/// Representa el estado global del progreso del jugador respecto al puzzle.
enum ValidationStatus {
  /// El caso ha sido resuelto al 100%. Todas las pistas se cumplen y las
  /// posiciones coinciden con la solución oculta.
  solved,

  /// Todos los sospechosos han sido ubicados, pero hay pistas no satisfechas
  /// o la posición no coincide con la solución.
  invalid,

  /// El jugador aún está experimentando. Faltan sospechosos por ubicar,
  /// pero ya hay pistas que pueden evaluarse (satisfactorias o insatisfactorias).
  partial,

  /// Prácticamente no existe información suficiente para evaluar pistas.
  incomplete,
}
