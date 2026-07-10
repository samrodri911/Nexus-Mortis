/// Representa el estado de una pista espacial tras ser evaluada.
enum ClueEvaluationResult {
  /// La pista se cumple dadas las posiciones actuales.
  satisfied,

  /// La pista no se cumple dadas las posiciones actuales.
  unsatisfied,

  /// La pista no puede evaluarse porque falta información
  /// (el sospechoso o el objetivo aún no tienen una posición única fijada).
  unknown,
}
