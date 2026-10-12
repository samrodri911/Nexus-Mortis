import 'dart:math';

import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';
import 'package:nexus_mortis/game/visual/models/room_archetype.dart';
import 'package:nexus_mortis/game/visual/models/visual_map_plan.dart';
import 'package:nexus_mortis/game/visual/services/room_archetype_resolver.dart';

/// Construye el plan visual procedural completo para un caso/mapa.
///
/// El plan se genera UNA SOLA VEZ por caso y se mantiene estable durante
/// toda la sesión de juego. Los `resize()` solo recalculan posiciones y escalas;
/// nunca regeneran decisiones visuales.
///
/// Reglas de integridad:
/// - SOLO lee datos del caso (zonas, celdas bloqueadas, tema).
/// - NUNCA modifica `CaseData`, `CellData`, `PlacedObjectData`, `GroundTruth`,
///   solver, replay, pistas, candidatos, X, Auto-X ni persistencia.
/// - El RNG visual es completamente independiente del RNG del puzzle.
class VisualMapBuilder {
  const VisualMapBuilder._();

  /// Genera un [VisualMapPlan] determinista para el caso dado.
  ///
  /// El [caseSeed] debe derivarse de datos estables del caso (ej. caseId hash).
  /// El resultado es determinista: mismo seed → mismas decisiones visuales
  /// en cualquier plataforma.
  static VisualMapPlan build({
    required List<ZoneData> zones,
    required Set<CellPosition> blockedCells,
    required int caseSeed,
    ZoneTheme? theme,
    Set<String> logicalObjectIds = const {},
    Map<String, CellPosition> zoneNameCells = const {},
  }) {
    final rooms = <String, RoomVisualPlan>{};

    for (int i = 0; i < zones.length; i++) {
      final zone = zones[i];
      final archetype = RoomArchetypeResolver.resolve(
        zone.name ?? '',
        theme,
      );

      // Seed determinista por zona: combina seed del caso con índice y ID
      final zoneSeed = _deterministicHash(caseSeed, zone.id, i);
      final rng = Random(zoneSeed);

      // Seleccionar suelo
      final floorTileType = _pickFloor(archetype, rng);

      // Determinar si lleva alfombra
      final hasRug = _evaluateRug(
        archetype: archetype,
        zoneName: zone.name ?? '',
        theme: theme,
      );

      // Evaluar decoraciones visuales sin ambigüedad con objetos lógicos
      final decorations = _evaluateDecorations(
        zone: zone,
        archetype: archetype,
        blockedCells: blockedCells,
        theme: theme,
        logicalObjectIds: logicalObjectIds,
        zoneNameCell: zoneNameCells[zone.id],
        rng: rng,
      );

      rooms[zone.id] = RoomVisualPlan(
        zoneId: zone.id,
        archetype: archetype,
        floorTileType: floorTileType,
        hasRug: hasRug,
        decorations: decorations,
      );
    }

    return VisualMapPlan(rooms: rooms, seed: caseSeed);
  }

  /// Selecciona un TileType de los candidatos del arquetipo.
  static TileType _pickFloor(RoomArchetype archetype, Random rng) {
    final candidates = archetype.floorCandidates;
    if (candidates.length == 1) return candidates[0];
    return candidates[rng.nextInt(candidates.length)];
  }

  /// Evalúa si la habitación debería tener alfombra según su RugPolicy.
  static bool _evaluateRug({
    required RoomArchetype archetype,
    required String zoneName,
    ZoneTheme? theme,
  }) {
    switch (archetype.rugPolicy) {
      case RugPolicy.always:
        return true;
      case RugPolicy.never:
        return false;
      case RugPolicy.ifNoble:
        if (theme != null) {
          return theme.nobleZoneNames.contains(zoneName);
        }
        return false;
    }
  }

  /// Evalúa y genera decoraciones visuales para una zona.
  ///
  /// Reglas estrictas:
  /// - Habitaciones de 1 a 3 celdas: máximo 1 elemento decorativo adicional.
  /// - Habitaciones de 4 o más celdas: máximo 2 elementos decorativos adicionales.
  /// - Excluye la celda del nombre de la habitación para evitar solapamientos.
  /// - Excluye cualquier elemento decorativo que comparta identidad con los objetos lógicos del caso.
  /// - Nunca coloca dos decoraciones idénticas en la misma habitación.
  static List<VisualPlacement> _evaluateDecorations({
    required ZoneData zone,
    required RoomArchetype archetype,
    required Set<CellPosition> blockedCells,
    required ZoneTheme? theme,
    required Set<String> logicalObjectIds,
    required CellPosition? zoneNameCell,
    required Random rng,
  }) {
    if (archetype.decorationDensity == DecorationDensity.none) return const [];

    final zoneCellCount = zone.cells.length;
    final logicalCount = zone.cells.where(blockedCells.contains).length;

    // Celdas libres no ocupadas por objetos lógicos
    final freeCells = zone.cells.where((c) => !blockedCells.contains(c)).toList();
    if (freeCells.isEmpty) return const [];

    // Celdas elegibles (excluyendo la celda del nombre de zona si la habitación tiene >1 celda)
    final eligibleCells = (zoneCellCount > 1 && zoneNameCell != null)
        ? freeCells.where((c) => c != zoneNameCell).toList()
        : freeCells;

    if (eligibleCells.isEmpty) return const [];

    // Límites de densidad:
    // 1-3 celdas: máx 1; 4+ celdas: máx 2
    int maxAllowed;
    if (zoneCellCount <= 3) {
      if (zoneCellCount <= 2 || logicalCount >= 1 || eligibleCells.isEmpty) {
        maxAllowed = (zoneCellCount == 3 && logicalCount == 0) ? 1 : 0;
      } else {
        maxAllowed = 1;
      }
    } else {
      if (logicalCount >= 2) {
        maxAllowed = 0;
      } else if (logicalCount == 1) {
        maxAllowed = 1;
      } else {
        maxAllowed = 2;
      }
    }

    if (archetype.decorationDensity == DecorationDensity.sparse && maxAllowed > 1) {
      maxAllowed = 1;
    }

    final targetCount = min(maxAllowed, eligibleCells.length);
    if (targetCount <= 0) return const [];

    // Obtener pool temático y filtrar ambigüedades con objetos lógicos del caso
    final pool = _getDecorationPool(zone.name ?? '', theme);
    final filteredPool = pool
        .where((id) => !_isAmbiguousWithLogicalObjects(id, logicalObjectIds))
        .toList();

    if (filteredPool.isEmpty) return const [];

    // Seleccionar de forma determinista celdas y decoraciones sin repetición
    eligibleCells.shuffle(rng);
    filteredPool.shuffle(rng);

    final selectedCells = eligibleCells.take(targetCount).toList();
    final result = <VisualPlacement>[];

    final distinctCount = min(selectedCells.length, filteredPool.length);
    for (int i = 0; i < distinctCount; i++) {
      result.add(VisualPlacement(
        row: selectedCells[i].row,
        col: selectedCells[i].col,
        objectId: filteredPool[i],
        zoneId: zone.id,
      ));
    }

    return result;
  }

  /// Comprueba si un ID decorativo puede confundirse con algún objeto lógico del caso.
  static bool _isAmbiguousWithLogicalObjects(
    String decorId,
    Set<String> activeLogicalObjectIds,
  ) {
    if (activeLogicalObjectIds.isEmpty) return false;
    final decor = decorId.toLowerCase();

    for (final logicalId in activeLogicalObjectIds) {
      final log = logicalId.toLowerCase();

      // 1. Coincidencia directa
      if (decor == log) return true;

      // 2. Coincidencia por familia semántica/visual
      if ((log.contains('silla') || log.contains('chair')) &&
          (decor.contains('silla') || decor.contains('sillon') || decor.contains('sillón'))) {
        return true;
      }
      if ((log.contains('mesa') || log.contains('table') || log.contains('escritorio') || log.contains('desk')) &&
          (decor.contains('mesa') || decor.contains('escritorio') || decor.contains('desk'))) {
        return true;
      }
      if ((log.contains('armario') || log.contains('wardrobe') || log.contains('closet')) &&
          (decor.contains('armario') || decor.contains('aparador'))) {
        return true;
      }
      if ((log.contains('librero') || log.contains('bookshelf') || log.contains('estant')) &&
          (decor.contains('librero') || decor.contains('estante') || decor.contains('estant'))) {
        return true;
      }
      if ((log.contains('lampara') || log.contains('lámpara') || log.contains('lamp')) &&
          (decor.contains('lampara') || decor.contains('lámpara') || decor.contains('foco'))) {
        return true;
      }
      if ((log.contains('caja') || log.contains('box')) &&
          (decor.contains('caja') || decor.contains('baul') || decor.contains('baúl'))) {
        return true;
      }
      if ((log.contains('cama') || log.contains('bed')) && decor.contains('cama')) {
        return true;
      }
    }
    return false;
  }

  /// Retorna el pool de decoraciones temáticas disponibles para una habitación.
  ///
  /// Estos son los mismos objectId que ya usa DecorativeFurnitureEvaluator
  /// y que ArchitecturalFurnitureRenderer sabe dibujar como fallback.
  static List<String> _getDecorationPool(String zoneName, ZoneTheme? theme) {
    final lower = zoneName.toLowerCase();

    // Museo / Archivo
    if (theme == ZoneTheme.museumArchive) {
      if (lower.contains('egipcia')) {
        return const ['obj_sarcofago', 'obj_anfora', 'obj_pedestal'];
      }
      if (lower.contains('galer') || lower.contains('arte')) {
        return const ['obj_caballete', 'obj_vitrina', 'obj_estatua'];
      }
      if (lower.contains('bóveda') || lower.contains('boveda')) {
        return const ['obj_vitrina', 'obj_baul', 'obj_pedestal'];
      }
      if (lower.contains('restaura') || lower.contains('taller')) {
        return const ['obj_caballete', 'obj_escritorio', 'obj_baul'];
      }
      return const ['obj_pedestal', 'obj_anfora', 'obj_vitrina'];
    }

    // Teatro / Ópera
    if (theme == ZoneTheme.theaterOpera) {
      if (lower.contains('escenario')) {
        return const ['obj_atril', 'obj_foco', 'obj_pedestal'];
      }
      if (lower.contains('palco') || lower.contains('platea')) {
        return const ['obj_silla_terciopelo', 'obj_columna', 'obj_lampara'];
      }
      if (lower.contains('foso') || lower.contains('orquesta')) {
        return const ['obj_atril', 'obj_silla_terciopelo'];
      }
      if (lower.contains('camerino')) {
        return const ['obj_silla_terciopelo', 'obj_armario', 'obj_lampara'];
      }
      return const ['obj_columna', 'obj_estatua', 'obj_silla_terciopelo'];
    }

    // Jardín Botánico
    if (theme == ZoneTheme.botanicalGarden) {
      if (lower.contains('rosaleda') || lower.contains('orquíd') || lower.contains('vivero')) {
        return const ['obj_maceta', 'obj_banco', 'obj_anfora'];
      }
      if (lower.contains('tropical')) {
        return const ['obj_maceta', 'obj_fuente', 'obj_banco'];
      }
      if (lower.contains('huerto') || lower.contains('cobertizo')) {
        return const ['obj_baul', 'obj_banco', 'obj_estante'];
      }
      return const ['obj_maceta', 'obj_banco', 'obj_anfora'];
    }

    // Mansión Clásica / Default
    if (lower.contains('biblio') || lower.contains('despacho')) {
      return const ['obj_sillon', 'obj_lampara', 'obj_reloj', 'obj_estatua', 'obj_maceta'];
    }
    if (lower.contains('salón') || lower.contains('salon')) {
      return const ['obj_sillon', 'obj_reloj', 'obj_estatua', 'obj_maceta', 'obj_pedestal'];
    }
    if (lower.contains('comedor')) {
      return const ['obj_aparador', 'obj_reloj', 'obj_estatua', 'obj_maceta'];
    }
    if (lower.contains('cocina')) {
      return const ['obj_aparador', 'obj_baul', 'obj_reloj'];
    }
    if (lower.contains('dormitorio')) {
      return const ['obj_sillon', 'obj_lampara', 'obj_reloj', 'obj_maceta'];
    }
    if (lower.contains('juego')) {
      return const ['obj_sillon', 'obj_reloj', 'obj_estatua', 'obj_baul'];
    }
    if (lower.contains('vestíbulo') || lower.contains('vestibulo')) {
      return const ['obj_estatua', 'obj_reloj', 'obj_columna', 'obj_maceta', 'obj_pedestal'];
    }

    return const ['obj_sillon', 'obj_reloj', 'obj_estatua', 'obj_maceta'];
  }

  /// Hash determinista multiplataforma.
  ///
  /// NO usa `hashCode` de Dart (no estable entre plataformas/isolates).
  /// Combina el seed del caso con el ID de la zona y su índice.
  static int _deterministicHash(int caseSeed, String zoneId, int zoneIndex) {
    int hash = caseSeed & 0x7FFFFFFF;
    for (int i = 0; i < zoneId.length; i++) {
      hash = ((hash * 31) + zoneId.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    hash = ((hash * 37) + zoneIndex) & 0x7FFFFFFF;
    return hash;
  }
}
