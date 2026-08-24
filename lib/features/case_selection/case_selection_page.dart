import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/home/home_page.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';

/// Pantalla inicial donde el jugador selecciona el caso a jugar.
/// Muestra los casos bloqueados y desbloqueados según el [ProgressionService].
class CaseSelectionPage extends StatelessWidget {
  const CaseSelectionPage({
    super.key,
    required this.progressionService,
    required this.saveGameService,
    required this.economyService,
    required this.proceduralCaseService,
  });

  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;
  final ProceduralCaseService proceduralCaseService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Mortis - Archivos'),
        backgroundColor: const Color(0xFF1E1E24),
      ),
      body: ValueListenableBuilder<PlayerProgress>(
        valueListenable: progressionService.progressNotifier,
        builder: (context, progress, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, size: 80, color: Colors.amber),
                const SizedBox(height: 24),
                Text(
                  'Archivos Completados: ${progress.completedCases.length}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monedas: ${progress.coins}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.amber),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () async {
                    // Mostrar un loader
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final nextCase = await proceduralCaseService.getNextCase();
                    
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // Ocultar loader

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          caseData: nextCase,
                          progressionService: progressionService,
                          saveGameService: saveGameService,
                          economyService: economyService,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('INVESTIGAR SIGUIENTE CASO'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
