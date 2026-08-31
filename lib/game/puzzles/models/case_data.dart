import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

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
    required this.zones,
    required this.suspects,
    required this.victimId,
    required this.killerId,
    required this.placedObjects,
    required this.clues,
    required this.solution,
    this.globalRules = const [],
    this.requiredCaseId,
    this.origin = CaseOrigin.campaign,
  });

  final String id;
  final String title;
  final String description;
  final PuzzleDifficulty difficulty;

  final int boardRows;
  final int boardColumns;

  /// Zonas lógicas y visuales del tablero.
  final List<ZoneData> zones;

  /// Lista de entidades investigables en el caso (incluye a la víctima).
  final List<SuspectData> suspects;

  /// ID de la víctima (que debe existir en suspects).
  final String victimId;

  /// ID del asesino (que debe existir en suspects).
  final String killerId;

  /// Objetos físicos inamovibles presentes en el escenario.
  /// Contienen su información base (ObjectData) y su posición (CellPosition).
  final List<PlacedObjectData> placedObjects;

  /// Pistas textuales y lógicas disponibles para el jugador (1 tarjeta por sospechoso + víctima).
  final List<SpatialClueData> clues;

  /// Reglas o condiciones generales del escenario (opcionales, 0 a 2).
  final List<BoardRuleData> globalRules;

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

  CaseData copyWith({
    String? id,
    String? title,
    String? description,
    PuzzleDifficulty? difficulty,
    int? boardRows,
    int? boardColumns,
    List<ZoneData>? zones,
    List<SuspectData>? suspects,
    String? victimId,
    String? killerId,
    List<PlacedObjectData>? placedObjects,
    List<SpatialClueData>? clues,
    List<BoardRuleData>? globalRules,
    SolutionData? solution,
    String? requiredCaseId,
    CaseOrigin? origin,
  }) {
    return CaseData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      boardRows: boardRows ?? this.boardRows,
      boardColumns: boardColumns ?? this.boardColumns,
      zones: zones ?? this.zones,
      suspects: suspects ?? this.suspects,
      victimId: victimId ?? this.victimId,
      killerId: killerId ?? this.killerId,
      placedObjects: placedObjects ?? this.placedObjects,
      clues: clues ?? this.clues,
      globalRules: globalRules ?? this.globalRules,
      solution: solution ?? this.solution,
      requiredCaseId: requiredCaseId ?? this.requiredCaseId,
      origin: origin ?? this.origin,
    );
  }
}
