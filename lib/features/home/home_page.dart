import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/features/hints/hint_panel.dart';
import 'package:nexus_mortis/features/home/clue_panel.dart';
import 'package:nexus_mortis/features/home/confirmation_panel.dart';
import 'package:nexus_mortis/features/home/suspect_panel.dart';
import 'package:nexus_mortis/features/home/tool_panel.dart';
import 'package:nexus_mortis/features/home/validation_debug_panel.dart';
import 'package:nexus_mortis/features/results/results_page.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/nexus_game.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Página principal que integra los paneles Flutter con el canvas de Flame.
///
/// La página delega todo el ciclo de vida de la partida a [GameSessionService].
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.sessionService,
    required this.economyService,
    required this.proceduralCaseService,
  });

  final GameSessionService sessionService;
  final HintEconomyService economyService;
  final ProceduralCaseService proceduralCaseService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final NexusGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final caseData = widget.sessionService.currentCase!;
    final saveState = widget.sessionService.activeState;

    // Instanciamos el juego con el caso y el saveState desde la sesión
    _game = NexusGame(
      caseData: caseData,
      saveState: saveState,
    );

    // Registramos el controlador en el servicio de sesión
    widget.sessionService.registerController(_game.boardController);

    // Escuchamos el evento de validación para notificar la resolución del caso
    _game.puzzleStatus.addListener(_onPuzzleStatusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.puzzleStatus.removeListener(_onPuzzleStatusChanged);
    widget.sessionService.unregisterController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Delegar pausar y autoguardar al servicio de sesión
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.sessionService.pauseGame();
    }
  }

  Future<void> _onPuzzleStatusChanged() async {
    if (_game.puzzleStatus.value == ValidationStatus.solved) {
      final result = await widget.sessionService.completeGame();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultsPage(
            result: result,
            unlockedAchievements: widget.sessionService.lastUnlockedAchievements,
            onContinue: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CaseSelectionPage(
                    progressionService: widget.sessionService.progressionService,
                    saveGameService: widget.sessionService.saveGameService,
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
  }

  @override
  Widget build(BuildContext context) {
    final currentCase = widget.sessionService.currentCase!;

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      body: SafeArea(
        child: Column(
          children: [
            ValidationDebugPanel(
              controller: _game.boardController,
              validationService: _game.validationService,
            ),
            HintPanel(
              economyService: widget.economyService,
              progressionService: widget.sessionService.progressionService,
              boardController: _game.boardController,
              validationService: _game.validationService,
              caseData: currentCase,
            ),
            SuspectPanel(controller: _game.boardController),
            ToolPanel(controller: _game.boardController),
            ConfirmationPanel(controller: _game.boardController),
            Expanded(
              child: GameWidget<NexusGame>(game: _game),
            ),
            CluePanel(controller: _game.boardController),
          ],
        ),
      ),
    );
  }
}
