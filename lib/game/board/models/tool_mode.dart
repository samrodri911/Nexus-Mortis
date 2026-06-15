/// Representa la herramienta activa que está usando el investigador
/// para realizar anotaciones en el tablero.
enum ToolMode {
  /// Modo Posible: Marca a un sospechoso como posible candidato en una celda.
  /// Requiere tener un sospechoso seleccionado.
  candidate,
  
  /// Modo Descartado: Aplica una marca global 'X' a la celda,
  /// indicando que nadie puede ocupar esa posición.
  /// No requiere un sospechoso seleccionado.
  eliminated,
}
