import 'dart:io';

void main() {
  final file = File('test/game/generator/puzzle_generator_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
'''        () => generator.generateSolution(
          rows: 2,
          columns: 2, // Solo caben 4 celdas en total
          suspects: suspects,
          objects: objects,
        ),''', 
'''        () => generator.generateSolution(
          rows: 2,
          columns: 2, // Solo caben 4 celdas en total
          suspects: suspects,
          objects: objects,
          victimId: 'victim',
          killerId: suspects.first,
          zones: const [],
        ),'''
  );
  
  // Also fix the unexpected type issue in spread operator:
  // result.solution.suspectPositions.values -> result.solution.suspectPositions.values.toList() if necessary?
  // Wait, Dart 3 can spread iterables natively.
  
  file.writeAsStringSync(content);
}
