import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/case_selection/case_selection_page.dart';
import 'package:nexus_mortis/features/hints/hint_panel.dart';
import 'package:nexus_mortis/features/home/clue_panel.dart';
import 'package:nexus_mortis/features/home/confirmation_panel.dart';
import 'package:nexus_mortis/features/home/suspect_panel.dart';
import 'package:nexus_mortis/features/home/tool_panel.dart';
import 'package:nexus_mortis/features/results/results_page.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/nexus_game.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Página principal que integra los paneles Flutter con el canvas de Flame.
///
/// La página delega todo el ciclo de vida de la partida a [GameSessionService].
///
/// Flujo de salida unificado:
/// - Botón de salida en UI → [_exitGame]
/// - Botón físico de Android → [PopScope] → [_exitGame]
/// - App en background → [didChangeAppLifecycleState] → [pauseGame] (sin navegación)
///
/// El guard [_isExiting] garantiza que la navegación de salida ocurra exactamente una vez.
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

  /// Guard que evita doble navegación al salir.
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final caseData = widget.sessionService.currentCase!;
    final saveState = widget.sessionService.activeState;

    _game = NexusGame(
      caseData: caseData,
      saveState: saveState,
    );

    widget.sessionService.registerController(_game.boardController);
    
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    widget.sessionService.unregisterController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausa y guarda si la app pasa a segundo plano.
    // No navega: ese es rol exclusivo de _exitGame.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      widget.sessionService.pauseGame();
    }
  }

  /// Flujo único de salida del juego.
  ///
  /// Pausa y guarda la partida (idempotente), luego navega al selector de casos.
  /// El guard [_isExiting] garantiza que la navegación ocurra solo una vez,
  /// incluso si el botón de salida y el gesto de Android se activan al mismo tiempo.
  Future<void> _exitGame() async {
    if (_isExiting) return;
    _isExiting = true;

    await widget.sessionService.pauseGame();

    if (!mounted) return;

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
  }

  /// Guard que evita doble navegación a los resultados.
  bool _isNavigatingToResults = false;

  Future<void> _submitSolution() async {
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
            unlockedAchievements: widget.sessionService.lastUnlockedAchievements,
            onContinue: (resultsContext) {
              Navigator.of(resultsContext).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => CaseSelectionPage(
                    progressionService:
                        widget.sessionService.progressionService,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitGame();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121214),
        body: SafeArea(
          child: Column(
            children: [
              // Barra superior con botón de salida
              _TopBar(
                caseTitle: currentCase.title,
                onExit: _exitGame,
                onSubmit: _submitSolution,
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
      ),
    );
  }
}

/// Barra superior minimalista de la pantalla de juego.
///
/// Muestra el título del caso y un botón de salida/pausa.
/// Reemplaza al [ValidationDebugPanel] que solo tenía valor de debug.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.caseTitle,
    required this.onExit,
    required this.onSubmit,
  });

  final String caseTitle;
  final VoidCallback onExit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1E1E24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
            tooltip: 'Pausar y salir',
            onPressed: onExit,
          ),
          Expanded(
            child: Text(
              caseTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: onSubmit,
            style: TextButton.styleFrom(
              foregroundColor: Colors.amber,
            ),
            child: const Text('Resolver', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
