import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/features/home/home_page.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';

/// Pantalla intermedia para decidir si continuar o abandonar una partida en curso.
class ResumeGamePage extends StatelessWidget {
  const ResumeGamePage({
    super.key,
    required this.saveState,
    required this.progressionService,
    required this.saveGameService,
    required this.economyService,
    required this.proceduralCaseService,
  });

  final ActiveGameState saveState;
  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;
  final ProceduralCaseService proceduralCaseService;

  void _onContinue(BuildContext context, CaseData caseData) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(
          caseData: caseData,
          progressionService: progressionService,
          saveGameService: saveGameService,
          economyService: economyService,
          saveState: saveState,
        ),
      ),
    );
  }

  Future<void> _onAbandon(BuildContext context) async {
    await saveGameService.clearGame();
    if (!context.mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CaseSelectionPage(
          progressionService: progressionService,
          saveGameService: saveGameService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CaseData?>(
      future: Future.value(proceduralCaseService.getCaseById(
        saveState.caseId,
        metadata: saveState.proceduralMetadata,
      )),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final caseData = snapshot.data;
        if (caseData == null) {
          // Si el caso guardado ya no existe, limpiar y salir
          saveGameService.clearGame();
          // Retrasamos la navegación para evitar problemas con el build actual
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CaseSelectionPage(
                  progressionService: progressionService,
                  saveGameService: saveGameService,
                  economyService: economyService,
                  proceduralCaseService: proceduralCaseService,
                ),
              ),
            );
          });
          return const Scaffold(backgroundColor: Colors.black);
        }

    // Formatear la fecha
    final diff = DateTime.now().difference(saveState.savedAt);
    String timeAgo = '';
    if (diff.inDays > 0) {
      timeAgo = 'Hace ${diff.inDays} días';
    } else if (diff.inHours > 0) {
      timeAgo = 'Hace ${diff.inHours} horas';
    } else if (diff.inMinutes > 0) {
      timeAgo = 'Hace ${diff.inMinutes} minutos';
    } else {
      timeAgo = 'Hace unos instantes';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Continuar Investigación',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.amber),
              ),
              const SizedBox(height: 24),
              Text(
                'Caso: ${caseData.title}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Última sesión: $timeAgo',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => _onAbandon(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Abandonar'),
                  ),
                  ElevatedButton(
                    onPressed: () => _onContinue(context, caseData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Continuar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  },
);
  }
}
