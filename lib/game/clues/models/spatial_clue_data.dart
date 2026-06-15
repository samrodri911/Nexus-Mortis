import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';

/// Modelo de datos para una pista espacial.
/// 
/// Por ahora, solo se utiliza para visualización en la UI.
/// En futuras iteraciones servirá como base para el motor de deducción.
class SpatialClueData {
  const SpatialClueData({
    required this.id,
    required this.text,
    required this.relation,
    required this.suspectId,
    required this.targetId,
  });

  /// Identificador único de la pista.
  final String id;

  /// Texto descriptivo a mostrar en el panel del investigador.
  final String text;

  /// Tipo de relación espacial.
  final SpatialRelation relation;

  /// ID del sospechoso principal de la pista (ej. Juan).
  final String suspectId;

  /// ID de la entidad objetivo (ej. otra persona u objeto fijo).
  final String targetId;
}
