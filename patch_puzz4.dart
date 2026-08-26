import 'dart:io';

void main() {
  final file = File('test/game/generator/puzzle_generator_test.dart');
  var content = file.readAsStringSync();
  
  // Revert the bad replacement
  content = content.replaceFirst(
'''      final objects = GeneratorCatalog.objects.take(1).toList();

      final result = generator.generateSolution(
      final allPos = [''',
'''      final objects = GeneratorCatalog.objects.take(1).toList();

      final result = generator.generateSolution(
        rows: 2,
        columns: 2,
        suspects: suspects,
        objects: objects,
        victimId: 'victim',
        killerId: suspects.first.id,
        zones: const [
          ZoneData(id: 'z1', name: 'Z1', cells: [
            CellPosition(0, 0), CellPosition(1, 1),
          ]),
          ZoneData(id: 'z2', name: 'Z2', cells: [
            CellPosition(0, 1), CellPosition(1, 0),
          ]),
        ],
      );

      expect(result.solution.suspectPositions.length, 2);
      expect(result.objectPositions.length, 1);
      
      final allPos = ['''
  );

  file.writeAsStringSync(content);
}
