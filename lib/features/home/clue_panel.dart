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
  bool _showDescription = false;

  @override
  Widget build(BuildContext context) {
    final caseData = widget.caseData;
    final clues = widget.controller.clues;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: const BoxDecoration(
        color: Color(0xFF14141E),
        border: Border(
          top: BorderSide(color: Color(0xFF28283C), width: 1.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header con título y botón de caso
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: const Color(0xFF1A1A28),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 6),
                const Text(
                  'TARJETAS DE DECLARACIÓN',
                  style: TextStyle(
                    color: Color(0xFFE2E2F0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                if (caseData != null && caseData.description.isNotEmpty)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showDescription = !_showDescription;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showDescription ? Icons.visibility_off : Icons.menu_book,
                            color: const Color(0xFF8C9EFF),
                            size: 14,
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
              ],
            ),
          ),

          // Contexto / Descripción expandible
          if (_showDescription && caseData != null)
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF1F1F30),
              child: Text(
                caseData.description,
                style: const TextStyle(
                  color: Color(0xFFD0D0E2),
                  fontSize: 12,
                  height: 1.3,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Reglas globales del escenario (si existen)
          if (caseData != null && caseData.globalRules.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Column(
                children: caseData.globalRules.map((rule) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF232338),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF434368), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.rule, color: Color(0xFF80DEEA), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            rule.text,
                            style: const TextStyle(
                              color: Color(0xFFE0F7FA),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          // Lista de tarjetas de sospechosos
          Expanded(
            child: clues.isEmpty
                ? const Center(
                    child: Text(
                      'No hay tarjetas de pistas disponibles.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: clues.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final clue = clues[index];
                      final suspectName = _resolveSuspectName(clue.suspectId, caseData);
                      return _SuspectClueCardWidget(
                        clue: clue,
                        suspectName: suspectName,
                      );
                    },
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
