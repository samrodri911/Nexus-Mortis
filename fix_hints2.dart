import 'dart:io';

void main() {
  final file = File('test/game/hints/hint_economy_service_test.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("puzzle_solver.dart")) {
      content = "import 'package:nexus_mortis/game/solver/puzzle_solver.dart';\n" + content;
  }
  
  content = content.replaceFirst(
'''      validationService = ValidationService(
        solution: dummyCase.solution,
        clues: dummyCase.clues,
        objectPositions: { for (var obj in dummyCase.placedObjects) obj.object.id: obj.position },
      );''',
'''      validationService = ValidationService(
        solver: PuzzleSolver(),
      );'''
  );

  file.writeAsStringSync(content);
}
