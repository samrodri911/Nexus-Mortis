import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';

/// Define la totalidad de un caso o nivel dentro de Nexus Mortis.
///
/// Es el único punto de verdad inmutable (fuente de datos) para construir el
/// tablero, configurar la UI de investigación y validar al jugador en el futuro.
class CaseData {
  const CaseData({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.boardRows,
    required this.boardColumns,
    required this.suspects,
    required this.placedObjects,
    required this.clues,
    required this.solution,
    this.requiredCaseId,
    this.origin = CaseOrigin.campaign,
  });

  final String id;
  final String title;
  final String description;
  final PuzzleDifficulty difficulty;

  final int boardRows;
  final int boardColumns;

  /// Lista de sospechosos involucrados en el caso.
  final List<SuspectData> suspects;

  /// Objetos físicos inamovibles presentes en el escenario.
  /// Contienen su información base (ObjectData) y su posición (CellPosition).
  final List<PlacedObjectData> placedObjects;

  /// Pistas textuales y lógicas disponibles para el jugador.
  final List<SpatialClueData> clues;

  /// La solución correcta del caso.
  /// Se mantiene aislada del estado de juego (BoardController)
  /// para evitar acoplamientos y prepararse para el sistema de validación.
  final SolutionData solution;

  /// ID del caso que debe ser completado antes de poder jugar este.
  /// Si es null, el caso está desbloqueado por defecto.
  final String? requiredCaseId;

  /// Origen del caso para sistemas externos (estadísticas, economía, recompensas).
  /// Por defecto es `CaseOrigin.campaign`.
  final CaseOrigin origin;
}
