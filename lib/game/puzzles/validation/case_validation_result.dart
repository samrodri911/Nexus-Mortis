import 'package:nexus_mortis/game/puzzles/validation/case_rejection_reason.dart';

/// Resultado detallado de la validación estricta de un [CaseData].
class CaseValidationResult {
  const CaseValidationResult({
    required this.isValid,
    this.rejectionReason,
    this.details,
  });

  /// Caso 100% válido y aprobado para gameplay.
  factory CaseValidationResult.valid() {
    return const CaseValidationResult(isValid: true);
  }

  /// Caso rechazado con motivo formal y descripción diagnóstica.
  factory CaseValidationResult.rejected(
    CaseRejectionReason reason, {
    String? details,
  }) {
    return CaseValidationResult(
      isValid: false,
      rejectionReason: reason,
      details: details,
    );
  }

  /// Indica si el caso cumple todos los invariantes de integridad y calidad.
  final bool isValid;

  /// Motivo específico del rechazo si [isValid] es falso.
  final CaseRejectionReason? rejectionReason;

  /// Detalles diagnósticos opcionales para debugging y reportes.
  final String? details;

  @override
  String toString() {
    if (isValid) return 'CaseValidationResult(VALID)';
    return 'CaseValidationResult(REJECTED: ${rejectionReason?.name}, details: $details)';
  }
}
