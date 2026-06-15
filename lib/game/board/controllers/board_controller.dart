import 'package:nexus_mortis/game/board/models/cell_annotation.dart';
import 'package:nexus_mortis/game/board/models/cell_data.dart';
import 'package:nexus_mortis/game/board/models/tool_mode.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';

/// Controla el estado lógico del tablero.
///
/// Responsabilidades:
/// - Mantener la grilla de [CellData] y construirla a partir de un [CaseData].
/// - Gestionar el sospechoso seleccionado y la herramienta activa.
/// - Aplicar marcas según las reglas.
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
      if (pos.row >= 0 && pos.row < caseData.boardRows && pos.col >= 0 && pos.col < caseData.boardColumns) {
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

  final List<List<CellData>> cells;
  final List<SuspectData> suspects;
  final List<SpatialClueData> clues;
  final List<PlacedObjectData> placedObjects;

  SuspectData? selectedSuspect;
  ToolMode activeTool = ToolMode.candidate;

  void selectSuspect(SuspectData? suspect) {
    selectedSuspect = suspect;
  }

  void setToolMode(ToolMode mode) {
    activeTool = mode;
  }

  /// Retorna el nombre de un objeto a partir de su ID para mostrarlo en UI.
  String? getObjectLabel(String objectId) {
    for (final placed in placedObjects) {
      if (placed.object.id == objectId) return placed.object.name;
    }
    return null;
  }

  bool toggleMark(int row, int col) {
    final cell = cells[row][col];
    
    // Regla C: celdas con objetos fijos no admiten marcas.
    if (cell.isBlocked) return false;

    if (activeTool == ToolMode.eliminated) {
      // Modo X: Anotación global de la celda.
      if (cell.annotation == CellAnnotation.eliminated) {
        cell.annotation = CellAnnotation.none;
      } else {
        cell.annotation = CellAnnotation.eliminated;
        // Regla A: Poner X elimina todos los candidatos.
        cell.candidateSuspectIds.clear();
      }
      return true;
    } else if (activeTool == ToolMode.candidate) {
      // Modo Posible: Requiere un sospechoso seleccionado.
      if (selectedSuspect == null) return false;

      // Regla B: Si la celda tiene X, no se pueden agregar candidatos.
      if (cell.annotation == CellAnnotation.eliminated) return false;
      
      final id = selectedSuspect!.id;
      if (cell.candidateSuspectIds.contains(id)) {
        cell.candidateSuspectIds.remove(id);
      } else {
        cell.candidateSuspectIds.add(id);
      }
      return true;
    }
    
    return false;
  }

  Set<String> getCandidates(int row, int col) => cells[row][col].candidateSuspectIds;

  bool hasCandidate(int row, int col, String suspectId) =>
      cells[row][col].candidateSuspectIds.contains(suspectId);
}
