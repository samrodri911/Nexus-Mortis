import 'dart:io';

void main() {
  final file = File('test/game/generator/puzzle_generator_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("killerId: suspects.first,", "killerId: suspects.first.id,");
  
  content = content.replaceFirst(
'''        () => generator.generateSolution(
          rows: 2,
          columns: 2, // Solo caben 4 celdas en total
          suspects: suspects,
          objects: objects,
        ),''',
'''        () => generator.generateSolution(
          rows: 2,
          columns: 2,
          suspects: suspects,
          objects: objects,
          victimId: 'victim',
          killerId: suspects.first.id,
          zones: const [],
        ),'''
  );

  file.writeAsStringSync(content);
}
