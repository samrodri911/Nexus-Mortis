import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/visual/models/sprite_region.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';

/// Visor visual de la imagen completa del atlas con recuadros delimitadores
/// de cada región registrada.
class AtlasFullImageViewer extends StatefulWidget {
  const AtlasFullImageViewer({
    super.key,
    required this.loadedAtlas,
  });

  final LoadedAtlas loadedAtlas;

  @override
  State<AtlasFullImageViewer> createState() => _AtlasFullImageViewerState();
}

class _AtlasFullImageViewerState extends State<AtlasFullImageViewer> {
  String? _selectedRegionName;

  @override
  Widget build(BuildContext context) {
    final image = widget.loadedAtlas.image;
    final regions = widget.loadedAtlas.definition.regions;

    return Column(
      children: [
        // Barra de estado de región seleccionada
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFF1E1C1A),
          child: Row(
            children: [
              Text(
                _selectedRegionName != null
                    ? 'Región: $_selectedRegionName'
                    : 'Toca una región o inspecciona la imagen completa (${image.width}×${image.height} px)',
                style: const TextStyle(
                  color: Color(0xFFEDE8DF),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_selectedRegionName != null && regions.containsKey(_selectedRegionName)) ...[
                Text(
                  '${regions[_selectedRegionName]!.width.toInt()}×${regions[_selectedRegionName]!.height.toInt()} px • pos: (${regions[_selectedRegionName]!.x.toInt()}, ${regions[_selectedRegionName]!.y.toInt()})',
                  style: const TextStyle(color: Color(0xFF68B684), fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        // Visor de imagen con CustomPaint
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                minScale: 0.2,
                maxScale: 5.0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF4A453E)),
                      color: const Color(0xFF141311),
                    ),
                    child: CustomPaint(
                      size: Size(image.width.toDouble(), image.height.toDouble()),
                      painter: _AtlasPainter(
                        image: image,
                        regions: regions,
                        selectedRegionName: _selectedRegionName,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AtlasPainter extends CustomPainter {
  _AtlasPainter({
    required this.image,
    required this.regions,
    required this.selectedRegionName,
  });

  final ui.Image image;
  final Map<String, SpriteRegion> regions;
  final String? selectedRegionName;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dibujar imagen del atlas
    canvas.drawImage(image, Offset.zero, Paint());

    // 2. Dibujar cajas delimitadoras para cada región
    final normalBoxPaint = Paint()
      ..color = const Color(0xFF42A5F5).withAlpha(180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final selectedBoxPaint = Paint()
      ..color = const Color(0xFF68B684)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      backgroundColor: Color(0xCC000000),
      fontWeight: FontWeight.bold,
    );

    for (final region in regions.values) {
      final isSelected = region.name == selectedRegionName;
      final rect = region.rect;

      canvas.drawRect(rect, isSelected ? selectedBoxPaint : normalBoxPaint);

      // Etiqueta del nombre del sprite
      final tp = TextPainter(
        text: TextSpan(text: ' ${region.name} ', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(region.x, region.y - 12 < 0 ? region.y : region.y - 12));
    }
  }

  @override
  bool shouldRepaint(_AtlasPainter oldDelegate) {
    return oldDelegate.selectedRegionName != selectedRegionName ||
        oldDelegate.image != image;
  }
}
