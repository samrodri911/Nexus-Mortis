/// Tipos declarativos de condiciones para evaluar logros.
enum AchievementConditionType {
  /// Requiere haber resuelto un número mínimo de puzzles totales.
  puzzlesSolved,

  /// Requiere haber acumulado una cantidad mínima de estrellas totales.
  starsEarned,

  /// Requiere resolver un caso obteniendo 3 estrellas.
  threeStarsCase,

  /// Requiere resolver un caso sin usar pistas.
  noHintsUsed,

  /// Requiere completar todos los casos que componen la campaña estática.
  campaignComplete,

  /// Requiere haber resuelto un número mínimo de casos procedimentales.
  proceduralSolved,
}
