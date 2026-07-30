import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/home/clue_panel.dart';
import 'package:nexus_mortis/features/home/confirmation_panel.dart';
import 'package:nexus_mortis/features/home/suspect_panel.dart';
import 'package:nexus_mortis/features/home/tool_panel.dart';
import 'package:nexus_mortis/features/home/validation_debug_panel.dart';
import 'package:nexus_mortis/game/nexus_game.dart';
import 'package:nexus_mortis/game/progression/models/reward_data.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/features/hints/hint_panel.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/validation/models/validation_status.dart';

/// Página principal que integra el panel Flutter de sospechosos
/// con el canvas de Flame.
///
/// Flutter maneja: [SuspectPanel] (selección de sospechoso).
/// Flame maneja: [GameWidget] (tablero y tap en celdas).
///
/// La comunicación entre capas ocurre a través de [NexusGame.boardController],
/// que es un objeto Dart puro compartido por referencia.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.caseData,
    required this.progressionService,
    required this.saveGameService,
    required this.economyService,
    this.saveState,
  });

  final CaseData caseData;
  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;
  final ActiveGameState? saveState;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final NexusGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Instanciamos el juego con el caso inyectado y el posible saveState.
    _game = NexusGame(
      caseData: widget.caseData,
      saveState: widget.saveState,
    );

    // Escuchamos el evento de validación para otorgar la victoria.
    _game.puzzleStatus.addListener(_onPuzzleStatusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.puzzleStatus.removeListener(_onPuzzleStatusChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Autoguardado cuando la app pasa a inactiva o pausada.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.saveGameService.saveCurrentGame(
        widget.caseData.id,
        _game.boardController,
      );
    }
  }

  void _onPuzzleStatusChanged() {
    if (_game.puzzleStatus.value == ValidationStatus.solved) {
      widget.progressionService.completeCase(
        widget.caseData.id,
        const RewardData(coins: 100, stars: 1), // Valores dummy por ahora
      );
      
      // Limpiamos la partida guardada ya que el caso ha sido resuelto.
      widget.saveGameService.clearGame();
      
      // Opcional: mostrar un diálogo de victoria, etc.
      // Por ahora nos conformamos con que el servicio se actualice.
    }
  }

  @override
  Widget build(BuildContext context) {
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
              progressionService: widget.progressionService,
              boardController: _game.boardController,
              validationService: _game.validationService,
              caseData: widget.caseData,
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
