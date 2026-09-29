import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/decoration_catalog.dart';
import 'package:nexus_mortis/game/visual/services/floor_catalog.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';
import 'package:nexus_mortis/game/visual/utils/sprite_layout_helper.dart';

/// Widget de desarrollo aislado para inspeccionar y validar visualmente
/// todos los sprites y configuraciones registrados en los catálogos visuales.
///
/// Dispone de 3 pestañas:
/// 1. Mobiliario ([FurnitureCatalog])
/// 2. Decoración ([DecorationCatalog])
/// 3. Suelos ([FloorCatalog])
class AtlasPreviewWidget extends StatefulWidget {
  const AtlasPreviewWidget({super.key});

  @override
  State<AtlasPreviewWidget> createState() => _AtlasPreviewWidgetState();
}

class _AtlasPreviewWidgetState extends State<AtlasPreviewWidget> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadAtlas();
  }

  Future<void> _loadAtlas() async {
    await AtlasManager.instance.loadAtlas(FurnitureCatalog.kitchenAtlas);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar atlas: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Nexus Mortis — Catálogos Visuales'),
              backgroundColor: const Color(0xFF1B1A17),
              foregroundColor: const Color(0xFFEDE8DF),
              bottom: const TabBar(
                indicatorColor: Color(0xFFB55D44),
                labelColor: Color(0xFFEDE8DF),
                unselectedLabelColor: Color(0xFFA89F91),
                tabs: [
                  Tab(text: 'Mobiliario'),
                  Tab(text: 'Decoración'),
                  Tab(text: 'Suelos'),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF262422),
            body: TabBarView(
              children: [
                _buildFurnitureTab(),
                _buildDecorationTab(),
                _buildFloorsTab(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFurnitureTab() {
    final entries = FurnitureCatalog.instance.allEntries;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final sprite = AtlasManager.instance.getSprite(
          entry.atlasId,
          entry.regionName,
        );
        final region =
            FurnitureCatalog.kitchenAtlas.getRegion(entry.regionName);

        return _SpriteCard(
          title: entry.id,
          subtitle:
              '${region?.width.toInt() ?? 0}×${region?.height.toInt() ?? 0} px • ${entry.category}',
          sprite: sprite,
        );
      },
    );
  }

  Widget _buildDecorationTab() {
    final entries = DecorationCatalog.instance.allEntries;
    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'No hay decoraciones registradas en este momento.\n(Usa ArchitecturalFurnitureRenderer como fallback)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFA89F91), fontSize: 13),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final sprite = AtlasManager.instance.getSprite(
          entry.atlasId,
          entry.regionName,
        );
        return _SpriteCard(
          title: entry.id,
          subtitle: entry.category,
          sprite: sprite,
        );
      },
    );
  }

  Widget _buildFloorsTab() {
    final entries = FloorCatalog.instance.allEntries;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF33302B),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4A453E)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.displayName,
                style: const TextStyle(
                  color: Color(0xFFEDE8DF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${entry.id}',
                style: const TextStyle(
                  color: Color(0xFFA89F91),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1C1A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Fallback: ${entry.fallbackTileType.name}',
                  style: const TextStyle(
                    color: Color(0xFFC4B8A5),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SpriteCard extends StatelessWidget {
  const _SpriteCard({
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
