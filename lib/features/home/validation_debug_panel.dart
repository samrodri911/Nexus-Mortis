import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

/// Panel temporal de depuración que muestra las métricas de validación.
/// Se actualiza reactivamente via [ValueListenableBuilder] sin polling.
class ValidationDebugPanel extends StatelessWidget {
  const ValidationDebugPanel({
    super.key,
    required this.controller,
    required this.validationService,
  });

  final BoardController controller;
  final ValidationService validationService;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.version,
      builder: (context, _, _) {
        final state = controller.exportPlayerState();
        final result = validationService.validate(state);

        return Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '--- DEBUG VALIDATION ---',
                style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text('Estado: ${result.status.name}',
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              Text(
                  'Pistas satisfechas: ${result.satisfiedClues}/${result.totalClues}',
                  style: const TextStyle(color: Colors.green, fontSize: 12)),
              Text('Pistas desconocidas: ${result.unknownClues}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Pistas incumplidas: ${result.unsatisfiedClues}',
                  style:
                      const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
