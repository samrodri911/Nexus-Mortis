import 'package:nexus_mortis/game/save_state/models/cell_snapshot.dart';

/// Snapshot inmutable del estado completo de una partida en curso.
class ActiveGameState {
  const ActiveGameState({
    required this.caseId,
    required this.cells,
    required this.savedAt,
  });

  final String caseId;
  final List<CellSnapshot> cells;
  final DateTime savedAt;
}
