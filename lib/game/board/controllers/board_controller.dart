import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/game/board/models/cell_annotation.dart';
import 'package:nexus_mortis/game/board/models/cell_data.dart';
import 'package:nexus_mortis/game/board/models/tool_mode.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/player/models/player_assignment.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/models/cell_snapshot.dart';

/// Controla el estado lógico del tablero.
///
/// Responsabilidades:
/// - Mantener la grilla de [CellData] y construirla a partir de un [CaseData].
/// - Gestionar el sospechoso seleccionado y la herramienta activa.
/// - Aplicar marcas según las reglas.
/// - Gestionar confirmaciones y Auto-X.
///
/// NO conoce ni utiliza [SolutionData] para garantizar que el estado del
/// jugador esté aislado de la verdad del puzzle.
class BoardController {
  BoardController({
    required this.cells,
    required this.suspects,
    required this.clues,
    required this.placedObjects,
  });

  /// Construye el controlador extrayendo solo lo necesario del [CaseData].
  factory BoardController.fromCase(CaseData caseData) {
    final cells = List.generate(
      caseData.boardRows,
      (r) => List.generate(caseData.boardColumns, (c) {
        return CellData(row: r, col: c, type: CellType.free);
      }),
    );

    // Posicionar objetos físicos que bloquean celdas
    for (final placed in caseData.placedObjects) {
      final pos = placed.position;
      if (pos.row >= 0 &&
          pos.row < caseData.boardRows &&
          pos.col >= 0 &&
          pos.col < caseData.boardColumns) {
        cells[pos.row][pos.col] = CellData(
          row: pos.row,
          col: pos.col,
          type: CellType.blocked,
          objectId: placed.object.id,
        );
      }
    }

    return BoardController(
      cells: cells,
      suspects: caseData.suspects,
      clues: caseData.clues,
      placedObjects: caseData.placedObjects,
    );
  }

  /// Construye el controlador reconstruyendo su estado interno a partir de un snapshot de guardado.
  factory BoardController.fromSaveState(CaseData caseData, ActiveGameState saveState) {
    final controller = BoardController.fromCase(caseData);

    for (int r = 0; r < controller.cells.length; r++) {
      for (int c = 0; c < controller.cells[r].length; c++) {
        final cell = controller.cells[r][c];
        // Encontrar el snapshot correspondiente a la celda original (r, c)
        // Como la lista de snapshots es un vector lineal, calculamos el índice:
        // índice = r * columnas + c
        final snapshot = saveState.cells[r * caseData.boardColumns + c];

        cell.candidateSuspectIds.addAll(snapshot.candidateIds);
        cell.confirmedSuspectId = snapshot.confirmedSuspectId;
        cell.annotation = snapshot.eliminated ? CellAnnotation.eliminated : CellAnnotation.none;
        cell.autoEliminationSources.addAll(snapshot.autoEliminationSources);

        // Reconstruir la fuente de verdad de las confirmaciones
        if (snapshot.confirmedSuspectId != null) {
          controller._confirmedAssignments[snapshot.confirmedSuspectId!] = CellPosition(r, c);
        }
      }
    }

    return controller;
  }

  final List<List<CellData>> cells;
  final List<SuspectData> suspects;
  final List<SpatialClueData> clues;
  final List<PlacedObjectData> placedObjects;

  SuspectData? selectedSuspect;
  ToolMode activeTool = ToolMode.candidate;

  /// Callback invocado cuando ocurre una acción explícita de corrección o error (deshacer/desconfirmar).
  VoidCallback? onMistakeOccurred;

  /// Versión de estado. Cada mutación incrementa este valor.
  /// Los widgets de Flutter pueden usar [ValueListenableBuilder] para
  /// reconstruirse automáticamente cuando el tablero cambia.
  final ValueNotifier<int> version = ValueNotifier(0);

  /// Fuente de verdad de las confirmaciones activas (ID sospechoso → posición).
  /// Las celdas derivan su [CellData.confirmedSuspectId] de este mapa.
  final Map<String, CellPosition> _confirmedAssignments = {};

  // ─── Notificación ─────────────────────────────────────────────────────────

  void _notifyChanged() => version.value++;

  // ─── Selección y herramienta ──────────────────────────────────────────────

  void selectSuspect(SuspectData? suspect) {
    selectedSuspect = suspect;
    _notifyChanged();
  }

  void setToolMode(ToolMode mode) {
    activeTool = mode;
    _notifyChanged();
  }

  // ─── Utilidades ───────────────────────────────────────────────────────────

  /// Retorna el nombre de un objeto a partir de su ID.
  String? getObjectLabel(String objectId) {
    for (final placed in placedObjects) {
      if (placed.object.id == objectId) return placed.object.name;
    }
    return null;
  }

  /// Una celda está bloqueada (dura) si tiene un objeto físico o una
  /// confirmación activa. Las Auto-X son visuales y NO bloquean.
  bool isCellLocked(int row, int col) {
    final cell = cells[row][col];
    return cell.isBlocked || cell.confirmedSuspectId != null;
  }

  /// Devuelve true si el sospechoso tiene una posición confirmada.
  bool isSuspectConfirmed(String suspectId) =>
      _confirmedAssignments.containsKey(suspectId);

  /// Devuelve la posición confirmada del sospechoso, o null si no existe.
  CellPosition? getConfirmedPosition(String suspectId) =>
      _confirmedAssignments[suspectId];

  // ─── Marcas ───────────────────────────────────────────────────────────────

  bool toggleMark(int row, int col) {
    // Bloqueo duro: objetos y celdas confirmadas.
    if (isCellLocked(row, col)) return false;

    final cell = cells[row][col];

    if (activeTool == ToolMode.eliminated) {
      // Modo X: anotación global de la celda.
      if (cell.annotation == CellAnnotation.eliminated) {
        cell.annotation = CellAnnotation.none;
      } else {
        cell.annotation = CellAnnotation.eliminated;
        // Regla: poner X elimina todos los candidatos manuales.
        cell.candidateSuspectIds.clear();
      }
      _notifyChanged();
      return true;
    } else if (activeTool == ToolMode.candidate) {
      // Modo Posible: requiere un sospechoso seleccionado.
      if (selectedSuspect == null) return false;

      // Regla: si la celda tiene X manual, no se pueden agregar candidatos.
      if (cell.annotation == CellAnnotation.eliminated) return false;

      final id = selectedSuspect!.id;
      if (cell.candidateSuspectIds.contains(id)) {
        cell.candidateSuspectIds.remove(id);
      } else {
        cell.candidateSuspectIds.add(id);
      }
      _notifyChanged();
      return true;
    }

    return false;
  }

  Set<String> getCandidates(int row, int col) =>
      cells[row][col].candidateSuspectIds;

  bool hasCandidate(int row, int col, String suspectId) =>
      cells[row][col].candidateSuspectIds.contains(suspectId);

  // ─── Confirmation System ──────────────────────────────────────────────────

  /// Devuelve todas las posiciones candidatas de un sospechoso en la grilla.
  List<CellPosition> _getCandidatesFor(String suspectId) {
    final result = <CellPosition>[];
    for (int r = 0; r < cells.length; r++) {
      for (int c = 0; c < cells[r].length; c++) {
        if (cells[r][c].candidateSuspectIds.contains(suspectId)) {
          result.add(CellPosition(r, c));
        }
      }
    }
    return result;
  }

  /// Devuelve true si el sospechoso seleccionado puede ser confirmado.
  bool canConfirmSelectedSuspect() {
    if (selectedSuspect == null) return false;

    // Regla: no se puede confirmar si ya está confirmado.
    if (isSuspectConfirmed(selectedSuspect!.id)) return false;

    // Regla: exactamente 1 candidato activo.
    final candidates = _getCandidatesFor(selectedSuspect!.id);
    if (candidates.length != 1) return false;

    // Regla: la celda objetivo no está confirmada por otro sospechoso.
    final target = candidates.first;
    if (cells[target.row][target.col].confirmedSuspectId != null) return false;

    return true;
  }

  /// Confirma la posición del sospechoso seleccionado.
  /// Aplica Auto-X en la fila y columna y elimina candidatos duplicados.
  /// Retorna true si la confirmación fue exitosa.
  bool confirmSelectedSuspect() {
    if (!canConfirmSelectedSuspect()) return false;

    final suspect = selectedSuspect!;
    final target = _getCandidatesFor(suspect.id).first;
    final targetCell = cells[target.row][target.col];

    // 1. Registrar en la fuente de verdad.
    _confirmedAssignments[suspect.id] = target;

    // 2. Sincronizar la caché de la celda.
    targetCell.confirmedSuspectId = suspect.id;

    // 3. El candidato de la celda confirmada ya no es necesario.
    targetCell.candidateSuspectIds.remove(suspect.id);

    // 4. Limpiar todos los demás candidatos del sospechoso en la grilla.
    for (int r = 0; r < cells.length; r++) {
      for (int c = 0; c < cells[r].length; c++) {
        if (r == target.row && c == target.col) continue;
        cells[r][c].candidateSuspectIds.remove(suspect.id);
      }
    }

    // 5. Aplicar Auto-X en fila y columna.
    _applyAutoX(suspect.id, target);

    // ─── EXTENSION POINT: Statistics ───────────────────────────────────────
    _onConfirmationEvent(suspectId: suspect.id, position: target);
    // ───────────────────────────────────────────────────────────────────────

    _notifyChanged();
    return true;
  }

  /// Revierte la confirmación de un sospechoso.
  /// Restaura la celda y elimina las Auto-X generadas por esa confirmación.
  void unconfirmSuspect(String suspectId) {
    final pos = _confirmedAssignments[suspectId];
    if (pos == null) return;

    final cell = cells[pos.row][pos.col];

    // 1. Eliminar de la fuente de verdad.
    _confirmedAssignments.remove(suspectId);

    // 2. Limpiar la caché de la celda y restaurar como candidato.
    cell.confirmedSuspectId = null;
    cell.candidateSuspectIds.add(suspectId);

    // 3. Revertir Auto-X de la fila y columna generadas por este sospechoso.
    _removeAutoX(suspectId, pos);

    // ─── EXTENSION POINT: Statistics ───────────────────────────────────────
    _onConfirmationEvent(suspectId: suspectId, position: null);
    // ───────────────────────────────────────────────────────────────────────

    _notifyChanged();
  }

  /// Aplica Auto-X en la fila y columna de [pos] en nombre de [suspectId].
  void _applyAutoX(String suspectId, CellPosition pos) {
    for (int c = 0; c < cells[pos.row].length; c++) {
      if (c == pos.col) continue;
      _addAutoSource(pos.row, c, suspectId);
    }
    for (int r = 0; r < cells.length; r++) {
      if (r == pos.row) continue;
      _addAutoSource(r, pos.col, suspectId);
    }
  }

  /// Elimina la Auto-X de [suspectId] en la fila y columna de [pos].
  void _removeAutoX(String suspectId, CellPosition pos) {
    for (int c = 0; c < cells[pos.row].length; c++) {
      cells[pos.row][c].autoEliminationSources.remove(suspectId);
    }
    for (int r = 0; r < cells.length; r++) {
      cells[r][pos.col].autoEliminationSources.remove(suspectId);
    }
  }

  /// Agrega [suspectId] a las fuentes de Auto-X de la celda (r, c),
  /// respetando las reglas: no sobreescribir objetos ni celdas confirmadas.
  void _addAutoSource(int r, int c, String suspectId) {
    final cell = cells[r][c];
    // No marcar sobre objetos físicos ni celdas ya confirmadas.
    if (cell.isBlocked || cell.confirmedSuspectId != null) return;
    cell.autoEliminationSources.add(suspectId);
  }

  // ─── EXTENSION POINT: Statistics ──────────────────────────────────────────
  void _onConfirmationEvent({
    required String suspectId,
    required CellPosition? position, // null = desconfirmación
  }) {
    if (position == null) {
      onMistakeOccurred?.call();
    }
  }
  // ──────────────────────────────────────────────────────────────────────────

  // ─── Exportar estado ──────────────────────────────────────────────────────

  /// Extrae una fotografía del estado lógico actual del jugador
  /// para ser inyectada en el Validation System.
  ///
  /// Las confirmaciones se exponen como asignaciones de 1 único candidato,
  /// por lo que el [ValidationService] no necesita conocer el concepto de
  /// confirmación directamente.
  PlayerBoardState exportPlayerState() {
    final assignmentsMap = <String, List<CellPosition>>{};
    for (final s in suspects) {
      assignmentsMap[s.id] = [];
    }

    final eliminatedCells = <CellPosition>{};

    for (int r = 0; r < cells.length; r++) {
      for (int c = 0; c < cells[r].length; c++) {
        final cell = cells[r][c];

        // 1. Las confirmaciones tienen prioridad como posición única.
        if (cell.confirmedSuspectId != null) {
          assignmentsMap[cell.confirmedSuspectId!]?.add(CellPosition(r, c));
        } else {
          // 2. Recolectar candidatos normales.
          for (final suspectId in cell.candidateSuspectIds) {
            assignmentsMap[suspectId]?.add(CellPosition(r, c));
          }
        }

        // 3. Recolectar celdas eliminadas globalmente (X manual).
        if (cell.annotation == CellAnnotation.eliminated) {
          eliminatedCells.add(CellPosition(r, c));
        }
      }
    }

    final assignments = assignmentsMap.entries
        .map((e) => PlayerAssignment(suspectId: e.key, candidates: e.value))
        .toList();

    return PlayerBoardState(
      assignments: assignments,
      eliminatedCells: eliminatedCells,
    );
  }

  /// Extrae un snapshot completo del estado lógico interno de la grilla,
  /// incluyendo candidatos, confirmaciones, y auto eliminaciones,
  /// para ser persistido en Isar por el SaveGameService.
  ActiveGameState exportGameState(String caseId) {
    final snapshots = <CellSnapshot>[];
    for (int r = 0; r < cells.length; r++) {
      for (int c = 0; c < cells[r].length; c++) {
        final cell = cells[r][c];
        snapshots.add(CellSnapshot(
          row: r,
          col: c,
          candidateIds: cell.candidateSuspectIds.toList(),
          confirmedSuspectId: cell.confirmedSuspectId,
          eliminated: cell.annotation == CellAnnotation.eliminated,
          autoEliminationSources: cell.autoEliminationSources.toList(),
        ));
      }
    }

    return ActiveGameState(
      caseId: caseId,
      cells: snapshots,
      savedAt: DateTime.now(),
    );
  }
}
