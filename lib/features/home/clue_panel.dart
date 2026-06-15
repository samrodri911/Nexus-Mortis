import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';

/// Panel que muestra la lista de pistas activas para el caso actual.
///
/// Es puramente visual, por ahora no interactúa con el tablero.
class CluePanel extends StatelessWidget {
  const CluePanel({super.key, required this.controller});

  final BoardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120, // Altura fija simple para mantener el diseño responsivo
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF161620),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pistas del Escenario:',
            style: TextStyle(
              color: Color(0xFFB0B0C0),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: controller.clues.length,
              itemBuilder: (context, index) {
                final clue = controller.clues[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: Color(0xFF7070A0), fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          clue.text,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
