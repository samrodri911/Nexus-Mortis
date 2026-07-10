/// Niveles de dificultad objetivos para un puzzle de Nexus Mortis.
///
/// Determinados automáticamente por [DifficultyAnalyzer] en función
/// de métricas del motor de resolución (visitedNodes, clueCount, etc.).
enum DifficultyLevel {
  trivial,
  easy,
  medium,
  hard,
  expert,
}
