/// Razones exhaustivas por las cuales un [CaseData] puede ser rechazado
/// durante la autorrevisión pre-entrega.
enum CaseRejectionReason {
  /// Dimensiones inválidas del tablero o título vacío.
  invalidDimensions,

  /// Lista de sospechosos insuficiente, excedida para Murdoku o sin víctima/asesino válidos.
  invalidSuspects,

  /// Configuración de zonas inválida (celdas no contiguas, fuera de límites, etc.).
  invalidZoneLayout,

  /// Una restricción o regla referencia una zona que no existe en el layout.
  invalidZoneReference,

  /// El texto visible de una pista menciona un nombre de zona que no existe en el layout.
  invalidZoneNameInClue,

  /// Una restricción referencia un objeto que no existe en el tablero.
  invalidObjectReference,

  /// El texto visible de una pista menciona un nombre de objeto que no existe en el tablero.
  invalidObjectNameInClue,

  /// Un objeto físico está posicionado fuera de los límites del tablero.
  objectOutOfBounds,

  /// Hay objetos físicos superpuestos en la misma celda.
  overlappingObjects,

  /// La víctima está sola en una zona o el asesino está en otra zona distinta.
  victimWithoutKiller,

  /// La escena del crimen contiene a una tercera persona (debe ser exactamente víctima + asesino).
  crimeSceneThirdOccupant,

  /// Un sospechoso inocente está ubicado en la escena del crimen.
  innocentInCrimeScene,

  /// Uno o más sospechosos quedan con más de 1 casilla candidata tras la deducción humana.
  suspectAmbiguous,

  /// La víctima queda con más de 1 celda o más de 1 habitación candidata tras la deducción.
  victimAmbiguous,

  /// La tarjeta de la víctima fue alterada o contiene pistas/restricciones espaciales no canónicas.
  victimCardInvalid,

  /// El solver matemático encuentra 0 o más de 1 solución global única.
  nonUniqueSolution,

  /// La deducción humana requiere adivinar, branching o prueba de hipótesis.
  requiresGuessing,

  /// La deducción final del asesino no coincide con el killerId del caso.
  killerDeductionFailed,

  /// La regla global no era necesaria (el caso ya se resolvía unívocamente sin ella).
  globalRuleRedundant,

  /// Hay más de 1 regla global asignada al caso.
  globalRuleTooMany,

  /// La regla global referencia una zona inválida o inexistente.
  globalRuleInvalidTarget,

  /// La dificultad calculada está fuera del rango objetivo para el nivel.
  difficultyOutOfRange,
}
