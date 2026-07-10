import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Contenedor inmutable que representa el resultado de una validación.
/// 
/// El progreso del jugador se mide por las pistas, no por la solución oculta,
/// para evitar filtrar respuestas (ej. no revelar cuántos sospechosos están correctos).
class ValidationResult {
  const ValidationResult({
    required this.status,
    required this.totalClues,
    required this.satisfiedClues,
    required this.unsatisfiedClues,
    required this.unknownClues,
  });

  /// Estado lógico general del puzzle.
  final ValidationStatus status;

  /// Cantidad total de pistas en el caso.
  final int totalClues;

  /// Pistas que se cumplen actualmente.
  final int satisfiedClues;

  /// Pistas que no se cumplen actualmente.
  final int unsatisfiedClues;

  /// Pistas que no pueden ser evaluadas porque faltan candidatos únicos.
  final int unknownClues;

  /// Porcentaje de progreso basado en las pistas satisfechas (0.0 a 1.0).
  double get clueProgressPercentage {
    if (totalClues == 0) return 0.0;
    return satisfiedClues / totalClues;
  }

  @override
  String toString() {
    return 'ValidationResult(status: ${status.name}, clues: $satisfiedClues/$totalClues, '
           'unsatisfied: $unsatisfiedClues, unknown: $unknownClues)';
  }
}
