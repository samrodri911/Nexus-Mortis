import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/visual/models/room_archetype.dart';

/// Represents a single visual decoration placement.
/// Strictly presentational, defines where a decorative object goes.
class VisualPlacement {
  final int row;
  final int col;
  final String objectId;
  final String zoneId;

  const VisualPlacement({
    required this.row,
    required this.col,
    required this.objectId,
    required this.zoneId,
  });
}

/// Represents the visual plan for a single room.
class RoomVisualPlan {
  final String zoneId;
  final RoomArchetype archetype;
  final TileType floorTileType;
  final bool hasRug;
  final List<VisualPlacement> decorations;

  const RoomVisualPlan({
    required this.zoneId,
    required this.archetype,
    required this.floorTileType,
    this.hasRug = false,
    required this.decorations,
  });
}

/// Represents the procedural visual plan for the entire map.
class VisualMapPlan {
  final Map<String, RoomVisualPlan> rooms;
  final int seed;

  const VisualMapPlan({
    required this.rooms,
    required this.seed,
  });

  /// Helper method to get the visual plan for a specific zone.
  RoomVisualPlan? forZone(String zoneId) {
    return rooms[zoneId];
  }
}
