import 'package:flutter/material.dart';
import 'package:nexus_mortis/data/local/isar_active_game_repository.dart';
import 'package:nexus_mortis/data/local/isar_database.dart';
import 'package:nexus_mortis/data/local/isar_progress_repository.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/features/case_selection/resume_game_page.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_service.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/clues/evaluators/clue_evaluator.dart';
import 'package:nexus_mortis/game/clues/evaluators/spatial_clue_evaluator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar la persistencia (Isar)
  final isar = await IsarDatabase.open();

  // Inicializar repositorios
  final progressRepository = IsarProgressRepository(isar);
  final activeGameRepository = IsarActiveGameRepository(isar);

  // Inicializar servicios
  final initialProgress = await progressRepository.loadProgress();
  final progressionService = ProgressionService(
    progressRepository,
    initialProgress: initialProgress,
  );
  
  final saveGameService = SaveGameService(activeGameRepository);
  final activeGameState = await saveGameService.loadGame();

  final hintService = HintService(clueEvaluator: const ClueEvaluator(SpatialClueEvaluator()));
  final economyService = HintEconomyService(
    progressionService: progressionService,
    hintService: hintService,
  );

  runApp(NexusMortisApp(
    progressionService: progressionService,
    saveGameService: saveGameService,
    economyService: economyService,
    activeGameState: activeGameState,
  ));
}

/// The root widget of the Nexus Mortis application.
class NexusMortisApp extends StatelessWidget {
  const NexusMortisApp({
    super.key,
    required this.progressionService,
    required this.saveGameService,
    required this.economyService,
    this.activeGameState,
  });

  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;
  final ActiveGameState? activeGameState;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexus Mortis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121214),
      ),
      home: activeGameState != null
          ? ResumeGamePage(
              saveState: activeGameState!,
              progressionService: progressionService,
              saveGameService: saveGameService,
              economyService: economyService,
            )
          : CaseSelectionPage(
              progressionService: progressionService,
              saveGameService: saveGameService,
              economyService: economyService,
            ),
    );
  }
}
