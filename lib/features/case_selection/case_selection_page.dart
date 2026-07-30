import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/home/home_page.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
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
  });

  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;

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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: CaseRegistry.cases.length,
            itemBuilder: (context, index) {
              final caseData = CaseRegistry.cases[index];
              final isUnlocked = progressionService.isCaseUnlocked(caseData);
              final isCompleted = progressionService.isCaseCompleted(caseData.id);
              final caseProgress = progress.completedCases[caseData.id];

              return Card(
                color: isUnlocked ? const Color(0xFF2C2C34) : const Color(0xFF1A1A1F),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    caseData.title,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    isUnlocked ? caseData.description : 'Requiere resolver el caso anterior',
                    style: TextStyle(
                      color: isUnlocked ? Colors.white70 : Colors.white24,
                    ),
                  ),
                  trailing: _buildTrailing(isUnlocked, isCompleted, caseProgress?.starsEarned),
                  onTap: isUnlocked
                      ? () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => HomePage(
                                caseData: caseData,
                                progressionService: progressionService,
                                saveGameService: saveGameService,
                                economyService: economyService,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrailing(bool isUnlocked, bool isCompleted, int? starsEarned) {
    if (!isUnlocked) {
      return const Icon(Icons.lock, color: Colors.white24);
    }

    if (isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$starsEarned',
            style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.green),
        ],
      );
    }

    return const Icon(Icons.arrow_forward_ios, color: Colors.white54);
  }
}
