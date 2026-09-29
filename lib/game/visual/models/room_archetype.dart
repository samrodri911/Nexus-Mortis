import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';

/// Defines the density of decorations for a room.
enum DecorationDensity {
  none,
  sparse,
  moderate,
}

/// Defines the policy for placing rugs in a room.
enum RugPolicy {
  always,
  ifNoble,
  never,
}

/// Represents visual room archetypes for the procedural decoration system.
/// This enum groups similar functional rooms across different zones to determine
/// their visual presentation defaults, such as floor type, decoration density, and rug policy.
enum RoomArchetype {
  /// Archetype for libraries, offices, and archives.
  library(
    floorCandidates: [TileType.woodPlanks],
    decorationDensity: DecorationDensity.sparse,
    rugPolicy: RugPolicy.ifNoble,
  ),

  /// Archetype for kitchens and similar utility food rooms.
  kitchen(
    floorCandidates: [TileType.checkerboard],
    decorationDensity: DecorationDensity.sparse,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for outdoor or garden-like rooms.
  garden(
    floorCandidates: [TileType.stone],
    decorationDensity: DecorationDensity.sparse,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for bedrooms and dressing rooms.
  bedroom(
    floorCandidates: [TileType.woodPlanks, TileType.classicTiles],
    decorationDensity: DecorationDensity.sparse,
    rugPolicy: RugPolicy.ifNoble,
  ),

  /// Archetype for exhibition rooms, galleries, and museums.
  gallery(
    floorCandidates: [TileType.woodPlanks, TileType.classicTiles],
    decorationDensity: DecorationDensity.none,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for salons, dining rooms, and lounges.
  lounge(
    floorCandidates: [TileType.carpet, TileType.woodPlanks],
    decorationDensity: DecorationDensity.moderate,
    rugPolicy: RugPolicy.always,
  ),

  /// Archetype for stages and performance areas.
  stage(
    floorCandidates: [TileType.woodPlanks],
    decorationDensity: DecorationDensity.none,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for laboratories, workshops, and rehearsal spaces.
  workshop(
    floorCandidates: [TileType.classicTiles, TileType.stone],
    decorationDensity: DecorationDensity.none,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for vaults, sheds, and utility storage.
  storage(
    floorCandidates: [TileType.stone],
    decorationDensity: DecorationDensity.none,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for lobbies, vestibules, and open public floors.
  hall(
    floorCandidates: [TileType.checkerboard, TileType.stone],
    decorationDensity: DecorationDensity.sparse,
    rugPolicy: RugPolicy.never,
  ),

  /// Archetype for orchestra pits.
  orchestraPit(
    floorCandidates: [TileType.woodPlanks, TileType.carpet],
    decorationDensity: DecorationDensity.none,
    rugPolicy: RugPolicy.never,
  );

  /// The list of valid tile types for this archetype.
  final List<TileType> floorCandidates;

  /// The density of decorative elements spawned in this archetype.
  final DecorationDensity decorationDensity;

  /// The rules for determining if a rug should be placed.
  final RugPolicy rugPolicy;

  const RoomArchetype({
    required this.floorCandidates,
    required this.decorationDensity,
    required this.rugPolicy,
  });

  /// Resolves the archetype from a specific room name.
  /// Maps all rooms from the 4 ZoneThemes to a suitable RoomArchetype.
  static RoomArchetype fromRoomName(String roomName) {
    switch (roomName) {
      // classicMansion
      case 'Biblioteca':
      case 'Despacho':
      case 'Archivo':
        return RoomArchetype.library;
      case 'Cocina':
        return RoomArchetype.kitchen;
      case 'Dormitorio':
      case 'Camerinos':
        return RoomArchetype.bedroom;
      case 'Salón Principal':
      case 'Comedor':
      case 'Sala de Juegos':
      case 'Palcos':
        return RoomArchetype.lounge;
      case 'Vestíbulo':
      case 'Platea':
        return RoomArchetype.hall;

      // theaterOpera
      case 'Escenario':
        return RoomArchetype.stage;
      case 'Foso de Orquesta':
        return RoomArchetype.orchestraPit;
      case 'Sala de Ensayos':
      case 'Taller de Restauración':
        return RoomArchetype.workshop;

      // botanicalGarden
      case 'Rosaleda':
      case 'Orquideario':
      case 'Pabellón Tropical':
      case 'Huerto':
      case 'Estanque':
      case 'Vivero':
        return RoomArchetype.garden;
      case 'Cobertizo':
      case 'Bóveda':
        return RoomArchetype.storage;

      // museumArchive
      case 'Galería de Arte':
      case 'Sala Clásica':
      case 'Sala Egipcia':
        return RoomArchetype.gallery;

      default:
        // Fallback for any unrecognized room name.
        return RoomArchetype.lounge;
    }
  }
}
