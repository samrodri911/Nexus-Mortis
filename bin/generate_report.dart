import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_quality_evaluator.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_simulator.dart';
import 'dart:io';

void main() async {
  final generator = PuzzleGenerator();
  final evaluator = PuzzleQualityEvaluator();
  final simulator = PuzzleSimulator();

  final log = StringBuffer();
  log.writeln('# REPORTE DE GENERACIÓN DE PUZZLES');
  
  // 1. Generar 30 casos
  final levels = [
    (DifficultyLevel.easy, 4, 4, 3, 2, 10),
    (DifficultyLevel.medium, 4, 4, 4, 3, 10),
    (DifficultyLevel.hard, 5, 5, 5, 4, 10),
  ];

  int totalAttempts = 0;
  int accepted = 0;
  
  log.writeln('## 30 CASOS ACEPTADOS');
  
  for (final level in levels) {
    final diff = level.$1;
    final rows = level.$2;
    final cols = level.$3;
    final suspects = level.$4;
    final objects = level.$5;
    final count = level.$6;
    
    log.writeln('\n### Nivel: ${diff.name}');
    
    for (int i = 0; i < count; i++) {
      final config = GeneratorConfig(
        rows: rows,
        columns: cols,
        suspectCount: suspects,
        objectCount: objects,
        targetDifficulty: diff,
        maxAttempts: 500, // Alto para asegurar que encuentra
      );
      
      final result = generator.generate(config);
      if (result == null) {
        log.writeln('- Caso $i falló (no se pudo generar en 500 intentos)');
        continue;
      }
      
      totalAttempts += result.statistics.attemptsUsed;
      accepted++;
      
      final caseData = result.caseData;
      final qScore = evaluator.evaluate(caseData, caseData.clues);
      final sim = simulator.simulate(caseData, caseData.clues);
      
      log.writeln('- Caso ${caseData.id}: Score=$qScore | Pistas=${caseData.clues.length} | Pasos=${sim.steps} | Unico=${!sim.stuck} | Intentos=${result.statistics.attemptsUsed}');
      
      if (diff == DifficultyLevel.easy && i == 0) {
        log.writeln('\n#### EJEMPLO COMPLETO (Paso a paso) - ${caseData.id}');
        log.writeln('**Zonas:**');
        for (final z in caseData.zones) {
          log.writeln(' - ${z.name}: ${z.cells.map((c) => "(${c.row},${c.col})").join(", ")}');
        }
        log.writeln('**Personajes:** ${caseData.suspects.map((s) => s.name).join(", ")}');
        log.writeln('**Objetos:** ${caseData.placedObjects.map((o) => "${o.object.name} en (${o.position.row},${o.position.col})").join(", ")}');
        log.writeln('**Pistas:**');
        for (final c in caseData.clues) {
          log.writeln(' - ${c.text}');
        }
        log.writeln('**Solución Real:**');
        for (final entry in caseData.solution.suspectPositions.entries) {
          log.writeln(' - $entry');
        }
        log.writeln('\n');
      }
    }
  }
  
  log.writeln('\n## ESTADÍSTICAS GLOBALES');
  log.writeln('Casos aceptados: $accepted');
  log.writeln('Intentos totales del generador (incluyendo rechazos): $totalAttempts');
  log.writeln('Tasa de rechazo (casos malos descartados): ${(totalAttempts - accepted)}');
  
  File('report.md').writeAsStringSync(log.toString());
}
