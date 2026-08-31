import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_constraint.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';

/// Formatea tarjetas de pistas en lenguaje natural en español pulido, canónico y temático.
class ClueTextFormatter {
  const ClueTextFormatter();

  /// Texto canónico oficial para la tarjeta de la víctima.
  static const String canonicalVictimText = 'La víctima. Estaba a solas con el asesino.';

  /// Genera la redacción en español para una tarjeta de pista estructurada.
  String format({
    required SpatialClueData clue,
    required Map<String, String> suspectNames,
    required Map<String, String> objectNames,
    required Map<String, String> zoneNames,
    required String victimId,
  }) {
    // Protocolo Canónico de la Víctima
    if (clue.suspectId == victimId || clue.suspectId == 'victim' || clue.isVictimCard) {
      return canonicalVictimText;
    }

    final subject = _resolveSubjectName(clue.suspectId, suspectNames, victimId);
    final constraints = clue.activeConstraints;

    if (constraints.isEmpty) {
      return '$subject estuvo en la escena.';
    }

    if (constraints.length == 1) {
      return _formatSingleConstraint(subject, constraints.first, suspectNames, objectNames, zoneNames, victimId);
    }

    if (constraints.length == 2) {
      return _formatDualConstraints(subject, constraints[0], constraints[1], suspectNames, objectNames, zoneNames, victimId);
    }

    // Para 3 o más restricciones
    final parts = constraints.map((c) => _constraintPhrase(c, suspectNames, objectNames, zoneNames, victimId)).toList();
    return '$subject ${parts.join(', y ')}.';
  }

  String _formatSingleConstraint(
    String subject,
    SpatialConstraint c,
    Map<String, String> suspectNames,
    Map<String, String> objectNames,
    Map<String, String> zoneNames,
    String victimId,
  ) {
    final phrase = _constraintPhrase(c, suspectNames, objectNames, zoneNames, victimId);
    return '$subject $phrase.';
  }

  String _formatDualConstraints(
    String subject,
    SpatialConstraint c1,
    SpatialConstraint c2,
    Map<String, String> suspectNames,
    Map<String, String> objectNames,
    Map<String, String> zoneNames,
    String victimId,
  ) {
    // Si una es zona y la otra es adyacencia/cardinal
    if (c1.relation == SpatialRelation.inZone && c2.relation != SpatialRelation.inZone) {
      final zone = _resolveZoneName(c1.targetId, zoneNames);
      final p2 = _constraintPhrase(c2, suspectNames, objectNames, zoneNames, victimId);
      return '$subject se encontraba en $zone, $p2.';
    }
    if (c2.relation == SpatialRelation.inZone && c1.relation != SpatialRelation.inZone) {
      final zone = _resolveZoneName(c2.targetId, zoneNames);
      final p1 = _constraintPhrase(c1, suspectNames, objectNames, zoneNames, victimId);
      return '$subject se encontraba en $zone, $p1.';
    }

    final p1 = _constraintPhrase(c1, suspectNames, objectNames, zoneNames, victimId);
    final p2 = _constraintPhrase(c2, suspectNames, objectNames, zoneNames, victimId);
    return '$subject $p1, y $p2.';
  }

  String _constraintPhrase(
    SpatialConstraint c,
    Map<String, String> suspectNames,
    Map<String, String> objectNames,
    Map<String, String> zoneNames,
    String victimId,
  ) {
    switch (c.relation) {
      case SpatialRelation.inZone:
        final zone = _resolveZoneName(c.targetId, zoneNames);
        return 'se encontraba en $zone';

      case SpatialRelation.notInZone:
        final zone = _resolveZoneName(c.targetId, zoneNames);
        return 'no estaba en $zone';

      case SpatialRelation.adjacentTo:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba junto a $target';

      case SpatialRelation.notAdjacentTo:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'no estaba junto a $target';

      case SpatialRelation.leftOf:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba al oeste de $target';

      case SpatialRelation.rightOf:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba al este de $target';

      case SpatialRelation.above:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba al norte de $target';

      case SpatialRelation.below:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba al sur de $target';

      case SpatialRelation.sameRow:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba en la misma fila que $target';

      case SpatialRelation.sameColumn:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba en la misma columna que $target';

      case SpatialRelation.differentRow:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba en una fila distinta a $target';

      case SpatialRelation.differentColumn:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba en una columna distinta a $target';

      case SpatialRelation.immediatelyNorthOf:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba inmediatamente al norte de $target';

      case SpatialRelation.immediatelySouthOf:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba inmediatamente al sur de $target';

      case SpatialRelation.immediatelyEastOf:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba inmediatamente al este de $target';

      case SpatialRelation.immediatelyWestOf:
        final target = _resolveTargetName(c.targetId, suspectNames, objectNames, victimId);
        return 'estaba inmediatamente al oeste de $target';
    }
  }

  String _resolveSubjectName(
    String id,
    Map<String, String> suspectNames,
    String victimId,
  ) {
    if (id == victimId || id == 'victim') {
      return 'La víctima';
    }
    return suspectNames[id] ?? id;
  }

  String _resolveTargetName(
    String id,
    Map<String, String> suspectNames,
    Map<String, String> objectNames,
    String victimId,
  ) {
    if (id == victimId || id == 'victim') {
      return 'la víctima';
    }
    if (objectNames.containsKey(id)) {
      final name = objectNames[id]!;
      return _withArticle(name);
    }
    if (suspectNames.containsKey(id)) {
      return suspectNames[id]!;
    }
    return id;
  }

  String _resolveZoneName(String zoneId, Map<String, String> zoneNames) {
    final rawName = zoneNames[zoneId] ?? zoneId;
    return _withArticle(rawName);
  }

  static const Set<String> _feminineWords = {
    'fuente', 'estatua', 'cama', 'silla', 'mesa', 'caja', 'lámpara',
    'biblioteca', 'galería', 'bóveda', 'cúpula', 'sala', 'terraza',
    'rosaleda', 'cámara', 'bodega', 'orquídea', 'puerta', 'ventana',
    'mansión', 'oficina', 'habitación',
  };

  String _withArticle(String name) {
    final lower = name.toLowerCase();
    if (lower.startsWith('el ') || lower.startsWith('la ') || lower.startsWith('los ') || lower.startsWith('las ')) {
      return name;
    }
    if (_feminineWords.contains(lower) ||
        lower.endsWith('a') ||
        lower.endsWith('ón') ||
        lower.endsWith('ad') ||
        lower.endsWith('ed')) {
      return 'la $name';
    }
    return 'el $name';
  }
}
