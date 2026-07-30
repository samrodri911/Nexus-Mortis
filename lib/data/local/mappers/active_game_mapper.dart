import 'dart:convert';

import 'package:nexus_mortis/data/local/models/active_game_entity.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/models/cell_snapshot.dart';

/// Convierte datos entre ActiveGameState (Dominio) y ActiveGameEntity (Isar).
class ActiveGameMapper {
  ActiveGameMapper._();

  static ActiveGameState toDomain(ActiveGameEntity entity) {
    final List<dynamic> decodedList = jsonDecode(entity.stateJson) as List<dynamic>;
    
    final cells = decodedList.map((dynamic item) {
      final map = item as Map<String, dynamic>;
      return CellSnapshot(
        row: map['row'] as int,
        col: map['col'] as int,
        candidateIds: List<String>.from(map['candidateIds'] as Iterable<dynamic>),
        confirmedSuspectId: map['confirmedSuspectId'] as String?,
        eliminated: map['eliminated'] as bool,
        autoEliminationSources: List<String>.from(map['autoEliminationSources'] as Iterable<dynamic>),
      );
    }).toList();

    return ActiveGameState(
      caseId: entity.caseId,
      cells: cells,
      savedAt: entity.savedAt,
    );
  }

  static ActiveGameEntity toEntity(ActiveGameState domain) {
    final List<Map<String, dynamic>> cellsMapList = domain.cells.map((cell) {
      return {
        'row': cell.row,
        'col': cell.col,
        'candidateIds': cell.candidateIds,
        'confirmedSuspectId': cell.confirmedSuspectId,
        'eliminated': cell.eliminated,
        'autoEliminationSources': cell.autoEliminationSources,
      };
    }).toList();

    final entity = ActiveGameEntity()
      ..id = 0
      ..caseId = domain.caseId
      ..stateJson = jsonEncode(cellsMapList)
      ..savedAt = domain.savedAt;

    return entity;
  }
}
