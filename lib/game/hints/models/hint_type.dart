/// Representa los niveles de ayuda disponibles en el juego.
enum HintType {
  /// Pista suave: sugerencia genérica sobre qué observar.
  soft,

  /// Pista media: evaluación del estado actual revelando inconsistencias.
  medium,

  /// Pista fuerte: revelación directa de un dato o relación no descubierta.
  reveal,
}
