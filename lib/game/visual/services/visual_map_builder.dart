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

      // Evaluar decoraciones visuales
      final decorations = _evaluateDecorations(
        zone: zone,
        archetype: archetype,
        blockedCells: blockedCells,
        theme: theme,
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
  /// Reglas de densidad (coherentes con DecorativeFurnitureEvaluator):
  /// - `none`: 0 decoraciones.
  /// - `sparse`: 0-1 decoraciones según tamaño de la habitación.
  /// - `moderate`: 1-2 decoraciones según tamaño de la habitación.
  ///
  /// No coloca decoraciones en celdas bloqueadas por objetos lógicos.
  static List<VisualPlacement> _evaluateDecorations({
    required ZoneData zone,
    required RoomArchetype archetype,
    required Set<CellPosition> blockedCells,
    required ZoneTheme? theme,
    required Random rng,
  }) {
    if (archetype.decorationDensity == DecorationDensity.none) return const [];

    final zoneCellCount = zone.cells.length;

    // Contar objetos lógicos ya presentes
    final logicalCount = zone.cells.where(blockedCells.contains).length;
    if (logicalCount >= 2) return const [];

    // Calcular target de decoraciones
    int targetCount;
    if (archetype.decorationDensity == DecorationDensity.sparse) {
      if (zoneCellCount <= 2 || logicalCount >= 1) {
        targetCount = 0;
      } else if (zoneCellCount <= 4) {
        targetCount = logicalCount == 0 ? 1 : 0;
      } else {
        targetCount = 1;
      }
    } else {
      // moderate
      if (zoneCellCount <= 2) {
        targetCount = 0;
      } else if (zoneCellCount <= 4) {
        targetCount = 1;
      } else {
        targetCount = min(2, (zoneCellCount / 3).floor());
      }
      if (logicalCount >= 1) {
        targetCount = min(targetCount, max(0, 2 - logicalCount));
      }
    }

    if (targetCount <= 0) return const [];

    // Filtrar celdas elegibles (no bloqueadas)
    final eligible = zone.cells
        .where((cell) => !blockedCells.contains(cell))
        .toList();

    if (eligible.isEmpty) return const [];

    // Seleccionar celdas
    eligible.shuffle(rng);
    final selectedCells = eligible.take(targetCount).toList();

    // Seleccionar IDs de decoración temáticos
    final pool = _getDecorationPool(zone.name ?? '', theme);
    if (pool.isEmpty) return const [];

    final result = <VisualPlacement>[];
    for (final cell in selectedCells) {
      final objId = pool[rng.nextInt(pool.length)];
      result.add(VisualPlacement(
        row: cell.row,
        col: cell.col,
        objectId: objId,
        zoneId: zone.id,
      ));
    }

    return result;
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
      return const ['obj_librero', 'obj_lampara', 'obj_sillon'];
    }
    if (lower.contains('salón') || lower.contains('salon')) {
      return const ['obj_sillon', 'obj_reloj', 'obj_estatua'];
    }
    if (lower.contains('comedor')) {
      return const ['obj_aparador', 'obj_silla', 'obj_reloj'];
    }
    if (lower.contains('cocina')) {
      return const ['obj_aparador', 'obj_baul'];
    }
    if (lower.contains('dormitorio')) {
      return const ['obj_sillon', 'obj_armario', 'obj_lampara'];
    }
    if (lower.contains('juego')) {
      return const ['obj_sillon', 'obj_reloj', 'obj_librero'];
    }
    if (lower.contains('vestíbulo') || lower.contains('vestibulo')) {
      return const ['obj_estatua', 'obj_reloj', 'obj_columna'];
    }

    return const ['obj_sillon', 'obj_reloj', 'obj_librero'];
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
