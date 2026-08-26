import 'dart:io';

void main() {
  final file = File('lib/features/case_selection/case_selection_page.dart');
  var content = file.readAsStringSync();
  
  // Replace the _startCase and _startProcedural bodies to start the game
  content = content.replaceAll(
    '''
  void _startCase(BuildContext context, CaseData caseData) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          progressionService: progressionService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
          caseToStart: caseData,
        ),
      ),
    );
  }

  void _startProcedural(BuildContext context) async {
    final nextCase = await proceduralCaseService.getNextCase();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          progressionService: progressionService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
          caseToStart: nextCase,
        ),
      ),
    );
  }

  void _resumePaused(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          progressionService: progressionService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ),
    );
  }
''',
    '''
  Future<void> _startCase(BuildContext context, CaseData caseData) async {
    if (!progressionService.isCaseUnlocked(caseData)) return;
    if (sessionService.hasActiveSession) return;
    await sessionService.startNewGame(caseData);
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

  Future<void> _startProcedural(BuildContext context) async {
    final nextCase = await proceduralCaseService.getNextCase();
    if (sessionService.hasActiveSession) return;
    await sessionService.startNewGame(nextCase);
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
'''
  );

  file.writeAsStringSync(content);
}
