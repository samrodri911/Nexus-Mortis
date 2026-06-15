import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/board/models/tool_mode.dart';

/// Panel para que el investigador seleccione la herramienta activa.
///
/// Permite cambiar entre modo "Posible" (candidato) y modo "X" (descartado).
class ToolPanel extends StatefulWidget {
  const ToolPanel({super.key, required this.controller});

  final BoardController controller;

  @override
  State<ToolPanel> createState() => _ToolPanelState();
}

class _ToolPanelState extends State<ToolPanel> {
  void _setTool(ToolMode mode) {
    setState(() {
      widget.controller.setToolMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeTool = widget.controller.activeTool;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF0F0F14), // Ligeramente más oscuro que el panel superior
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ToolButton(
            label: 'Posible',
            isActive: activeTool == ToolMode.candidate,
            onTap: () => _setTool(ToolMode.candidate),
          ),
          const SizedBox(width: 16),
          _ToolButton(
            label: 'X (Descartar)',
            isActive: activeTool == ToolMode.eliminated,
            onTap: () => _setTool(ToolMode.eliminated),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF3E3E50) : const Color(0xFF1E1E2A),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? const Color(0xFF8888D0) : const Color(0xFF2E2E3E),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF888899),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
