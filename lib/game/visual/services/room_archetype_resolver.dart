import 'package:nexus_mortis/game/visual/models/room_archetype.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

/// Resolvedor centralizado de arquetipos visuales para habitaciones.
///
/// Único punto de verdad para mapear `(ZoneTheme?, zoneName) → RoomArchetype`.
/// Evita comparaciones de strings dispersas en renderers.
///
/// Regla: las habitaciones son metadata visual; este resolver no crea, modifica
/// ni afecta ningún dato lógico del puzzle.
class RoomArchetypeResolver {
  const RoomArchetypeResolver._();

  /// Resuelve el [RoomArchetype] apropiado para una habitación.
  ///
  /// Utiliza coincidencia case-insensitive por substring para ser robusto
  /// ante variaciones menores en nombres. El [theme] se usa como contexto
  /// para desambiguar nombres compartidos (ej. 'Vestíbulo' existe en varios temas).
  static RoomArchetype resolve(String zoneName, [ZoneTheme? theme]) {
    final lower = zoneName.toLowerCase();

    // --- Biblioteca / Estudio / Archivo / Despacho ---
    if (lower.contains('biblio') ||
        lower.contains('archivo') ||
        lower.contains('despacho') ||
        lower.contains('estudio')) {
      return RoomArchetype.library;
    }

    // --- Cocina ---
    if (lower.contains('cocina')) return RoomArchetype.kitchen;

    // --- Comedor ---
    if (lower.contains('comedor')) return RoomArchetype.lounge;

    // --- Dormitorio / Camerinos ---
    if (lower.contains('dormitorio') || lower.contains('camerino')) {
      return RoomArchetype.bedroom;
    }

    // --- Escenario ---
    if (lower.contains('escenario')) return RoomArchetype.stage;

    // --- Galería / Museo / Sala Clásica / Sala Egipcia ---
    if (lower.contains('galer') ||
        lower.contains('museo') ||
        lower.contains('clásic') ||
        lower.contains('clasic') ||
        lower.contains('egipcia')) {
      return RoomArchetype.gallery;
    }

    // --- Bóveda / Cobertizo ---
    if (lower.contains('bóveda') ||
        lower.contains('boveda') ||
        lower.contains('cobertizo')) {
      return RoomArchetype.storage;
    }

    // --- Jardín / Rosaleda / Orquideario / Tropical / Vivero / Estanque / Huerto ---
    if (lower.contains('rosaleda') ||
        lower.contains('orquíd') ||
        lower.contains('orquid') ||
        lower.contains('tropical') ||
        lower.contains('vivero') ||
        lower.contains('estanque') ||
        lower.contains('huerto') ||
        lower.contains('jard') ||
        lower.contains('botán') ||
        lower.contains('botan')) {
      return RoomArchetype.garden;
    }

    // --- Foso de Orquesta ---
    if (lower.contains('foso') || lower.contains('orquesta')) {
      return RoomArchetype.orchestraPit;
    }

    // --- Taller / Ensayo / Restauración ---
    if (lower.contains('taller') ||
        lower.contains('ensayo') ||
        lower.contains('restaura')) {
      return RoomArchetype.workshop;
    }

    // --- Vestíbulo / Platea ---
    if (lower.contains('vestíbulo') ||
        lower.contains('vestibulo') ||
        lower.contains('platea')) {
      return RoomArchetype.hall;
    }

    // --- Palcos ---
    if (lower.contains('palco')) return RoomArchetype.hall;

    // --- Salón / Sala de Juegos ---
    if (lower.contains('salón') ||
        lower.contains('salon') ||
        lower.contains('juego')) {
      return RoomArchetype.lounge;
    }

    // Fallback seguro
    return RoomArchetype.lounge;
  }
}
