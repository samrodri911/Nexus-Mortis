import 'package:nexus_mortis/game/board/models/cell_annotation.dart';

/// Tipo estructural de la celda: si está disponible o bloqueada por un objeto.
enum CellType {
  free,
  blocked,
}

/// Estado visual de la celda.
///
/// Actualmente solo se usa [normal], pero la arquitectura ya contempla
/// futuros estados: hover, hinted, solution, error.
enum CellState {
  normal,
  highlighted,
}

/// Modelo de datos de una celda del tablero espacial.
///
/// Cada celda representa una posición física del escenario.
/// Las celdas [CellType.blocked] están ocupadas por un objeto del escenario.
/// Las celdas [CellType.free] pueden acumular candidatos de sospechosos o marcas.
///
/// Las propiedades [row] y [col] son fundamentales para el futuro sistema
/// de pistas espaciales (e.g. distancia Manhattan, relaciones de adyacencia).
class CellData {
  CellData({
    required this.row,
    required this.col,
    required this.type,
    this.objectId,
    this.state = CellState.normal,
  })  : candidateSuspectIds = {},
        autoEliminationSources = {};

  final int row;
  final int col;
  final CellType type;

  /// ID del objeto fijo que ocupa esta celda.
  /// Solo presente cuando [type] == [CellType.blocked].
  final String? objectId;

  /// Estado visual actual de la celda.
  CellState state;

  /// Anotación global de la celda (ej. descartada manualmente con 'X').
  /// Pertenece a la celda misma, no a un sospechoso específico.
  CellAnnotation annotation = CellAnnotation.none;

  /// IDs de los sospechosos marcados como candidatos en esta celda.
  final Set<String> candidateSuspectIds;

  /// ID del sospechoso confirmado en esta celda.
  /// Es una caché de renderizado sincronizada con
  /// [BoardController._confirmedAssignments], que es la fuente de verdad.
  String? confirmedSuspectId;

  /// IDs de sospechosos cuya confirmación generó un bloqueo automático
  /// en esta celda (Auto-X). La celda muestra Auto-X si el Set no está vacío.
  /// Al desconfirmar un sospechoso, su ID se elimina de esta colección,
  /// sin afectar los bloqueos generados por otros sospechosos.
  final Set<String> autoEliminationSources;

  /// Retorna true si la celda muestra una Auto-X activa.
  bool get isAutoEliminated => autoEliminationSources.isNotEmpty;

  /// Una celda con objeto físico.
  bool get isBlocked => type == CellType.blocked;

  /// Una celda sin objeto físico.
  bool get isFree => type == CellType.free;
}
