import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/nexus_game.dart';

/// The primary page widget hosting the gameplay board viewport.
///
/// It acts as the bridge between the Flutter-based UI layer and the Flame engine view.
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
    _game = NexusGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GameWidget<NexusGame>(
          game: _game,
        ),
      ),
    );
  }
}
