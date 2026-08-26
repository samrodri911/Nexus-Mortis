import 'dart:io';

void main() {
  final files = [
    'test/features/case_selection/case_selection_page_test.dart',
    'test/game/achievements/achievement_service_test.dart',
    'test/game/difficulty/difficulty_analyzer_test.dart',
    'test/game/puzzles/procedural_case_service_test.dart',
    'test/game/session/game_session_service_test.dart',
    'test/game/solver/puzzle_solver_test.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    
    if (!content.contains('victimId:')) {
      content = content.replaceAll(
        'placedObjects:', 
        'victimId: \'dummy1\', killerId: \'dummy2\', zones: const [], placedObjects:'
      );
      file.writeAsStringSync(content);
      print('Patched $path');
    }
  }
}
