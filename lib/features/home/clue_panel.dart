import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/clues/models/spatial_clue_data.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Panel interactivo y elegante que muestra las tarjetas de pistas de los sospechosos, la víctima y reglas de escenario.
class CluePanel extends StatefulWidget {
  const CluePanel({
    super.key,
    required this.controller,
    this.caseData,
  });

  final BoardController controller;
  final CaseData? caseData;

  @override
  State<CluePanel> createState() => _CluePanelState();
}

class _CluePanelState extends State<CluePanel> {
  bool _isExpanded = false; // Colapsado por defecto para maximizar espacio del tablero
  bool _showDescription = false;

  @override
  Widget build(BuildContext context) {
    final caseData = widget.caseData;
    final clues = widget.controller.clues;

    final globalRulesCount = caseData?.globalRules.length ?? 0;
    final totalClues = globalRulesCount + clues.length;
    final countLabel = totalClues == 1 ? '1 disponible' : '$totalClues disponibles';

    final screenH = MediaQuery.sizeOf(context).height;
    // Altura adaptativa para el estado expandido: protege el espacio del tablero en móviles pequeños
    final maxExpandedH = (screenH * 0.32).clamp(180.0, 240.0);
    final currentHeight = _isExpanded ? maxExpandedH : 46.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: double.infinity,
      height: currentHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        border: Border(
          top: BorderSide(
            color: _isExpanded ? const Color(0xFF384460) : const Color(0xFF28283C),
            width: 1.5,
          ),
        ),
        boxShadow: _isExpanded
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(90),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de cabecera compacta táctil (Estado COLLAPSED / toggle)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: _isExpanded ? const Color(0xFF1A1A28) : const Color(0xFF14141E),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFFFFD700),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PISTAS',
                    style: TextStyle(
                      color: Color(0xFFE2E2F0),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Badge con indicador de pistas disponibles
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F293D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF3B4D70),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      countLabel,
                      style: const TextStyle(
                        color: Color(0xFF90CAF9),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Botón "Ver Caso" (solo cuando está expandido)
                  if (_isExpanded && caseData != null && caseData.description.isNotEmpty) ...[
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showDescription = !_showDescription;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showDescription ? Icons.visibility_off : Icons.menu_book,
                              color: const Color(0xFF8C9EFF),
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _showDescription ? 'Ocultar Caso' : 'Ver Caso',
                              style: const TextStyle(
                                color: Color(0xFF8C9EFF),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Icono indicador de expansión/colapso
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // Contenido desplegable (activo solo cuando está EXPANDED)
          if (_isExpanded)
            Expanded(
              child: clues.isEmpty && (caseData == null || caseData.globalRules.isEmpty)
                  ? const Center(
                      child: Text(
                        'No hay tarjetas de pistas disponibles.',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      children: [
                        // Contexto / Descripción del caso
                        if (_showDescription && caseData != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1F30),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF383850)),
                            ),
                            child: Text(
                              caseData.description,
                              style: const TextStyle(
                                color: Color(0xFFD0D0E2),
                                fontSize: 11.5,
                                height: 1.3,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],

                        // Reglas globales del escenario (si existen)
                        if (caseData != null && caseData.globalRules.isNotEmpty)
                          ...caseData.globalRules.map((rule) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF182332),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF00ACC1), width: 1.2),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00ACC1).withAlpha(50),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: const Color(0xFF00ACC1), width: 1),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.gavel_rounded, color: Color(0xFF80DEEA), size: 11),
                                        SizedBox(width: 4),
                                        Text(
                                          'PISTA GENERAL',
                                          style: TextStyle(
                                            color: Color(0xFF80DEEA),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9.5,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rule.text,
                                      style: const TextStyle(
                                        color: Color(0xFFE0F7FA),
                                        fontSize: 11.5,
                                        height: 1.25,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                        // Lista de tarjetas de declaraciones de sospechosos
                        ...clues.map((clue) {
                          final suspectName = _resolveSuspectName(clue.suspectId, caseData);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: _SuspectClueCardWidget(
                              clue: clue,
                              suspectName: suspectName,
                            ),
                          );
                        }),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  String _resolveSuspectName(String suspectId, CaseData? caseData) {
    if (suspectId == 'victim' || suspectId == caseData?.victimId) {
      return 'VÍCTIMA';
    }
    if (caseData != null) {
      for (final s in caseData.suspects) {
        if (s.id == suspectId) return s.name.toUpperCase();
      }
    }
    return suspectId.toUpperCase();
  }
}

class _SuspectClueCardWidget extends StatelessWidget {
  const _SuspectClueCardWidget({
    required this.clue,
    required this.suspectName,
  });

  final SpatialClueData clue;
  final String suspectName;

  @override
  Widget build(BuildContext context) {
    final isVictim = clue.isVictimCard || suspectName == 'VÍCTIMA';

    final badgeColor = isVictim ? const Color(0xFFE53935) : const Color(0xFF3949AB);
    final cardBgColor = isVictim ? const Color(0xFF201416) : const Color(0xFF181826);
    final borderColor = isVictim ? const Color(0xFF5A2226) : const Color(0xFF2C2C44);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge del personaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withAlpha(50),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: badgeColor, width: 1),
            ),
            child: Text(
              suspectName,
              style: TextStyle(
                color: isVictim ? const Color(0xFFFF8A80) : const Color(0xFF9FA8DA),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Texto compuesto de la tarjeta
          Expanded(
            child: Text(
              clue.text,
              style: TextStyle(
                color: isVictim ? const Color(0xFFFFCDD2) : const Color(0xFFE8E8F2),
                fontSize: 12,
                height: 1.25,
                fontStyle: isVictim ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
