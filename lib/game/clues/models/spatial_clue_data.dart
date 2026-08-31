import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';

/// Modelo de datos para una tarjeta de pista lógica en Nexus Mortis (1 Personaje = 1 Tarjeta).
///
/// La tarjeta agrupa una o más restricciones espaciales compuestas ([constraints])
/// que deben cumplirse simultáneamente para el sujeto ([suspectId]).
/// El campo [text] contiene la redacción en lenguaje natural para el panel de investigación.
class SpatialClueData {
  const SpatialClueData({
    required this.id,
    required this.text,
    required this.suspectId,
    this.relation = SpatialRelation.adjacentTo,
    this.targetId = '',
    this.type = ClueType.cardinal,
    this.constraints = const [],
  });

  /// Identificador único de la tarjeta de pista.
  final String id;

  /// Texto descriptivo en español para el panel del investigador.
  final String text;

  /// ID del sospechoso principal de la tarjeta (o víctima).
  final String suspectId;

  /// Relación principal (para tarjetas de 1 restricción o retrocompatibilidad).
  final SpatialRelation relation;

  /// ID de la entidad objetivo (otro sospechoso, objeto o zona).
  final String targetId;

  /// Categoría deductiva principal.
  final ClueType type;

  /// Lista de restricciones compuestas asociadas a esta tarjeta.
  final List<SpatialConstraint> constraints;

  /// Retorna la lista efectiva de restricciones que deben cumplirse para este sospechoso.
  List<SpatialConstraint> get activeConstraints {
    if (constraints.isNotEmpty) {
      return constraints;
    }
    if (targetId.isNotEmpty) {
      return [SpatialConstraint(relation: relation, targetId: targetId, type: type)];
    }
    return const [];
  }

  /// Indica si esta tarjeta corresponde al protocolo canónico de la víctima.
  bool get isVictimCard => suspectId == 'victim' || (constraints.isEmpty && targetId.isEmpty);

  SpatialClueData copyWith({
    String? id,
    String? text,
    String? suspectId,
    SpatialRelation? relation,
    String? targetId,
    ClueType? type,
    List<SpatialConstraint>? constraints,
  }) {
    return SpatialClueData(
      id: id ?? this.id,
      text: text ?? this.text,
      suspectId: suspectId ?? this.suspectId,
      relation: relation ?? this.relation,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      constraints: constraints ?? this.constraints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'suspectId': suspectId,
      'relation': relation.name,
      'targetId': targetId,
      'type': type.name,
      if (constraints.isNotEmpty)
        'constraints': constraints.map((c) => c.toJson()).toList(),
    };
  }

  factory SpatialClueData.fromJson(Map<String, dynamic> json) {
    final relName = json['relation'] as String?;
    final relation = relName != null
        ? SpatialRelation.values.firstWhere(
            (e) => e.name == relName,
            orElse: () => SpatialRelation.adjacentTo,
          )
        : SpatialRelation.adjacentTo;

    final typeName = json['type'] as String?;
    final type = typeName != null
        ? ClueType.values.firstWhere(
            (e) => e.name == typeName,
            orElse: () => _inferTypeFromRelation(relation),
          )
        : _inferTypeFromRelation(relation);

    final rawConstraints = json['constraints'] as List<dynamic>?;
    final parsedConstraints = rawConstraints != null
        ? rawConstraints
            .map((c) => SpatialConstraint.fromJson(c as Map<String, dynamic>))
            .toList()
        : const <SpatialConstraint>[];

    return SpatialClueData(
      id: json['id'] as String,
      text: json['text'] as String? ?? '',
      suspectId: json['suspectId'] as String,
      relation: relation,
      targetId: json['targetId'] as String? ?? '',
      type: type,
      constraints: parsedConstraints,
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
      other is SpatialClueData &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          suspectId == other.suspectId &&
          relation == other.relation &&
          targetId == other.targetId &&
          type == other.type;

  @override
  int get hashCode =>
      id.hashCode ^
      text.hashCode ^
      suspectId.hashCode ^
      relation.hashCode ^
      targetId.hashCode ^
      type.hashCode;
}
