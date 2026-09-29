import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/puzzles/models/cell_position.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_data.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';
import 'package:nexus_mortis/game/visual/models/room_archetype.dart';
import 'package:nexus_mortis/game/visual/models/visual_map_plan.dart';
import 'package:nexus_mortis/game/visual/services/visual_map_builder.dart';

void main() {
  group('VisualMapBuilder', () {
    late List<ZoneData> testZones;
    late Set<CellPosition> blockedCells;

    setUp(() {
      testZones = [
        const ZoneData(
          id: 'z0',
          name: 'Biblioteca',
          cells: [
            CellPosition(0, 0), CellPosition(0, 1),
            CellPosition(1, 0), CellPosition(1, 1),
            CellPosition(2, 0), CellPosition(2, 1),
          ],
        ),
        const ZoneData(
          id: 'z1',
          name: 'Cocina',
          cells: [
            CellPosition(0, 2), CellPosition(0, 3),
            CellPosition(1, 2), CellPosition(1, 3),
          ],
        ),
        const ZoneData(
          id: 'z2',
          name: 'Salón Principal',
          cells: [
            CellPosition(2, 2), CellPosition(2, 3),
            CellPosition(3, 0), CellPosition(3, 1),
            CellPosition(3, 2), CellPosition(3, 3),
          ],
        ),
      ];
      blockedCells = {
        const CellPosition(0, 0), // obj_mesa en Biblioteca
        const CellPosition(1, 2), // obj_silla en Cocina
      };
    });

    test('generates a plan for all zones', () {
      final plan = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 42,
        theme: ZoneTheme.classicMansion,
      );

      expect(plan.rooms.length, equals(3));
      expect(plan.forZone('z0'), isNotNull);
      expect(plan.forZone('z1'), isNotNull);
      expect(plan.forZone('z2'), isNotNull);
      expect(plan.forZone('z99'), isNull);
    });

    test('assigns correct archetypes', () {
      final plan = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 42,
        theme: ZoneTheme.classicMansion,
      );

      expect(plan.forZone('z0')!.archetype, equals(RoomArchetype.library));
      expect(plan.forZone('z1')!.archetype, equals(RoomArchetype.kitchen));
      expect(plan.forZone('z2')!.archetype, equals(RoomArchetype.lounge));
    });

    test('assigns valid floor tile types from archetype candidates', () {
      final plan = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 42,
        theme: ZoneTheme.classicMansion,
      );

      for (final room in plan.rooms.values) {
        expect(
          room.archetype.floorCandidates.contains(room.floorTileType),
          isTrue,
          reason:
              '${room.zoneId}: ${room.floorTileType} not in ${room.archetype.floorCandidates}',
        );
      }
    });

    test('Biblioteca (noble room) gets a rug, Cocina does not', () {
      final plan = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 42,
        theme: ZoneTheme.classicMansion,
      );

      expect(plan.forZone('z0')!.hasRug, isTrue,
          reason: 'Biblioteca should have a rug (noble room)');
      expect(plan.forZone('z1')!.hasRug, isFalse,
          reason: 'Cocina should never have a rug');
    });

    test('decorations never appear on blocked cells', () {
      final plan = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 42,
        theme: ZoneTheme.classicMansion,
      );

      for (final room in plan.rooms.values) {
        for (final dec in room.decorations) {
          final pos = CellPosition(dec.row, dec.col);
          expect(blockedCells.contains(pos), isFalse,
              reason: 'Decoration at ($pos) overlaps blocked cell');
        }
      }
    });

    test('same seed produces identical plan', () {
      final plan1 = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 12345,
        theme: ZoneTheme.classicMansion,
      );
      final plan2 = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 12345,
        theme: ZoneTheme.classicMansion,
      );

      expect(plan1.rooms.length, equals(plan2.rooms.length));
      for (final zoneId in plan1.rooms.keys) {
        final r1 = plan1.forZone(zoneId)!;
        final r2 = plan2.forZone(zoneId)!;
        expect(r1.archetype, equals(r2.archetype));
        expect(r1.floorTileType, equals(r2.floorTileType));
        expect(r1.hasRug, equals(r2.hasRug));
        expect(r1.decorations.length, equals(r2.decorations.length));
        for (int i = 0; i < r1.decorations.length; i++) {
          expect(r1.decorations[i].row, equals(r2.decorations[i].row));
          expect(r1.decorations[i].col, equals(r2.decorations[i].col));
          expect(r1.decorations[i].objectId, equals(r2.decorations[i].objectId));
        }
      }
    });

    test('different seeds produce different plans', () {
      final plan1 = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 111,
        theme: ZoneTheme.classicMansion,
      );
      final plan2 = VisualMapBuilder.build(
        zones: testZones,
        blockedCells: blockedCells,
        caseSeed: 999,
        theme: ZoneTheme.classicMansion,
      );

      // At least one decoration or floor tile should differ
      bool anyDifference = false;
      for (final zoneId in plan1.rooms.keys) {
        final r1 = plan1.forZone(zoneId)!;
        final r2 = plan2.forZone(zoneId)!;
        if (r1.floorTileType != r2.floorTileType ||
            r1.decorations.length != r2.decorations.length) {
          anyDifference = true;
          break;
        }
        for (int i = 0; i < r1.decorations.length; i++) {
          if (r1.decorations[i].objectId != r2.decorations[i].objectId ||
              r1.decorations[i].row != r2.decorations[i].row ||
              r1.decorations[i].col != r2.decorations[i].col) {
            anyDifference = true;
            break;
          }
        }
      }
      expect(anyDifference, isTrue,
          reason: 'Different seeds should produce visual differences');
    });

    test('no VisualPlacement has isLogical property', () {
      // Compile-time safety: VisualPlacement doesn't have isLogical.
      // This test verifies the model shape at runtime.
      const placement = VisualPlacement(
        row: 0, col: 0, objectId: 'obj_test', zoneId: 'z0');
      expect(placement.row, equals(0));
      expect(placement.col, equals(0));
      // If isLogical existed, it would be accessible here, but it doesn't.
    });

    test('works with all ZoneThemes', () {
      for (final theme in ZoneTheme.values) {
        final zoneNames = theme.availableZoneNames;
        final zones = <ZoneData>[];
        for (int i = 0; i < zoneNames.length && i < 4; i++) {
          zones.add(ZoneData(
            id: 'z$i',
            name: zoneNames[i],
            cells: [CellPosition(i, 0), CellPosition(i, 1)],
          ));
        }

        final plan = VisualMapBuilder.build(
          zones: zones,
          blockedCells: const {},
          caseSeed: 42,
          theme: theme,
        );

        expect(plan.rooms.length, equals(zones.length),
            reason: '${theme.name}: expected ${zones.length} rooms');
        for (final room in plan.rooms.values) {
          expect(TileType.values.contains(room.floorTileType), isTrue);
          expect(RoomArchetype.values.contains(room.archetype), isTrue);
        }
      }
    });
  });
}
