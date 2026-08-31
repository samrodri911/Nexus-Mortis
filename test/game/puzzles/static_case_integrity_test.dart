import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/data/repositories/progress_repository.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';
import 'package:nexus_mortis/game/player/models/player_assignment.dart';
import 'package:nexus_mortis/game/player/models/player_board_state.dart';
import 'package:nexus_mortis/game/progression/models/case_progress.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/sources/static_case_source.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

class _FakeProgressRepo implements ProgressRepository {
  PlayerProgress? saved;
  @override
  Future<PlayerProgress> loadProgress() async => saved ?? PlayerProgress.empty();
  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    saved = progress;
  }
  @override
  Future<void> clearProgress() async {
    saved = null;
  }
}

void main() {
  group('CaseRegistry & StaticCaseSource Integrity', () {
    test('CaseRegistry contiene todos los casos de la campaña sin referencias rotas', () {
      expect(CaseRegistry.cases, hasLength(3));
      expect(CaseRegistry.cases[0].id, 'case_001');
      expect(CaseRegistry.cases[1].id, 'case_002');
      expect(CaseRegistry.cases[2].id, 'case_003');

      expect(CaseRegistry.getCase('case_001'), isNotNull);
      expect(CaseRegistry.getCase('case_002'), isNotNull);
      expect(CaseRegistry.getCase('case_003'), isNotNull);
      expect(CaseRegistry.getCase('non_existent'), isNull);
    });

    test('StaticCaseSource retorna todos los casos correctamente', () {
      const source = StaticCaseSource();
      expect(source.allCases, hasLength(3));
      expect(source.getCase('case_001'), equals(demoCase001));
      expect(source.getCase('case_002'), equals(demoCase002));
      expect(source.getCase('case_003'), equals(demoCase003));
    });
  });

  group('Static Cases Structural Integrity', () {
    final allCases = [demoCase001, demoCase002, demoCase003];

    for (final c in allCases) {
      test('Caso ${c.id} (${c.title}) cumple todas las validaciones de integridad estructural', () {
        expect(
          CaseIntegrityValidator().validate(c),
          isTrue, reason: 'El getter isValid debe retornar true');
        expect(c.boardRows, greaterThan(0));
        expect(c.boardColumns, greaterThan(0));
        expect(c.title.trim(), isNotEmpty);
        expect(c.description.trim(), isNotEmpty);

        // Sospechosos y víctimas
        expect(c.suspects, isNotEmpty);
        expect(c.suspects.any((s) => s.id == c.victimId), isTrue,
            reason: 'La víctima (${c.victimId}) debe ser parte de la lista de sospechosos investigables');
        expect(c.suspects.any((s) => s.id == c.killerId), isTrue,
            reason: 'El asesino (${c.killerId}) debe ser parte de la lista de sospechosos');
        expect(c.victimId, isNot(equals(c.killerId)),
            reason: 'La víctima y el asesino deben ser identidades distintas');

        // Zonas
        expect(c.zones, isNotEmpty);
        final coveredCells = <CellPosition>{};
        for (final zone in c.zones) {
          expect(zone.cells, isNotEmpty, reason: 'La zona ${zone.id} no puede estar vacía');
          for (final cell in zone.cells) {
            expect(cell.row, inInclusiveRange(0, c.boardRows - 1));
            expect(cell.col, inInclusiveRange(0, c.boardColumns - 1));
            final added = coveredCells.add(cell);
            expect(added, isTrue, reason: 'La celda $cell está superpuesta en múltiples zonas');
          }
        }
        expect(coveredCells.length, equals(c.boardRows * c.boardColumns),
            reason: 'Las zonas deben particionar exactamente la totalidad del tablero');

        // Objetos
        final objectPositions = <CellPosition>{};
        for (final placed in c.placedObjects) {
          expect(placed.position.row, inInclusiveRange(0, c.boardRows - 1));
          expect(placed.position.col, inInclusiveRange(0, c.boardColumns - 1));
          final added = objectPositions.add(placed.position);
          expect(added, isTrue, reason: 'Dos objetos ocupan la misma posición');
        }

        // Pistas
        expect(c.clues, isNotEmpty, reason: 'Un caso estático jugable debe incluir pistas');
        final allValidTargetIds = {
          ...c.suspects.map((s) => s.id),
          ...c.placedObjects.map((o) => o.object.id),
          ...c.zones.map((z) => z.id),
        };
        for (final clue in c.clues) {
          expect(c.suspects.any((s) => s.id == clue.suspectId), isTrue,
              reason: 'El suspectId ${clue.suspectId} en la pista ${clue.id} no existe en suspects');
          for (final constraint in clue.activeConstraints) {
            expect(allValidTargetIds.contains(constraint.targetId), isTrue,
                reason: 'El targetId ${constraint.targetId} en la pista ${clue.id} no existe en targets válidos');
          }
        }

        // Solución
        expect(c.solution.suspectPositions.length, equals(c.suspects.length),
            reason: 'La solución debe especificar la posición de todos los sospechosos y la víctima');
        for (final entry in c.solution.suspectPositions.entries) {
          expect(entry.value.row, inInclusiveRange(0, c.boardRows - 1));
          expect(entry.value.col, inInclusiveRange(0, c.boardColumns - 1));
          expect(objectPositions.contains(entry.value), isFalse,
              reason: 'La posición asignada en solución colisiona con un objeto fijo');
        }
      });
    }
  });

  group('Static Cases Mathematical Solver & Murdoku Rules', () {
    final solver = PuzzleSolver();
    final allCases = [demoCase001, demoCase002, demoCase003];

    for (final c in allCases) {
      test('Caso ${c.id} tiene exactamente 1 solución única que respeta Murdoku y regla del asesino', () {
        final result = solver.solve(c, maxSolutions: 5);

        expect(result.solutionCount, equals(1),
            reason: 'El caso ${c.id} debe ser determinista y tener exactamente 1 solución');
        expect(result.solutions, hasLength(1));

        final sol = result.solutions.first;

        // Verificar coincidencia exacta con la solución declarada
        for (final suspect in c.suspects) {
          expect(sol.suspectPositions[suspect.id], equals(c.solution.suspectPositions[suspect.id]),
              reason: 'La solución del solver para ${suspect.id} debe coincidir con c.solution');
        }

        // Murdoku: Filas y columnas únicas
        final usedRows = <int>{};
        final usedCols = <int>{};
        for (final pos in sol.suspectPositions.values) {
          expect(usedRows.add(pos.row), isTrue, reason: 'Regla Murdoku violada: dos personajes en fila ${pos.row}');
          expect(usedCols.add(pos.col), isTrue, reason: 'Regla Murdoku violada: dos personajes en columna ${pos.col}');
        }

        // Regla del Asesino y Zonas
        final zoneMap = <CellPosition, String>{};
        for (final z in c.zones) {
          for (final cell in z.cells) {
            zoneMap[cell] = z.id;
          }
        }

        final victimPos = sol.suspectPositions[c.victimId]!;
        final killerPos = sol.suspectPositions[c.killerId]!;
        final victimZone = zoneMap[victimPos];
        final killerZone = zoneMap[killerPos];

        expect(victimZone, isNotNull);
        expect(killerZone, isNotNull);
        expect(killerZone, equals(victimZone),
            reason: 'El asesino y la víctima DEBEN pertenecer a la misma zona');

        for (final suspect in c.suspects) {
          if (suspect.id == c.victimId || suspect.id == c.killerId) continue;
          final innocentPos = sol.suspectPositions[suspect.id]!;
          final innocentZone = zoneMap[innocentPos];
          expect(innocentZone, isNot(equals(victimZone)),
              reason: 'El inocente ${suspect.name} no puede estar en la zona de la víctima');
        }
      });
    }
  });

  group('ValidationService on Static Cases', () {
    const clueEvaluator = ClueEvaluator(SpatialClueEvaluator());
    final allCases = [demoCase001, demoCase002, demoCase003];

    for (final c in allCases) {
      test('ValidationService valida como SOLVED el tablero completo del caso ${c.id}', () {
        final validationService = ValidationService(
          caseData: c,
          clueEvaluator: clueEvaluator,
        );

        // Construir estado del tablero con solución correcta y celdas restantes descartadas con X
        final assignments = c.suspects.map((s) {
          return PlayerAssignment(
            suspectId: s.id,
            candidates: [c.solution.suspectPositions[s.id]!],
          );
        }).toList();

        final assignedPositions = c.solution.suspectPositions.values.toSet();
        final objectPositions = c.placedObjects.map((o) => o.position).toSet();
        final eliminatedCells = <CellPosition>{};

        for (int r = 0; r < c.boardRows; r++) {
          for (int col = 0; col < c.boardColumns; col++) {
            final pos = CellPosition(r, col);
            if (!assignedPositions.contains(pos) && !objectPositions.contains(pos)) {
              eliminatedCells.add(pos);
            }
          }
        }

        final playerBoardState = PlayerBoardState(
          assignments: assignments,
          eliminatedCells: eliminatedCells,
        );

        final valResult = validationService.validate(playerBoardState);
        expect(valResult.status, equals(ValidationStatus.readyForKiller));
        expect(validationService.validateKiller(c.killerId), isTrue);
        expect(valResult.unsatisfiedClues, equals(0));
        expect(valResult.satisfiedClues, equals(c.clues.length));
      });
    }
  });

  group('Campaign Progression Flow', () {
    test('Progresión de campaña desbloquea secuencialmente Caso 1 -> Caso 2 -> Caso 3', () {
      final repo = _FakeProgressRepo();
      final cases = CaseRegistry.cases;

      // 1. Sin progreso previo
      final service0 = ProgressionService(repo, initialProgress: PlayerProgress.empty());
      final next0 = service0.getNextCampaignCase(cases);
      expect(next0, isNotNull);
      expect(next0!.id, equals('case_001'));

      // 2. Completado Caso 1
      final p1 = PlayerProgress(
        coins: 10,
        totalStars: 3,
        completedCases: {
          'case_001': const CaseProgress(caseId: 'case_001', completed: true, starsEarned: 3),
        },
      );
      final service1 = ProgressionService(repo, initialProgress: p1);
      final next1 = service1.getNextCampaignCase(cases);
      expect(next1, isNotNull);
      expect(next1!.id, equals('case_002'));

      // 3. Completado Caso 2
      final p2 = PlayerProgress(
        coins: 20,
        totalStars: 6,
        completedCases: {
          'case_001': const CaseProgress(caseId: 'case_001', completed: true, starsEarned: 3),
          'case_002': const CaseProgress(caseId: 'case_002', completed: true, starsEarned: 3),
        },
      );
      final service2 = ProgressionService(repo, initialProgress: p2);
      final next2 = service2.getNextCampaignCase(cases);
      expect(next2, isNotNull);
      expect(next2!.id, equals('case_003'));

      // 4. Completada toda la campaña
      final p3 = PlayerProgress(
        coins: 30,
        totalStars: 9,
        completedCases: {
          'case_001': const CaseProgress(caseId: 'case_001', completed: true, starsEarned: 3),
          'case_002': const CaseProgress(caseId: 'case_002', completed: true, starsEarned: 3),
          'case_003': const CaseProgress(caseId: 'case_003', completed: true, starsEarned: 3),
        },
      );
      final service3 = ProgressionService(repo, initialProgress: p3);
      final next3 = service3.getNextCampaignCase(cases);
      expect(next3, isNull, reason: 'Al completar la campaña se activa el modo procedural infinito');
    });
  });
}
