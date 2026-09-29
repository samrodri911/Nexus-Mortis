import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_mortis/game/board/models/zone_visual_theme.dart';
import 'package:nexus_mortis/game/visual/models/room_archetype.dart';
import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';
import 'package:nexus_mortis/game/visual/services/room_archetype_resolver.dart';

void main() {
  group('RoomArchetype', () {
    test('all archetypes have at least one floor candidate', () {
      for (final archetype in RoomArchetype.values) {
        expect(archetype.floorCandidates, isNotEmpty,
            reason: '${archetype.name} has no floor candidates');
      }
    });

    test('floor candidates are valid TileType values', () {
      for (final archetype in RoomArchetype.values) {
        for (final tile in archetype.floorCandidates) {
          expect(TileType.values.contains(tile), isTrue);
        }
      }
    });

    test('fromRoomName covers all classicMansion rooms', () {
      final mansionRooms = ZoneTheme.classicMansion.availableZoneNames;
      for (final name in mansionRooms) {
        final archetype = RoomArchetype.fromRoomName(name);
        expect(archetype, isNotNull,
            reason: 'No archetype for "$name"');
      }
    });

    test('fromRoomName covers all theaterOpera rooms', () {
      final theaterRooms = ZoneTheme.theaterOpera.availableZoneNames;
      for (final name in theaterRooms) {
        final archetype = RoomArchetype.fromRoomName(name);
        expect(archetype, isNotNull,
            reason: 'No archetype for "$name"');
      }
    });

    test('fromRoomName covers all botanicalGarden rooms', () {
      final gardenRooms = ZoneTheme.botanicalGarden.availableZoneNames;
      for (final name in gardenRooms) {
        final archetype = RoomArchetype.fromRoomName(name);
        expect(archetype, isNotNull,
            reason: 'No archetype for "$name"');
      }
    });

    test('fromRoomName covers all museumArchive rooms', () {
      final museumRooms = ZoneTheme.museumArchive.availableZoneNames;
      for (final name in museumRooms) {
        final archetype = RoomArchetype.fromRoomName(name);
        expect(archetype, isNotNull,
            reason: 'No archetype for "$name"');
      }
    });
  });

  group('RoomArchetypeResolver', () {
    test('resolve covers all classicMansion rooms', () {
      for (final name in ZoneTheme.classicMansion.availableZoneNames) {
        final archetype = RoomArchetypeResolver.resolve(
            name, ZoneTheme.classicMansion);
        expect(archetype, isNotNull,
            reason: 'Resolver failed for "$name"');
      }
    });

    test('resolve covers all theaterOpera rooms', () {
      for (final name in ZoneTheme.theaterOpera.availableZoneNames) {
        final archetype = RoomArchetypeResolver.resolve(
            name, ZoneTheme.theaterOpera);
        expect(archetype, isNotNull,
            reason: 'Resolver failed for "$name"');
      }
    });

    test('resolve covers all botanicalGarden rooms', () {
      for (final name in ZoneTheme.botanicalGarden.availableZoneNames) {
        final archetype = RoomArchetypeResolver.resolve(
            name, ZoneTheme.botanicalGarden);
        expect(archetype, isNotNull,
            reason: 'Resolver failed for "$name"');
      }
    });

    test('resolve covers all museumArchive rooms', () {
      for (final name in ZoneTheme.museumArchive.availableZoneNames) {
        final archetype = RoomArchetypeResolver.resolve(
            name, ZoneTheme.museumArchive);
        expect(archetype, isNotNull,
            reason: 'Resolver failed for "$name"');
      }
    });

    test('kitchen rooms resolve to kitchen archetype', () {
      expect(
        RoomArchetypeResolver.resolve('Cocina', ZoneTheme.classicMansion),
        equals(RoomArchetype.kitchen),
      );
    });

    test('library rooms resolve to library archetype', () {
      expect(
        RoomArchetypeResolver.resolve('Biblioteca', ZoneTheme.classicMansion),
        equals(RoomArchetype.library),
      );
      expect(
        RoomArchetypeResolver.resolve('Despacho', ZoneTheme.classicMansion),
        equals(RoomArchetype.library),
      );
    });

    test('garden rooms resolve to garden archetype', () {
      expect(
        RoomArchetypeResolver.resolve('Rosaleda', ZoneTheme.botanicalGarden),
        equals(RoomArchetype.garden),
      );
      expect(
        RoomArchetypeResolver.resolve('Vivero', ZoneTheme.botanicalGarden),
        equals(RoomArchetype.garden),
      );
    });

    test('gallery rooms resolve to gallery archetype', () {
      expect(
        RoomArchetypeResolver.resolve(
            'Galería de Arte', ZoneTheme.museumArchive),
        equals(RoomArchetype.gallery),
      );
      expect(
        RoomArchetypeResolver.resolve(
            'Sala Egipcia', ZoneTheme.museumArchive),
        equals(RoomArchetype.gallery),
      );
    });

    test('unknown name falls back to lounge', () {
      expect(
        RoomArchetypeResolver.resolve('Desconocida'),
        equals(RoomArchetype.lounge),
      );
    });

    test('case insensitive matching works', () {
      // Resolver should handle lowercase
      expect(
        RoomArchetypeResolver.resolve('cocina'),
        equals(RoomArchetype.kitchen),
      );
    });
  });
}
