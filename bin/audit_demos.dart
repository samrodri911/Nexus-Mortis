import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/clues/models/spatial_relation.dart';
import 'package:nexus_mortis/game/puzzles/validation/case_integrity_validator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'package:nexus_mortis/game/solver/puzzle_solver.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

void main() {
  final validator = CaseIntegrityValidator(
    solver: PuzzleSolver(),
    simulator: const PuzzleSimulator(),
  );

  final cases = [
    demoCase001,
    demoCase002,
    demoCase003,
  ];

  for (final c in cases) {
    print('\n========================================');
    print('AUDITANDO CASO: ${c.id} - ${c.title}');
    print('========================================');

    print('Validando integridad...');
    final result = validator.validateDetailed(c);
    print('  isValid: ${result.isValid}');
    if (!result.isValid) {
      print('  Rechazo: ${result.rejectionReason?.name} - ${result.details}');
    }
    
    print('\n1. ZONAS');
    for (final z in c.zones) {
      print('  ${z.id} (${z.name}): ${z.cells.length} celdas');
    }
    
    print('\n2. OBJETOS FIJOS');
    for (final o in c.placedObjects) {
      print('  ${o.object.id} en (${o.position.row}, ${o.position.col})');
    }
    
    print('\n3. GROUND TRUTH (SOLUCION)');
    final killerPos = c.solution.suspectPositions[c.killerId]!;
    final victimPos = c.solution.suspectPositions[c.victimId]!;
    print('  Víctima: (${victimPos.row}, ${victimPos.col}) en zona ${_getZone(c, victimPos)}');
    print('  Asesino (${c.killerId}): (${killerPos.row}, ${killerPos.col}) en zona ${_getZone(c, killerPos)}');
    
    for (final s in c.suspects) {
      if (s.id == c.victimId || s.id == c.killerId) continue;
      final pos = c.solution.suspectPositions[s.id]!;
      print('  Sospechoso ${s.id}: (${pos.row}, ${pos.col}) en zona ${_getZone(c, pos)}');
    }
    
    print('\n4. PISTAS Y DIRECCIONES');
    for (final clue in c.clues) {
      if (clue.suspectId == c.victimId) continue;
      print('  ${clue.suspectId}: "${clue.text}"');
      final subjPos = c.solution.suspectPositions[clue.suspectId]!;
      for (final constraint in clue.activeConstraints) {
        if (constraint.relation == SpatialRelation.inZone) continue;
        final targetPos = _getTargetPos(c, constraint.targetId);
        if (targetPos != null) {
          print('    Validando ${constraint.relation.name} de ${constraint.targetId}(${targetPos.row},${targetPos.col}) -> Sujeto en (${subjPos.row},${subjPos.col})');
        }
      }
    }
  }
}

String _getZone(CaseData c, var pos) {
  for (final z in c.zones) {
    if (z.cells.contains(pos)) return z.id;
  }
  return 'Ninguna';
}

dynamic _getTargetPos(CaseData c, String targetId) {
  for (final o in c.placedObjects) {
    if (o.object.id == targetId) return o.position;
  }
  for (final entry in c.solution.suspectPositions.entries) {
    if (entry.key == targetId) return entry.value;
  }
  return null;
}
