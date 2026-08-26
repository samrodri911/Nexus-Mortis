import 'dart:io';

void main() {
  final file = File('lib/features/home/home_page.dart');
  var content = file.readAsStringSync();
  
  // Remove listener
  content = content.replaceFirst(
    '_game.puzzleStatus.addListener(_onPuzzleStatusChanged);',
    ''
  );
  content = content.replaceFirst(
    '_game.puzzleStatus.removeListener(_onPuzzleStatusChanged);',
    ''
  );
  
  // Replace _onPuzzleStatusChanged with _submitSolution
  content = content.replaceFirst(
'''  Future<void> _onPuzzleStatusChanged() async {
    if (_game.puzzleStatus.value == ValidationStatus.solved) {
      if (_isNavigatingToResults) return;
      _isNavigatingToResults = true;

      final result = await widget.sessionService.completeGame();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            result: result,
            unlockedAchievements: widget.sessionService.achievementsUnlockedThisSession,
            onContinue: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CaseSelectionPage(
                    progressionService: widget.sessionService.progressionService,
                    saveGameService: widget.saveGameService,
                    economyService: widget.economyService,
                    proceduralCaseService: widget.proceduralCaseService,
                    sessionService: widget.sessionService,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }''',
'''  Future<void> _submitSolution() async {
    final state = _game.boardController.exportPlayerState();
    final status = _game.validationService.validate(state).status;

    if (status == ValidationStatus.incomplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El tablero está incompleto. Debes llenar o descartar todas las celdas.')),
      );
      return;
    } else if (status == ValidationStatus.invalid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hay contradicciones en tu deducción. Revisa las pistas.')),
      );
      return;
    }

    if (status == ValidationStatus.solved) {
      if (_isNavigatingToResults) return;
      _isNavigatingToResults = true;

      final result = await widget.sessionService.completeGame();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            result: result,
            unlockedAchievements: widget.sessionService.achievementsUnlockedThisSession,
            onContinue: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CaseSelectionPage(
                    progressionService: widget.sessionService.progressionService,
                    saveGameService: widget.saveGameService,
                    economyService: widget.economyService,
                    proceduralCaseService: widget.proceduralCaseService,
                    sessionService: widget.sessionService,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }'''
  );
  
  // Add button to _TopBar
  content = content.replaceFirst(
'''              _TopBar(
                caseTitle: currentCase.title,
                onExit: _exitGame,
              ),''',
'''              _TopBar(
                caseTitle: currentCase.title,
                onExit: _exitGame,
                onSubmit: _submitSolution,
              ),'''
  );

  content = content.replaceFirst(
'''class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.caseTitle,
    required this.onExit,
  });

  final String caseTitle;
  final VoidCallback onExit;''',
'''class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.caseTitle,
    required this.onExit,
    required this.onSubmit,
  });

  final String caseTitle;
  final VoidCallback onExit;
  final VoidCallback onSubmit;'''
  );

  content = content.replaceFirst(
'''          // Placeholder para simetría visual
          const SizedBox(width: 48),''',
'''          TextButton(
            onPressed: onSubmit,
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
            ),
            child: const Text('Resolver', style: TextStyle(fontWeight: FontWeight.bold)),
          ),'''
  );

  file.writeAsStringSync(content);
}
