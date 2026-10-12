import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';

/// Tarjeta de previsualización individual para un sprite de catálogo.
class SpriteCardWidget extends StatelessWidget {
  const SpriteCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sprite,
  });

  final String title;
  final String subtitle;
  final Sprite? sprite;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF33302B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A453E)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1C1A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3D3833)),
              ),
              child: sprite != null
                  ? CustomPaint(
                      painter: _SpritePreviewPainter(sprite!),
                    )
                  : const Center(
                      child: Text(
                        'No sprite',
                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFEDE8DF),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFA89F91),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SpritePreviewPainter extends CustomPainter {
  _SpritePreviewPainter(this.sprite);

  final Sprite sprite;

  @override
  void paint(Canvas canvas, Size size) {
    final cellRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final destRect = SpriteLayoutHelper.calculateDestRect(
      cellRect: cellRect,
      srcWidth: sprite.srcSize.x,
      srcHeight: sprite.srcSize.y,
      fillRatio: 0.75,
    );

    sprite.renderRect(canvas, destRect);
  }

  @override
  bool shouldRepaint(_SpritePreviewPainter oldDelegate) =>
      oldDelegate.sprite != sprite;
}
