import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/clues/models/clue_type.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_quality_evaluator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/clues/models/object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/placed_object_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/models/solution_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';

void main() {
  group('PuzzleSimulator & Determinación Exacta Tests', () {
    const simulator = PuzzleSimulator();
    const evaluator = PuzzleQualityEvaluator();
    final solver = PuzzleSolver();

    test('Test 1: Caso donde un personaje tiene candidatos > 1 debe marcar solved == false y stuck == true', () {
      final caseData = CaseRegistry.cases[0]; // DemoCase001
      // Pasamos un subconjunto insuficiente de pistas
      final result = simulator.simulate(caseData, [caseData.clues.first]);

      expect(result.solved, isFalse);
      expect(result.stuck, isTrue);
      expect(result.requiresGuessing, isTrue);
      expect(result.domainSizes.values.any((count) => count > 1), isTrue);
    });

    test('Test 2: Caso con unicidad matemática pero candidatos > 1 humanos es rechazado por QualityEvaluator', () {
      final caseData = CaseRegistry.cases[0];
      // Si eliminamos pistas hasta que sea ambiguo para un humano
      final result = simulator.simulate(caseData, [caseData.clues.first]);
      expect(result.solved, isFalse);

      final score = evaluator.evaluate(caseData, [caseData.clues.first]);
      expect(score, equals(0), reason: 'Score debe ser 0 para casos ambiguos');
      expect(evaluator.isAcceptable(caseData, [caseData.clues.first]), isFalse);
    });

    test('Test 3: Caso completamente determinado (DemoCase001 con todas sus pistas) tiene 1 candidato por entidad y aprueba', () {
      final caseData = CaseRegistry.cases[0];
      final result = simulator.simulate(caseData, caseData.clues);

      expect(result.solved, isTrue);
      expect(result.stuck, isFalse);
      expect(result.requiresGuessing, isFalse);
      expect(result.killerDeductionUnique, isTrue);
      for (final entry in result.domainSizes.entries) {
        expect(entry.value, equals(1), reason: 'Entidad ${entry.key} debe tener exactamente 1 celda candidata');
      }
    });

    test('Test 4: Víctima ambigua (más de 1 candidato) es rechazada', () {
      const suspectA = SuspectData(id: 's1', name: 'Carlos');
      const victim = SuspectData(id: 'victim', name: 'Víctima');

      final caseData = CaseData(
        id: 'test_ambiguous_victim',
        title: 'Test',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        zones: const [
          ZoneData(id: 'z1', cells: [CellPosition(0, 0), CellPosition(0, 1)]),
          ZoneData(id: 'z2', cells: [CellPosition(1, 0), CellPosition(1, 1), CellPosition(2, 0), CellPosition(2, 1), CellPosition(0, 2), CellPosition(1, 2), CellPosition(2, 2)]),
        ],
        suspects: const [suspectA, victim],
        victimId: 'victim',
        killerId: 's1',
        placedObjects: const [],
        clues: const [
          SpatialClueData(
            id: 'c1',
            text: 'Carlos en zona 1',
            relation: SpatialRelation.inZone,
            suspectId: 's1',
            targetId: 'z1',
            type: ClueType.zone,
          ),
        ],
        solution: const SolutionData(suspectPositions: {
          's1': CellPosition(0, 0),
          'victim': CellPosition(0, 1),
        }),
      );

      final result = simulator.simulate(caseData, caseData.clues);
      expect(result.domainSizes['victim'] != 1, isTrue);
      expect(result.solved, isFalse);
    });

    test('Test 5: Asesino ambiguo (2 o más sospechosos en la zona de la víctima) es rechazado', () {
      const s1 = SuspectData(id: 's1', name: 'Carlos');
      const s2 = SuspectData(id: 's2', name: 'Ana');
      const victim = SuspectData(id: 'victim', name: 'Víctima');

      final caseData = CaseData(
        id: 'test_ambiguous_killer',
        title: 'Test',
        description: 'Test',
        difficulty: PuzzleDifficulty.easy,
        boardRows: 3,
        boardColumns: 3,
        zones: const [
          // Una sola zona gigante para todo el tablero
          ZoneData(id: 'z1', cells: [
            CellPosition(0, 0), CellPosition(0, 1), CellPosition(0, 2),
            CellPosition(1, 0), CellPosition(1, 1), CellPosition(1, 2),
            CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2),
          ]),
        ],
        suspects: const [s1, s2, victim],
        victimId: 'victim',
        killerId: 's1',
        placedObjects: const [],
        clues: const [],
        solution: const SolutionData(suspectPositions: {
          's1': CellPosition(0, 0),
          's2': CellPosition(1, 1),
          'victim': CellPosition(2, 2),
        }),
      );

      final result = simulator.simulate(caseData, caseData.clues);
      expect(result.killerDeductionUnique, isFalse);
      expect(result.solved, isFalse);
    });

    test('Test 6: Lote de casos generados proceduralmente garantiza solución única y candidateCount == 1 para cada entidad', () {
      final generator = PuzzleGenerator(solver: solver);

      for (int i = 0; i < 5; i++) {
        final config = GeneratorConfig(
          rows: 4,
          columns: 4,
          suspectCount: 3,
          objectCount: 2,
          targetDifficulty: DifficultyLevel.easy,
          maxAttempts: 100,
        );

        final result = generator.generate(config);
        expect(result, isNotNull, reason: 'El generador debe producir un caso válido');

        final caseData = result!.caseData;

        // 1. Unicidad técnica matemática
        final solverResult = solver.solve(caseData, maxSolutions: 2);
        expect(solverResult.solutionCount, equals(1));

        // 2. Determinación humana con cero grados de libertad
        final simResult = simulator.simulate(caseData, caseData.clues);
        expect(simResult.solved, isTrue, reason: 'Caso ${caseData.id} debe ser humanamente resoluble sin guessing');
        expect(simResult.stuck, isFalse);
        expect(simResult.killerDeductionUnique, isTrue);

        for (final entry in simResult.domainSizes.entries) {
          expect(entry.value, equals(1), reason: 'Entidad ${entry.key} debe tener exactamente 1 celda candidata en caso ${caseData.id}');
        }
      }
    });

    test('Test 7 (Regresión Crítica): El caso roto reportado (María 2 candidatos, Sofía 2, Diego 3, Víctima 4) es estrictamente RECHAZADO por CaseIntegrityValidator y Simulator', () {
      const maria = SuspectData(id: 'suspect_maria', name: 'María');
      const sofia = SuspectData(id: 'suspect_sofia', name: 'Sofía');
      const diego = SuspectData(id: 'suspect_diego', name: 'Diego');
      const victim = SuspectData(id: 'victim', name: 'Víctima');

      const silla = ObjectData(id: 'obj_silla', name: 'Silla');
      const cama = ObjectData(id: 'obj_cama', name: 'Cama');

      final brokenCase = CaseData(
        id: 'broken_case_regression',
        title: 'Caso Roto Reportado',
        description: 'Caso con personajes ambiguos',
        difficulty: PuzzleDifficulty.medium,
        boardRows: 5,
        boardColumns: 5,
        zones: const [
          ZoneData(id: 'z_lotos', name: 'Estanque de Lotos', cells: [CellPosition(1, 1), CellPosition(1, 2)]),
          ZoneData(id: 'z_rosaleda', name: 'Rosaleda Victoriana', cells: [CellPosition(0, 0), CellPosition(0, 1)]),
          ZoneData(id: 'z_tropical', name: 'Pabellón Tropical', cells: [CellPosition(3, 2), CellPosition(4, 2), CellPosition(4, 3), CellPosition(4, 4)]),
          ZoneData(id: 'z_mansion', name: 'Mansión', cells: [
            CellPosition(0, 2), CellPosition(0, 3), CellPosition(0, 4),
            CellPosition(1, 0), CellPosition(1, 3), CellPosition(1, 4),
            CellPosition(2, 0), CellPosition(2, 1), CellPosition(2, 2), CellPosition(2, 3), CellPosition(2, 4),
            CellPosition(3, 0), CellPosition(3, 1), CellPosition(3, 3), CellPosition(3, 4),
            CellPosition(4, 0), CellPosition(4, 1),
          ]),
        ],
        suspects: const [maria, sofia, diego, victim],
        victimId: 'victim',
        killerId: 'suspect_diego',
        placedObjects: const [
          PlacedObjectData(object: silla, position: CellPosition(1, 4)),
          PlacedObjectData(object: cama, position: CellPosition(3, 4)),
        ],
        clues: const [
          SpatialClueData(
            id: 'c1',
            text: 'María en el Estanque de Lotos',
            relation: SpatialRelation.inZone,
            suspectId: 'suspect_maria',
            targetId: 'z_lotos',
            type: ClueType.zone,
          ),
          SpatialClueData(
            id: 'c2',
            text: 'María no estaba junto a la Silla',
            relation: SpatialRelation.notAdjacentTo,
            suspectId: 'suspect_maria',
            targetId: 'obj_silla',
            type: ClueType.adjacency,
          ),
          SpatialClueData(
            id: 'c3',
            text: 'Sofía en la Rosaleda Victoriana',
            relation: SpatialRelation.inZone,
            suspectId: 'suspect_sofia',
            targetId: 'z_rosaleda',
            type: ClueType.zone,
          ),
          SpatialClueData(
            id: 'c4',
            text: 'Sofía al norte de María',
            relation: SpatialRelation.above,
            suspectId: 'suspect_sofia',
            targetId: 'suspect_maria',
            type: ClueType.cardinal,
          ),
          SpatialClueData(
            id: 'c5',
            text: 'Diego estaba junto a la Cama',
            relation: SpatialRelation.adjacentTo,
            suspectId: 'suspect_diego',
            targetId: 'obj_cama',
            type: ClueType.adjacency,
          ),
          SpatialClueData(
            id: 'c6',
            text: 'Víctima en el Pabellón Tropical',
            relation: SpatialRelation.inZone,
            suspectId: 'victim',
            targetId: 'z_tropical',
            type: ClueType.zone,
          ),
        ],
        solution: const SolutionData(suspectPositions: {
          'suspect_sofia': CellPosition(0, 0),
          'suspect_maria': CellPosition(1, 1),
          'suspect_diego': CellPosition(4, 4),
          'victim': CellPosition(3, 2),
        }),
      );

      final simResult = simulator.simulate(brokenCase, brokenCase.clues);

      // Verificar que el simulador detecta la ambigüedad humana
      expect(simResult.solved, isFalse, reason: 'El simulador no debe considerar resuelto un caso ambiguo');
      expect(simResult.stuck, isTrue);
      expect(simResult.requiresGuessing, isTrue);
      expect(simResult.domainSizes['suspect_maria'], greaterThanOrEqualTo(2));
      expect(simResult.domainSizes['suspect_sofia'], greaterThanOrEqualTo(2));
      expect(simResult.domainSizes['suspect_diego'], greaterThanOrEqualTo(2));
      expect(simResult.domainSizes['victim'], greaterThanOrEqualTo(2));

      // Verificar que el validador oficial y el evaluador de calidad RECHAZAN terminantemente el caso
      final validator = CaseIntegrityValidator();
      expect(validator.validate(brokenCase), isFalse, reason: 'CaseIntegrityValidator DEBE rechazar casos con grados de libertad');
      expect(evaluator.evaluate(brokenCase, brokenCase.clues), equals(0));
      expect(evaluator.isAcceptable(brokenCase, brokenCase.clues), isFalse);
    });
  });
}
