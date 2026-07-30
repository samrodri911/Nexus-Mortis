/// Snapshot inmutable del estado exacto de una celda en un instante dado.
/// Permite persistir la partida sin acoplar la base de datos a la lógica de Flame/Flutter.
class CellSnapshot {
  const CellSnapshot({
    required this.row,
    required this.col,
    required this.candidateIds,
    required this.confirmedSuspectId,
    required this.eliminated,
    required this.autoEliminationSources,
  });

  final int row;
  final int col;
  final List<String> candidateIds;
  final String? confirmedSuspectId;
  final bool eliminated;
  final List<String> autoEliminationSources;
}
