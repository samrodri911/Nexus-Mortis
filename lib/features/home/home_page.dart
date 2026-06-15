import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/home/clue_panel.dart';
import 'package:nexus_mortis/features/home/suspect_panel.dart';
import 'package:nexus_mortis/features/home/tool_panel.dart';
import 'package:nexus_mortis/game/nexus_game.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';

/// Página principal que integra el panel Flutter de sospechosos
/// con el canvas de Flame.
///
/// Flutter maneja: [SuspectPanel] (selección de sospechoso).
/// Flame maneja: [GameWidget] (tablero y tap en celdas).
///
/// La comunicación entre capas ocurre a través de [NexusGame.boardController],
/// que es un objeto Dart puro compartido por referencia.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final NexusGame _game;

  @override
  void initState() {
    super.initState();
    // Inyectamos el caso demo al motor de juego.
    // En el futuro, este caso podría provenir de un Navigator o Provider.
    _game = NexusGame(demoCase001);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      body: SafeArea(
        child: Column(
          children: [
            SuspectPanel(controller: _game.boardController),
            ToolPanel(controller: _game.boardController),
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
