import 'dart:io';

void main() {
  final file = File('test/game/hints/hint_economy_service_test.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst(
'''      validationService = ValidationService(
        solution: dummyCase.solution,
      );''',
'''      validationService = ValidationService(
        solver: PuzzleSolver(),
      );'''
  );

  file.writeAsStringSync(content);
}
