/// Tipo de regla o condición global del escenario.
enum BoardRuleType {
  /// Cada habitación ocupada contiene exactamente a 1 persona, salvo la escena del crimen (que contiene 2).
  maxOnePersonPerRoomExceptCrime,

  /// Ninguna habitación está vacía (todas contienen al menos 1 persona).
  noEmptyRooms,

  /// Una zona específica albergaba a una única persona (un inocente).
  singleOccupantZone,

  /// La escena del crimen ocurrió en una habitación provista de mobiliario.
  crimeSceneHasObject,

  /// La escena del crimen era una estancia despejada, completamente desprovista de muebles.
  crimeSceneHasNoObject,
}

/// Representa una meta-regla o condición general del escenario que acota el tablero.
class BoardRuleData {
  const BoardRuleData({
    required this.id,
    required this.type,
    required this.text,
    this.targetId,
    this.parameter,
  });

  final String id;
  final BoardRuleType type;
  final String text;
  final String? targetId;
  final int? parameter;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      if (targetId != null) 'targetId': targetId,
      if (parameter != null) 'parameter': parameter,
    };
  }

  factory BoardRuleData.fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String;
    final type = BoardRuleType.values.firstWhere(
      (e) => e.name == typeName || (typeName == 'maxOneSuspectPerRoomExceptCrime' && e == BoardRuleType.maxOnePersonPerRoomExceptCrime),
      orElse: () => BoardRuleType.maxOnePersonPerRoomExceptCrime,
    );
    return BoardRuleData(
      id: json['id'] as String,
      type: type,
      text: json['text'] as String,
      targetId: json['targetId'] as String?,
      parameter: json['parameter'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BoardRuleData &&
        other.id == id &&
        other.type == type &&
        other.text == text &&
        other.targetId == targetId &&
        other.parameter == parameter;
  }

  @override
  int get hashCode => Object.hash(id, type, text, targetId, parameter);
}
