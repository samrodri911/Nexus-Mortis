import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/services/board_layout_metrics.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';
import 'package:nexus_mortis/game/generator/models/generator_config.dart';
import 'package:nexus_mortis/game/generator/services/puzzle_generator.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

void main() {
  test('Auditoría Visual Completa: 4x4, 5x4, 5x5, 6x5 — Geometría, Alfombras y Sets Temáticos', () {
    final puzzleGen = PuzzleGenerator();
    const geomBuilder = ZoneGeometryBuilder();

    final testDimensions = [
      (rows: 4, cols: 4, name: '4x4 Pequeño'),
      (rows: 4, cols: 5, name: '5x4 / 4x5 Mediano'),
      (rows: 5, cols: 5, name: '5x5 Cuadrado'),
      (rows: 5, cols: 6, name: '6x5 / 5x6 Grande'),
    ];

    int totalCasesEvaluated = 0;
    int totalRugsRendered = 0;
    int casesWithZeroRugs = 0;
    int casesWithOneRug = 0;
    int casesWithTwoRugs = 0;

    final themeCounts = <ZoneTheme, int>{
      for (final t in ZoneTheme.values) t: 0,
    };

    for (final dim in testDimensions) {
      for (int i = 0; i < 5; i++) {
        final seed = 7000 + (dim.rows * 100) + (dim.cols * 10) + i;
        final config = GeneratorConfig(
          rows: dim.rows,
          columns: dim.cols,
          suspectCount: (dim.rows >= 5) ? 4 : 3,
          objectCount: (dim.rows >= 5) ? 3 : 2,
          randomSeed: seed,
          targetDifficulty: DifficultyLevel.easy,
          maxAttempts: 25,
        );

        final result = puzzleGen.generate(config);
        if (result == null) continue;

        totalCasesEvaluated++;
        final puzzle = result.caseData;
        final theme = puzzle.zoneTheme!;
        themeCounts[theme] = (themeCounts[theme] ?? 0) + 1;

        // 1. Verificación Temática: Todas las zonas pertenecen al set cerrado
        final allowedRooms = theme.availableZoneNames.toSet();
        for (final zone in puzzle.zones) {
          expect(allowedRooms.contains(zone.name), isTrue,
              reason: 'Habitación "${zone.name}" no pertenece al tema ${theme.name}');
        }

        // 2. Cálculo geométrico con métricas reales
        final metrics = BoardLayoutMetrics.calculate(
          availableWidth: 360.0,
          availableHeight: 360.0,
          rows: dim.rows,
          cols: dim.cols,
        );

        final blocked = <CellPosition>{};
        for (final po in puzzle.placedObjects) {
          blocked.add(po.position);
        }

        final geom = geomBuilder.build(
          rows: dim.rows,
          columns: dim.cols,
          zones: puzzle.zones,
          boardWidth: metrics.boardWidth,
          boardHeight: metrics.boardHeight,
          blockedCells: blocked,
          theme: theme,
        );

        // 3. Verificación de Nombres de Zona
        for (final zone in puzzle.zones) {
          final center = geom.zoneVisualCenters[zone.id];
          expect(center, isNotNull);

          // Debe estar dentro del polígono de la habitación
          final path = geom.zoneFloorPaths[zone.id]!;
          expect(path.contains(center!), isTrue,
              reason: 'El centro visual de ${zone.name} debe estar dentro de su habitación');

          // Si la habitación tiene celdas libres, no debe estar en una celda bloqueada
          final freeCells = zone.cells.where((c) => !blocked.contains(c)).toList();
          if (freeCells.isNotEmpty) {
            // Comprobar a qué celda pertenece center
            final col = (center.dx / geom.cellWidth).floor();
            final row = (center.dy / geom.cellHeight).floor();
            expect(blocked.contains(CellPosition(row, col)), isFalse,
                reason: 'El texto de ${zone.name} no debe posicionarse sobre una celda con mueble');
          }
        }

        // 4. Verificación Estricta de Alfombras
        final rugs = geom.zoneRugRects;
        final rugCount = rugs.length;
        totalRugsRendered += rugCount;

        if (rugCount == 0) casesWithZeroRugs++;
        if (rugCount == 1) casesWithOneRug++;
        if (rugCount == 2) casesWithTwoRugs++;

        final isLargeMap = (dim.rows * dim.cols) >= 25;
        if (isLargeMap) {
          expect(rugCount, lessThanOrEqualTo(2),
              reason: 'Mapas grandes pueden tener como máximo 2 alfombras');
        } else {
          expect(rugCount, lessThanOrEqualTo(1),
              reason: 'Mapas normales pueden tener como máximo 1 alfombra');
        }

        for (final entry in rugs.entries) {
          final zoneId = entry.key;
          final rugRect = entry.value;
          final zone = puzzle.zones.firstWhere((z) => z.id == zoneId);

          // Debe ser un rectángulo simple
          int minR = zone.cells.first.row, maxR = zone.cells.first.row;
          int minC = zone.cells.first.col, maxC = zone.cells.first.col;
          for (final c in zone.cells) {
            if (c.row < minR) minR = c.row;
            if (c.row > maxR) maxR = c.row;
            if (c.col < minC) minC = c.col;
            if (c.col > maxC) maxC = c.col;
          }
          final wCells = maxC - minC + 1;
          final hCells = maxR - minR + 1;

          expect(zone.cells.length, equals(wCells * hCells),
              reason: 'La alfombra solo puede estar en habitaciones rectangulares simples (no L ni T)');
          expect(wCells, greaterThanOrEqualTo(2));
          expect(hCells, greaterThanOrEqualTo(2));

          // Debe tener padding respecto a los muros de la habitación
          final roomLeft = minC * geom.cellWidth;
          final roomTop = minR * geom.cellHeight;
          final roomRight = (maxC + 1) * geom.cellWidth;
          final roomBottom = (maxR + 1) * geom.cellHeight;

          expect(rugRect.left, greaterThanOrEqualTo(roomLeft + 4.0));
          expect(rugRect.top, greaterThanOrEqualTo(roomTop + 4.0));
          expect(rugRect.right, lessThanOrEqualTo(roomRight - 4.0));
          expect(rugRect.bottom, lessThanOrEqualTo(roomBottom - 4.0));

          // Ninguna celda cubierta por la alfombra puede tener mueble
          for (final b in blocked) {
            final bLeft = b.col * geom.cellWidth;
            final bTop = b.row * geom.cellHeight;
            final bRight = (b.col + 1) * geom.cellWidth;
            final bBottom = (b.row + 1) * geom.cellHeight;
            // Si la celda bloqueada está dentro de la habitación, la alfombra no puede solaparla
            final cellRect = ui.Rect.fromLTRB(bLeft, bTop, bRight, bBottom);
            expect(rugRect.overlaps(cellRect), isFalse,
                reason: 'La alfombra nunca debe solapar un mueble en ($b.row, $b.col)');
          }
        }
      }
    }

    // ignore: avoid_print
    print('''
═══════════════════════════════════════════════════════════════════════════════
AUDITORÍA VISUAL INTEGRAL NEXUS MORTIS V3.4 (4x4, 5x4, 5x5, 6x5)
═══════════════════════════════════════════════════════════════════════════════
Casos Auditados: $totalCasesEvaluated
Distribución de Temas:
  - Mansión Clásica: ${themeCounts[ZoneTheme.classicMansion]}
  - Teatro / Ópera: ${themeCounts[ZoneTheme.theaterOpera]}
  - Jardín Botánico: ${themeCounts[ZoneTheme.botanicalGarden]}
  - Museo / Archivo: ${themeCounts[ZoneTheme.museumArchive]}
Frecuencia de Alfombras:
  - Casos con 0 alfombras (habitaciones irregulares o sin 2x2 libre): $casesWithZeroRugs
  - Casos con 1 alfombra de acento: $casesWithOneRug
  - Casos con 2 alfombras (mapas grandes): $casesWithTwoRugs
  - Total Alfombras Dibujadas: $totalRugsRendered
Todas las verificaciones geométricas, de muros, muebles y texto superadas con éxito.
═══════════════════════════════════════════════════════════════════════════════
''');
  });
}
