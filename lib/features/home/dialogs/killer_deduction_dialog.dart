import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';

/// Diálogo temático interactivo para la deducción y acusación formal del asesino.
class KillerDeductionDialog extends StatefulWidget {
  const KillerDeductionDialog({
    super.key,
    required this.caseData,
    required this.onAccuse,
  });

  final CaseData caseData;
  final Future<GameResult?> Function(String suspectId) onAccuse;

  @override
  State<KillerDeductionDialog> createState() => _KillerDeductionDialogState();
}

class _KillerDeductionDialogState extends State<KillerDeductionDialog> {
  String? _selectedSuspectId;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // Excluir a la víctima de la lista de sospechosos a acusar
    final accusedCandidates = widget.caseData.suspects
        .where((s) => s.id != widget.caseData.victimId)
        .toList();

    return Dialog(
      backgroundColor: const Color(0xFF1A1A24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF8B0000), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.fingerprint, color: Color(0xFFFF4444), size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '¿QUIÉN ES EL ASESINO?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: _isProcessing ? null : () => Navigator.of(context).pop(null),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Has deducido las posiciones del tablero. Basándote en la zona donde se encontraba la víctima, acusa formalmente al culpable.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF441111),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade700),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: accusedCandidates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final suspect = accusedCandidates[index];
                  final isSelected = _selectedSuspectId == suspect.id;

                  return InkWell(
                    onTap: _isProcessing
                        ? null
                        : () {
                            setState(() {
                              _selectedSuspectId = suspect.id;
                              _errorMessage = null;
                            });
                          },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF3B1E2B) : const Color(0xFF242434),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF5555) : const Color(0xFF3E3E55),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isSelected ? const Color(0xFFFF5555) : const Color(0xFF444460),
                            child: Text(
                              suspect.name.isNotEmpty ? suspect.name[0] : '?',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              suspect.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFFFF5555), size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: (_selectedSuspectId == null || _isProcessing)
                  ? null
                  : () async {
                      setState(() {
                        _isProcessing = true;
                        _errorMessage = null;
                      });

                      try {
                        final result = await widget.onAccuse(_selectedSuspectId!);

                        if (!context.mounted) return;

                        if (result != null) {
                          Navigator.of(context).pop(result);
                        } else {
                          setState(() {
                            _isProcessing = false;
                            _errorMessage = 'Acusación incorrecta. Recuerda: el asesino debe estar en la misma zona que la víctima.';
                          });
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        setState(() {
                          _isProcessing = false;
                          _errorMessage = 'Ocurrió un error al procesar la acusación: $e';
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                disabledBackgroundColor: const Color(0xFF442222),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'ACUSAR AL SOSPECHOSO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
