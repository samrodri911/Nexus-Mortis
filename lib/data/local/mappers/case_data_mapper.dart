import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/puzzles/models/board_rule_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_origin.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

/// Mapper de serialización y deserialización fiel e inmutable para CaseData.
class CaseDataMapper {
  CaseDataMapper._();

  static Map<String, dynamic> toJson(CaseData data) {
    return {
      'id': data.id,
      'title': data.title,
      'description': data.description,
      'difficulty': data.difficulty.name,
      'boardRows': data.boardRows,
      'boardColumns': data.boardColumns,
      'zones': data.zones.map((z) => {
        'id': z.id,
        'name': z.name,
        'cells': z.cells.map((c) => {'row': c.row, 'col': c.col}).toList(),
      }).toList(),
      'suspects': data.suspects.map((s) => {
        'id': s.id,
        'name': s.name,
      }).toList(),
      'victimId': data.victimId,
      'killerId': data.killerId,
      'placedObjects': data.placedObjects.map((po) => {
        'object': {
          'id': po.object.id,
          'name': po.object.name,
        },
        'position': {'row': po.position.row, 'col': po.position.col},
      }).toList(),
      'clues': data.clues.map((c) => c.toJson()).toList(),
      'globalRules': data.globalRules.map((r) => r.toJson()).toList(),
      'solution': {
        'suspectPositions': data.solution.suspectPositions.map(
          (key, val) => MapEntry(key, {'row': val.row, 'col': val.col}),
        ),
      },
      'requiredCaseId': data.requiredCaseId,
      'origin': data.origin.name,
    };
  }

  static CaseData fromJson(Map<String, dynamic> json) {
    final difficultyName = json['difficulty'] as String;
    final difficulty = PuzzleDifficulty.values.firstWhere(
      (e) => e.name == difficultyName,
      orElse: () => PuzzleDifficulty.medium,
    );

    final originName = json['origin'] as String?;
    final origin = originName != null
        ? CaseOrigin.values.firstWhere(
            (e) => e.name == originName,
            orElse: () => CaseOrigin.campaign,
          )
        : CaseOrigin.campaign;

    final rawZones = json['zones'] as List<dynamic>? ?? [];
    final zones = rawZones.map((dynamic z) {
      final zMap = z as Map<String, dynamic>;
      final rawCells = zMap['cells'] as List<dynamic>? ?? [];
      final cells = rawCells.map((dynamic c) {
        final cMap = c as Map<String, dynamic>;
        return CellPosition(cMap['row'] as int, cMap['col'] as int);
      }).toList();
      return ZoneData(
        id: zMap['id'] as String,
        name: zMap['name'] as String? ?? zMap['id'] as String,
        cells: cells,
      );
    }).toList();

    final rawSuspects = json['suspects'] as List<dynamic>? ?? [];
    final suspects = rawSuspects.map((dynamic s) {
      final sMap = s as Map<String, dynamic>;
      return SuspectData(
        id: sMap['id'] as String,
        name: sMap['name'] as String,
      );
    }).toList();

    final rawObjects = json['placedObjects'] as List<dynamic>? ?? [];
    final placedObjects = rawObjects.map((dynamic po) {
      final poMap = po as Map<String, dynamic>;
      final objMap = poMap['object'] as Map<String, dynamic>;
      final posMap = poMap['position'] as Map<String, dynamic>;
      return PlacedObjectData(
        object: ObjectData(
          id: objMap['id'] as String,
          name: objMap['name'] as String,
        ),
        position: CellPosition(posMap['row'] as int, posMap['col'] as int),
      );
    }).toList();

    final rawClues = json['clues'] as List<dynamic>? ?? [];
    final clues = rawClues.map((dynamic c) {
      return SpatialClueData.fromJson(c as Map<String, dynamic>);
    }).toList();

    final rawRules = json['globalRules'] as List<dynamic>? ?? [];
    final globalRules = rawRules.map((dynamic r) {
      return BoardRuleData.fromJson(r as Map<String, dynamic>);
    }).toList();

    final solMap = json['solution'] as Map<String, dynamic>? ?? {};
    final rawPositions = solMap['suspectPositions'] as Map<String, dynamic>? ?? {};
    final suspectPositions = rawPositions.map((key, dynamic val) {
      final pMap = val as Map<String, dynamic>;
      return MapEntry(key, CellPosition(pMap['row'] as int, pMap['col'] as int));
    });

    return CaseData(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: difficulty,
      boardRows: json['boardRows'] as int,
      boardColumns: json['boardColumns'] as int,
      zones: zones,
      suspects: suspects,
      victimId: json['victimId'] as String,
      killerId: json['killerId'] as String,
      placedObjects: placedObjects,
      clues: clues,
      globalRules: globalRules,
      solution: SolutionData(suspectPositions: suspectPositions),
      requiredCaseId: json['requiredCaseId'] as String?,
      origin: origin,
    );
  }
}
