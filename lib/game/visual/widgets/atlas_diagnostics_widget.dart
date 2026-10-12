import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/visual/models/atlas_validation_result.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';

/// Widget de diagnóstico visual para un atlas de texturas.
///
/// Muestra:
/// - Dimensiones reales de la imagen base.
/// - Cantidad de regiones válidas.
/// - Detección de regiones fuera de límites o con dimensiones no positivas.
/// - Advertencias técnicas de recorte.
class AtlasDiagnosticsWidget extends StatelessWidget {
  const AtlasDiagnosticsWidget({
    super.key,
    required this.loadedAtlas,
  });

  final LoadedAtlas loadedAtlas;

  @override
  Widget build(BuildContext context) {
    final result = loadedAtlas.validate();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(result),
          const SizedBox(height: 16),
          if (result.errors.isNotEmpty) ...[
            _buildSectionTitle('Errores Críticos (${result.errors.length})', Colors.redAccent),
            const SizedBox(height: 8),
            ...result.errors.map((e) => _buildIssueTile(e, isError: true)),
            const SizedBox(height: 16),
          ],
          if (result.warnings.isNotEmpty) ...[
            _buildSectionTitle('Advertencias (${result.warnings.length})', Colors.amberAccent),
            const SizedBox(height: 8),
            ...result.warnings.map((w) => _buildIssueTile(w, isError: false)),
            const SizedBox(height: 16),
          ],
          _buildSectionTitle('Regiones Válidas (${result.validRegions.length})', const Color(0xFF68B684)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: result.validRegions.length,
              itemBuilder: (context, index) {
                final name = result.validRegions[index];
                final region = loadedAtlas.definition.getRegion(name)!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF33302B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF4A453E)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF68B684), size: 18),
                      const SizedBox(width: 10),
                      Text(
                        name,
                        style: const TextStyle(
                          color: Color(0xFFEDE8DF),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'x:${region.x.toInt()} y:${region.y.toInt()} • ${region.width.toInt()}×${region.height.toInt()} px',
                        style: const TextStyle(color: Color(0xFFA89F91), fontSize: 12),
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

  Widget _buildSummaryCard(AtlasValidationResult result) {
    final statusColor = result.isValid ? const Color(0xFF68B684) : Colors.redAccent;
    final statusIcon = result.isValid ? Icons.verified_rounded : Icons.warning_rounded;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2C28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withAlpha(120)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.isValid ? 'Atlas Válido y Saludable' : 'Atlas con Errores Geométricos',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.summary,
                  style: const TextStyle(color: Color(0xFFD4CEC3), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildIssueTile(String text, {required bool isError}) {
    final color = isError ? Colors.redAccent : Colors.amberAccent;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline_rounded : Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
