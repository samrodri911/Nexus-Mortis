import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/services/zone_geometry_builder.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';

void main() {
  group('ZoneGeometryBuilder Tests', () {
    const builder = ZoneGeometryBuilder();

    test('Tablero con una sola zona: Cero muros interiores y 4 muros exteriores continuos', () {
      final zoneAll = ZoneData(
        id: 'zone_all',
        name: 'Gran Salón',
        cells: [
          const CellPosition(0, 0),
          const CellPosition(0, 1),
          const CellPosition(1, 0),
          const CellPosition(1, 1),
        ],
      );

      final result = builder.build(
        rows: 2,
        columns: 2,
        zones: [zoneAll],
        boardWidth: 200,
        boardHeight: 200,
      );

      // Cero muros interiores entre celdas de la misma zona
      expect(result.rawInteriorEdges, isEmpty);
      expect(result.interiorWalls, isEmpty);

      // Borde exterior: 2 horizontales (top r=0, bottom r=2) + 2 verticales (left c=0, right c=2)
      expect(result.rawExteriorEdges.length, equals(8)); // 2 en top + 2 en bot + 2 en left + 2 en right
      expect(result.exteriorWalls.length, equals(4)); // 4 lados fusionados

      // Caminos de suelo y centroide
      expect(result.zoneFloorPaths.containsKey('zone_all'), isTrue);
      expect(result.zoneCentroids['zone_all'], equals(const Offset(100, 100)));
    });

    test('Dos zonas adyacentes: Exactamente 1 frontera continua compartida, cero duplicados', () {
      // 2x2: Fila 0 es zone_top, Fila 1 es zone_bottom
      final zoneTop = ZoneData(
        id: 'zone_top',
        cells: [const CellPosition(0, 0), const CellPosition(0, 1)],
      );
      final zoneBottom = ZoneData(
        id: 'zone_bottom',
        cells: [const CellPosition(1, 0), const CellPosition(1, 1)],
      );

      final result = builder.build(
        rows: 2,
        columns: 2,
        zones: [zoneTop, zoneBottom],
        boardWidth: 200,
        boardHeight: 200,
      );

      // Raw edges: 2 aristas horizontales en r=1 (c=0 y c=1)
      expect(result.rawInteriorEdges.length, equals(2));
      expect(result.rawInteriorEdges.every((e) => e.isHorizontal && e.index1 == 1), isTrue);

      // Muros fusionados: Debe haber exactamente 1 muro interior horizontal continuo de (0, 100) a (200, 100)
      expect(result.interiorWalls.length, equals(1));
      final wall = result.interiorWalls.first;
      expect(wall.isHorizontal, isTrue);
      expect(wall.start, equals(const Offset(0, 100)));
      expect(wall.end, equals(const Offset(200, 100)));
      expect(wall.length, equals(200));
      expect(wall.isExterior, isFalse);

      // Verificar que no hay aristas duplicadas
      final edgeSet = result.rawInteriorEdges.toSet();
      expect(edgeSet.length, equals(result.rawInteriorEdges.length));
    });

    test('Comprobar que las fronteras entre celdas de la misma zona NUNCA se dibujan', () {
      // 3x3: Zona izquierda (cols 0, 1) y zona derecha (col 2)
      final zoneLeft = ZoneData(
        id: 'zone_left',
        cells: [
          const CellPosition(0, 0), const CellPosition(0, 1),
          const CellPosition(1, 0), const CellPosition(1, 1),
          const CellPosition(2, 0), const CellPosition(2, 1),
        ],
      );
      final zoneRight = ZoneData(
        id: 'zone_right',
        cells: [
          const CellPosition(0, 2),
          const CellPosition(1, 2),
          const CellPosition(2, 2),
        ],
      );

      final result = builder.build(
        rows: 3,
        columns: 3,
        zones: [zoneLeft, zoneRight],
        boardWidth: 300,
        boardHeight: 300,
      );

      // Entre col 0 y col 1 pertenecen a la misma zona -> CERO muros verticales en c=1
      expect(result.rawInteriorEdges.any((e) => !e.isHorizontal && e.index2 == 1), isFalse);

      // Entre fila 0, 1, 2 en la zona izquierda -> CERO muros horizontales entre ellas
      expect(result.rawInteriorEdges.any((e) => e.isHorizontal && (e.index2 == 0 || e.index2 == 1)), isFalse);

      // Solo debe existir la frontera vertical en c=2 (entre col 1 y col 2)
      expect(result.interiorWalls.length, equals(1));
      final wall = result.interiorWalls.first;
      expect(wall.isHorizontal, isFalse);
      expect(wall.start, equals(const Offset(200, 0)));
      expect(wall.end, equals(const Offset(200, 300)));
    });

    test('Zona irregular en forma de L', () {
      // Cuadrícula 3x3:
      // Zona L: (0,0), (1,0), (2,0), (2,1), (2,2)
      // Zona Resto: (0,1), (0,2), (1,1), (1,2)
      final zoneL = ZoneData(
        id: 'zone_l',
        cells: [
          const CellPosition(0, 0),
          const CellPosition(1, 0),
          const CellPosition(2, 0),
          const CellPosition(2, 1),
          const CellPosition(2, 2),
        ],
      );
      final zoneRest = ZoneData(
        id: 'zone_rest',
        cells: [
          const CellPosition(0, 1),
          const CellPosition(0, 2),
          const CellPosition(1, 1),
          const CellPosition(1, 2),
        ],
      );

      final result = builder.build(
        rows: 3,
        columns: 3,
        zones: [zoneL, zoneRest],
        boardWidth: 300,
        boardHeight: 300,
      );

      // Debe haber exactamente dos segmentos de muro interior continuo:
      // 1. Vertical en c=1 desde y=0 a y=200
      // 2. Horizontal en r=2 desde x=100 a x=300
      expect(result.interiorWalls.length, equals(2));

      final vWall = result.interiorWalls.firstWhere((w) => !w.isHorizontal);
      expect(vWall.start, equals(const Offset(100, 0)));
      expect(vWall.end, equals(const Offset(100, 200)));

      final hWall = result.interiorWalls.firstWhere((w) => w.isHorizontal);
      expect(hWall.start, equals(const Offset(100, 200)));
      expect(hWall.end, equals(const Offset(300, 200)));

      // Las dos líneas se encuentran perfectamente en (100, 200) sin gaps
      expect(vWall.end, equals(hWall.start));
    });

    test('Zona irregular en forma de T', () {
      // Cuadrícula 3x3:
      // Zona T: Fila 0 completa (0,0), (0,1), (0,2) y columna 1 central (1,1), (2,1)
      // Zona Izq: (1,0), (2,0)
      // Zona Der: (1,2), (2,2)
      final zoneT = ZoneData(
        id: 'zone_t',
        cells: [
          const CellPosition(0, 0), const CellPosition(0, 1), const CellPosition(0, 2),
          const CellPosition(1, 1),
          const CellPosition(2, 1),
        ],
      );
      final zoneIzq = ZoneData(
        id: 'zone_izq',
        cells: [const CellPosition(1, 0), const CellPosition(2, 0)],
      );
      final zoneDer = ZoneData(
        id: 'zone_der',
        cells: [const CellPosition(1, 2), const CellPosition(2, 2)],
      );

      final result = builder.build(
        rows: 3,
        columns: 3,
        zones: [zoneT, zoneIzq, zoneDer],
        boardWidth: 300,
        boardHeight: 300,
      );

      // Verificar que no existan aristas duplicadas
      final edgeSet = result.rawInteriorEdges.toSet();
      expect(edgeSet.length, equals(result.rawInteriorEdges.length));

      // Muros interiores:
      // Horizontal r=1 en col 0 (entre (0,0) y (1,0))
      // Horizontal r=1 en col 2 (entre (0,2) y (1,2))
      // Vertical c=1 en filas 1 y 2 (entre col 0 y col 1)
      // Vertical c=2 en filas 1 y 2 (entre col 1 y col 2)
      expect(result.interiorWalls.length, equals(4));

      final vWall1 = result.interiorWalls.firstWhere((w) => !w.isHorizontal && w.start.dx == 100);
      expect(vWall1.start, equals(const Offset(100, 100)));
      expect(vWall1.end, equals(const Offset(100, 300)));

      final vWall2 = result.interiorWalls.firstWhere((w) => !w.isHorizontal && w.start.dx == 200);
      expect(vWall2.start, equals(const Offset(200, 100)));
      expect(vWall2.end, equals(const Offset(200, 300)));

      final hWall1 = result.interiorWalls.firstWhere((w) => w.isHorizontal && w.start.dx == 0);
      expect(hWall1.start, equals(const Offset(0, 100)));
      expect(hWall1.end, equals(const Offset(100, 100)));

      final hWall2 = result.interiorWalls.firstWhere((w) => w.isHorizontal && w.start.dx == 200);
      expect(hWall2.start, equals(const Offset(200, 100)));
      expect(hWall2.end, equals(const Offset(300, 100)));
    });

    test('Cuadrícula con 4 zonas en cuadrantes (2x2 de zonas)', () {
      // 4x4 cuadrícula:
      // Z1: (0..1, 0..1), Z2: (0..1, 2..3)
      // Z3: (2..3, 0..1), Z4: (2..3, 2..3)
      final z1 = ZoneData(id: 'z1', cells: [
        const CellPosition(0, 0), const CellPosition(0, 1),
        const CellPosition(1, 0), const CellPosition(1, 1),
      ]);
      final z2 = ZoneData(id: 'z2', cells: [
        const CellPosition(0, 2), const CellPosition(0, 3),
        const CellPosition(1, 2), const CellPosition(1, 3),
      ]);
      final z3 = ZoneData(id: 'z3', cells: [
        const CellPosition(2, 0), const CellPosition(2, 1),
        const CellPosition(3, 0), const CellPosition(3, 1),
      ]);
      final z4 = ZoneData(id: 'z4', cells: [
        const CellPosition(2, 2), const CellPosition(2, 3),
        const CellPosition(3, 2), const CellPosition(3, 3),
      ]);

      final result = builder.build(
        rows: 4,
        columns: 4,
        zones: [z1, z2, z3, z4],
        boardWidth: 400,
        boardHeight: 400,
      );

      // Cero duplicados en aristas
      expect(result.rawInteriorEdges.toSet().length, equals(result.rawInteriorEdges.length));

      // Muros interiores:
      // Muro horizontal en r=2 (separa z1/z2 de z3/z4)
      // Muro vertical en c=2 (separa z1/z3 de z2/z4)
      expect(result.interiorWalls.length, equals(4)); // 2 tramos horizontales + 2 tramos verticales (por diferente par de zonas)
      expect(result.interiorWalls.every((w) => w.length == 200), isTrue);
    });

    test('Zona de una sola celda (1x1) rodeada: Muros continuos en sus 4 lados', () {
      // 3x3 cuadrícula, celda central (1,1) es 'z_center', el resto es 'z_surround'
      final surroundCells = <CellPosition>[];
      for (var r = 0; r < 3; r++) {
        for (var c = 0; c < 3; c++) {
          if (r != 1 || c != 1) {
            surroundCells.add(CellPosition(r, c));
          }
        }
      }
      final zCenter = ZoneData(id: 'z_center', cells: [const CellPosition(1, 1)]);
      final zSurround = ZoneData(id: 'z_surround', cells: surroundCells);

      final result = builder.build(
        rows: 3,
        columns: 3,
        zones: [zCenter, zSurround],
        boardWidth: 300,
        boardHeight: 300,
      );

      // Debe haber exactamente 4 muros interiores alrededor de (1,1):
      // y=100 (x: 100..200), y=200 (x: 100..200), x=100 (y: 100..200), x=200 (y: 100..200)
      expect(result.interiorWalls.length, equals(4));
      expect(result.zoneVisualCenters.containsKey('z_center'), isTrue);
      // El centro visual de la celda central (1, 1) debe estar exactamente en (150, 150)
      expect(result.zoneVisualCenters['z_center'], equals(const Offset(150, 150)));
    });

    test('zoneVisualCenters en zona L evita celdas bloqueadas y cae dentro de la zona', () {
      // Zona L: (0,0), (1,0), (2,0), (2,1), (2,2)
      // Bloqueamos la celda (1,0)
      final zoneL = ZoneData(
        id: 'zone_l',
        cells: [
          const CellPosition(0, 0),
          const CellPosition(1, 0),
          const CellPosition(2, 0),
          const CellPosition(2, 1),
          const CellPosition(2, 2),
        ],
      );
      final zoneRest = ZoneData(
        id: 'zone_rest',
        cells: [
          const CellPosition(0, 1),
          const CellPosition(0, 2),
          const CellPosition(1, 1),
          const CellPosition(1, 2),
        ],
      );

      final result = builder.build(
        rows: 3,
        columns: 3,
        zones: [zoneL, zoneRest],
        boardWidth: 300,
        boardHeight: 300,
        blockedCells: {const CellPosition(1, 0)},
      );

      final center = result.zoneVisualCenters['zone_l']!;
      // Debe caer dentro del bounding box de alguna celda de zoneL que NO sea (1,0)
      final col = (center.dx / 100).floor();
      final row = (center.dy / 100).floor();
      final chosenPos = CellPosition(row, col);

      expect(zoneL.cells.contains(chosenPos), isTrue);
      expect(chosenPos, isNot(equals(const CellPosition(1, 0))));
    });
  });
}
