import 'dart:io';

void main() {
  final file = File('lib/features/case_selection/case_selection_page.dart');
  var content = file.readAsStringSync();
  
  // Add saveGameService to constructor
  content = content.replaceFirst(
    'required this.progressionService,',
    'required this.progressionService,\n    required this.saveGameService,'
  );
  content = content.replaceFirst(
    'final ProgressionService progressionService;',
    'final ProgressionService progressionService;\n  final SaveGameService saveGameService;'
  );

  // Fix _resumePaused to navigate to ResumeGamePage
  content = content.replaceFirst(
    '''
  Future<void> _resumePaused(BuildContext context) async {
    await sessionService.resumeGame();
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ),
    );
  }
''',
    '''
  Future<void> _resumePaused(BuildContext context) async {
    final activeState = sessionService.activeState;
    if (activeState == null) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResumeGamePage(
          saveState: activeState,
          progressionService: progressionService,
          saveGameService: saveGameService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ),
    );
  }
'''
  );

  // We need to import ResumeGamePage
  if (!content.contains("resume_game_page.dart")) {
    content = "import 'package:nexus_mortis/features/case_selection/resume_game_page.dart';\n" + content;
  }
  if (!content.contains("save_game_service.dart")) {
    content = "import 'package:nexus_mortis/game/save_state/save_game_service.dart';\n" + content;
  }

  file.writeAsStringSync(content);
}
