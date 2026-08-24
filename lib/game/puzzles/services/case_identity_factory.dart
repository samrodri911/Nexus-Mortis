/// Fábrica dedicada exclusivamente a la generación de identificadores únicos
/// para los casos, manteniendo el Single Responsibility Principle (SRP).
class CaseIdentityFactory {
  const CaseIdentityFactory();

  /// Crea un ID determinista o semántico para un caso procedimental.
  String createProceduralId(int seed) {
    // Formato amigable que no tiene peso semántico para la lógica de regeneración.
    return 'procedural_$seed';
  }
}
