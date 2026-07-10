import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';

/// Panel de confirmación del sospechoso seleccionado.
///
/// Permite confirmar la posición del sospechoso activo (si tiene exactamente
/// 1 candidato) y deshacerla si ya fue confirmada.
///
/// Se actualiza reactivamente usando [ValueListenableBuilder] sobre
/// [BoardController.version], sin necesidad de polling.
class ConfirmationPanel extends StatelessWidget {
  const ConfirmationPanel({super.key, required this.controller});

  final BoardController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller.version,
      builder: (context, _, _) {
        final suspect = controller.selectedSuspect;

        if (suspect == null) {
          return const SizedBox.shrink();
        }

        final alreadyConfirmed = controller.isSuspectConfirmed(suspect.id);
        final canConfirm = controller.canConfirmSelectedSuspect();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF0E0E16),
          child: Row(
            children: [
              // Nombre del sospechoso activo
              Text(
                suspect.name,
                style: const TextStyle(
                  color: Color(0xFFCCCCFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Botón Confirmar (solo si NO está confirmado)
              if (!alreadyConfirmed)
                _ActionButton(
                  label: '✓ Confirmar',
                  enabled: canConfirm,
                  color: const Color(0xFFB8860B),
                  onTap: () => controller.confirmSelectedSuspect(),
                ),
              // Botón Deshacer (solo si YA está confirmado)
              if (alreadyConfirmed)
                _ActionButton(
                  label: '↩ Deshacer',
                  enabled: true,
                  color: const Color(0xFF885555),
                  onTap: () => controller.unconfirmSuspect(suspect.id),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: enabled ? color : const Color(0xFF333333),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: enabled ? color : const Color(0xFF444444),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
