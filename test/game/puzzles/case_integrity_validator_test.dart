import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';

void main() {
  group('CaseIntegrityValidator Tests', () {
    final validator = CaseIntegrityValidator();

    test('Valida exitosamente los 3 casos estáticos de la campaña', () {
      expect(validator.validate(demoCase001), isTrue);
      expect(validator.validate(demoCase002), isTrue);
      expect(validator.validate(demoCase003), isTrue);
    });

    test('Rechaza un caso si la víctima y el asesino no comparten zona', () {
      final badSolution = Map<String, CellPosition>.from(demoCase001.solution.suspectPositions);
      badSolution['suspect_carlos'] = const CellPosition(0, 0);

      final badCase = CaseData(
        id: demoCase001.id,
        title: demoCase001.title,
        description: demoCase001.description,
        difficulty: demoCase001.difficulty,
        boardRows: demoCase001.boardRows,
        boardColumns: demoCase001.boardColumns,
        zones: demoCase001.zones,
        suspects: demoCase001.suspects,
        victimId: demoCase001.victimId,
        killerId: demoCase001.killerId,
        placedObjects: demoCase001.placedObjects,
        clues: demoCase001.clues,
        solution: SolutionData(suspectPositions: badSolution),
      );

      expect(validator.validate(badCase), isFalse);
    });

    test('Rechaza un caso si un inocente comparte zona con la víctima', () {
      final badSolution = Map<String, CellPosition>.from(demoCase001.solution.suspectPositions);
      badSolution['suspect_ana'] = const CellPosition(4, 1);

      final badCase = CaseData(
        id: demoCase001.id,
        title: demoCase001.title,
        description: demoCase001.description,
        difficulty: demoCase001.difficulty,
        boardRows: demoCase001.boardRows,
        boardColumns: demoCase001.boardColumns,
        zones: demoCase001.zones,
        suspects: demoCase001.suspects,
        victimId: demoCase001.victimId,
        killerId: demoCase001.killerId,
        placedObjects: demoCase001.placedObjects,
        clues: demoCase001.clues,
        solution: SolutionData(suspectPositions: badSolution),
      );

      expect(validator.validate(badCase), isFalse);
    });
  });
}
