import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/clues/models/suspect_data.dart';

/// Panel Flutter de selección de sospechosos.
///
/// Responsabilidad exclusiva: permitir al jugador activar o desactivar
/// un sospechoso. Al tocar uno seleccionado, lo deselecciona.
///
/// Este widget es Flutter puro. No conoce nada de Flame.
/// La comunicación con el tablero ocurre a través de [BoardController],
/// que es compartido por referencia con [NexusGame].
class SuspectPanel extends StatefulWidget {
  const SuspectPanel({super.key, required this.controller});

  final BoardController controller;

  @override
  State<SuspectPanel> createState() => _SuspectPanelState();
}

class _SuspectPanelState extends State<SuspectPanel> {
  void _onTap(SuspectData suspect) {
    setState(() {
      final isActive = widget.controller.selectedSuspect?.id == suspect.id;
      widget.controller.selectSuspect(isActive ? null : suspect);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.selectedSuspect;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color(0xFF13131A),
      child: Wrap(
        spacing: 8,
        children: widget.controller.suspects.map((suspect) {
          final isActive = selected?.id == suspect.id;
          return _SuspectChip(
            suspect: suspect,
            isActive: isActive,
            onTap: () => _onTap(suspect),
          );
        }).toList(),
      ),
    );
  }
}

class _SuspectChip extends StatelessWidget {
  const _SuspectChip({
    required this.suspect,
    required this.isActive,
    required this.onTap,
  });

  final SuspectData suspect;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E2E50) : const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? const Color(0xFF7070C0) : const Color(0xFF2E2E3E),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          suspect.name,
          style: TextStyle(
            color: isActive ? const Color(0xFFCCCCFF) : const Color(0xFF777788),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
