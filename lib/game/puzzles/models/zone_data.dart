import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';

class ZoneData {
  const ZoneData({
    required this.id,
    this.name,
    required this.cells,
  });

  final String id;
  final String? name;
  final List<CellPosition> cells;
}
