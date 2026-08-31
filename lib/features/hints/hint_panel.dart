import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/hints/models/hint_type.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

class HintPanel extends StatelessWidget {
  const HintPanel({
    super.key,
    required this.economyService,
    required this.progressionService,
    required this.boardController,
    required this.validationService,
    required this.caseData,
  });

  final HintEconomyService economyService;
  final ProgressionService progressionService;
  final BoardController boardController;
  final ValidationService validationService;
  final CaseData caseData;

  void _buyHint(BuildContext context, HintType type) {
    final state = boardController.exportPlayerState();
    final result = economyService.buyHint(type, caseData, state, validationService);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes suficientes monedas."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          title: Text(
            "Pista",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amber),
          ),
          content: Text(
            result.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Entendido", style: TextStyle(color: Colors.amber)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: progressionService.progressNotifier,
      builder: (context, progress, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${progress.coins}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _HintButton(
                    label: 'Soft',
                    cost: economyService.costs.soft,
                    onTap: () => _buyHint(context, HintType.soft),
                  ),
                  _HintButton(
                    label: 'Medium',
                    cost: economyService.costs.medium,
                    onTap: () => _buyHint(context, HintType.medium),
                  ),
                  _HintButton(
                    label: 'Reveal',
                    cost: economyService.costs.reveal,
                    onTap: () => _buyHint(context, HintType.reveal),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({
    required this.label,
    required this.cost,
    required this.onTap,
  });

  final String label;
  final int cost;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      backgroundColor: Colors.grey[800],
      side: const BorderSide(color: Colors.amber, width: 0.5),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.amber, fontSize: 12)),
          const SizedBox(width: 4),
          Row(children: [Text('$cost ', style: const TextStyle(fontSize: 12)), const Icon(Icons.monetization_on, color: Colors.amber, size: 14)])
        ],
      ),
      onPressed: onTap,
    );
  }
}
