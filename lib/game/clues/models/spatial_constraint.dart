import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';

/// Representa una restricción espacial atómica dentro de una tarjeta de pista.
class SpatialConstraint {
  const SpatialConstraint({
    required this.relation,
    required this.targetId,
    this.type = ClueType.cardinal,
  });

  /// Tipo de relación lógica.
  final SpatialRelation relation;

  /// ID de la entidad objetivo (otro sospechoso, objeto o zona).
  final String targetId;

  /// Categoría deductiva de la restricción.
  final ClueType type;

  Map<String, dynamic> toJson() => {
        'relation': relation.name,
        'targetId': targetId,
        'type': type.name,
      };

  factory SpatialConstraint.fromJson(Map<String, dynamic> json) {
    final relName = json['relation'] as String;
    final relation = SpatialRelation.values.firstWhere(
      (e) => e.name == relName,
      orElse: () => SpatialRelation.adjacentTo,
    );

    final typeName = json['type'] as String?;
    final type = typeName != null
        ? ClueType.values.firstWhere(
            (e) => e.name == typeName,
            orElse: () => _inferTypeFromRelation(relation),
          )
        : _inferTypeFromRelation(relation);

    return SpatialConstraint(
      relation: relation,
      targetId: json['targetId'] as String,
      type: type,
    );
  }

  static ClueType _inferTypeFromRelation(SpatialRelation rel) {
    switch (rel) {
      case SpatialRelation.adjacentTo:
      case SpatialRelation.notAdjacentTo:
        return ClueType.adjacency;
      case SpatialRelation.leftOf:
      case SpatialRelation.rightOf:
      case SpatialRelation.above:
      case SpatialRelation.below:
      case SpatialRelation.immediatelyNorthOf:
      case SpatialRelation.immediatelySouthOf:
      case SpatialRelation.immediatelyEastOf:
      case SpatialRelation.immediatelyWestOf:
        return ClueType.cardinal;
      case SpatialRelation.inZone:
      case SpatialRelation.notInZone:
        return ClueType.zone;
      case SpatialRelation.sameRow:
      case SpatialRelation.sameColumn:
      case SpatialRelation.differentRow:
      case SpatialRelation.differentColumn:
        return ClueType.coLocation;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpatialConstraint &&
          runtimeType == other.runtimeType &&
          relation == other.relation &&
          targetId == other.targetId &&
          type == other.type;

  @override
  int get hashCode => relation.hashCode ^ targetId.hashCode ^ type.hashCode;
}
