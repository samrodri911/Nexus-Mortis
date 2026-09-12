import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/hints/models/hint_type.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/validation/validation_service.dart';

class HintPanel extends StatefulWidget {
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

  @override
  State<HintPanel> createState() => _HintPanelState();
}

class _HintPanelState extends State<HintPanel> {
  bool _isExpanded = false;

  void _buyHint(BuildContext context, HintType type) {
    final state = widget.boardController.exportPlayerState();
    final result = widget.economyService.buyHint(
      type,
      widget.caseData,
      state,
      widget.validationService,
    );

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No tienes suficientes monedas."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Al adquirir una pista con éxito, colapsamos el panel para devolver la atención al tablero
    setState(() {
      _isExpanded = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF8A6D24), width: 1.2),
          ),
          title: const Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Color(0xFFFFD700), size: 22),
              SizedBox(width: 8),
              Text(
                "Informe del Informador",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            result.message,
            style: const TextStyle(color: Color(0xFFE2E2F0), fontSize: 14, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Entendido",
                style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.progressionService.progressNotifier,
      builder: (context, progress, _) {
        final currentHeight = _isExpanded ? 122.0 : 38.0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          width: double.infinity,
          height: currentHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF14141E),
            border: Border(
              bottom: BorderSide(
                color: _isExpanded ? const Color(0xFF384460) : const Color(0xFF28283C),
                width: 1.5,
              ),
            ),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(90),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera compacta táctil (Estado COLLAPSED / toggle)
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    color: _isExpanded ? const Color(0xFF1A1A28) : const Color(0xFF14141E),
                    child: Row(
                      children: [
                        // Saldo de monedas del jugador
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF231F10),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8A6D24),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.monetization_on_rounded,
                                color: Color(0xFFFFD700),
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${progress.coins}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Color(0xFFFFD700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Título de la sección
                        const Text(
                          'AYUDAS',
                          style: TextStyle(
                            color: Color(0xFFE2E2F0),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isExpanded ? 'Toca para ocultar' : 'Consultar opciones',
                          style: TextStyle(
                            color: Colors.white.withAlpha(120),
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: const Color(0xFFFFD700),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                // Opciones de ayuda expandidas con lo que cuestan
                if (_isExpanded)
                  Container(
                    height: 84,
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HintOptionCard(
                            icon: Icons.lightbulb_outline_rounded,
                            title: 'Suave',
                            description: 'Sugerencia sutil',
                            cost: widget.economyService.costs.soft,
                            playerCoins: progress.coins,
                            onTap: () => _buyHint(context, HintType.soft),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HintOptionCard(
                            icon: Icons.search_rounded,
                            title: 'Media',
                            description: 'Evalúa marcas',
                            cost: widget.economyService.costs.medium,
                            playerCoins: progress.coins,
                            onTap: () => _buyHint(context, HintType.medium),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _HintOptionCard(
                            icon: Icons.visibility_outlined,
                            title: 'Revelar',
                            description: 'Ubicación clave',
                            cost: widget.economyService.costs.reveal,
                            playerCoins: progress.coins,
                            onTap: () => _buyHint(context, HintType.reveal),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HintOptionCard extends StatelessWidget {
  const _HintOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.cost,
    required this.playerCoins,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final int cost;
  final int playerCoins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canAfford = playerCoins >= cost;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            color: canAfford ? const Color(0xFF1E1E2E) : const Color(0xFF181822),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: canAfford
                  ? const Color(0xFF8A6D24).withAlpha(160)
                  : const Color(0xFF333344),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 13,
                    color: canAfford ? const Color(0xFFFFD700) : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: canAfford ? const Color(0xFFE2E2F0) : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: canAfford ? const Color(0xFF90CAF9) : Colors.grey[600],
                  fontSize: 9.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: canAfford ? const Color(0xFF2C2412) : const Color(0xFF222228),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: canAfford
                        ? const Color(0xFFFFD700).withAlpha(180)
                        : Colors.grey[700]!,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$cost',
                      style: TextStyle(
                        color: canAfford ? const Color(0xFFFFD700) : Colors.grey[500],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.monetization_on_rounded,
                      color: canAfford ? const Color(0xFFFFD700) : Colors.grey[500],
                      size: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
