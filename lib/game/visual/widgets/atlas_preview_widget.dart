import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/visual/models/texture_atlas.dart';
import 'package:nexus_mortis/game/visual/services/atlas_manager.dart';
import 'package:nexus_mortis/game/visual/services/atlas_registry.dart';
import 'package:nexus_mortis/game/visual/services/decoration_catalog.dart';
import 'package:nexus_mortis/game/visual/services/floor_catalog.dart';
import 'package:nexus_mortis/game/visual/services/furniture_catalog.dart';
import 'package:nexus_mortis/game/visual/widgets/atlas_diagnostics_widget.dart';
import 'package:nexus_mortis/game/visual/widgets/atlas_full_image_viewer.dart';
import 'package:nexus_mortis/game/visual/widgets/board_visual_preview_tab.dart';
import 'package:nexus_mortis/game/visual/widgets/sprite_card_widget.dart';

/// Widget de desarrollo integral para inspeccionar y validar visualmente
/// todos los sprites, atlas y configuraciones registrados en Nexus Mortis.
///
/// Dispone de 5 pestañas:
/// 1. Mobiliario ([FurnitureCatalog])
/// 2. Decoración ([DecorationCatalog])
/// 3. Suelos ([FloorCatalog])
/// 4. Hoja & Diagnóstico (Visor completo de atlas y validación de recortes)
/// 5. Tablero (Previsualización procedural mini del tablero)
class AtlasPreviewWidget extends StatefulWidget {
  const AtlasPreviewWidget({super.key});

  @override
  State<AtlasPreviewWidget> createState() => _AtlasPreviewWidgetState();
}

class _AtlasPreviewWidgetState extends State<AtlasPreviewWidget> {
  late Future<void> _loadFuture;
  String _selectedAtlasId = FurnitureCatalog.kitchenAtlasId;

  @override
  void initState() {
    super.initState();
    if (AtlasManager.instance.isLoaded(_selectedAtlasId)) {
      _loadFuture = Future.value();
    } else {
      _loadFuture = _loadAtlases();
    }
  }

  Future<void> _loadAtlases() async {
    await AtlasRegistry.instance.preloadAll(AtlasManager.instance);
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

        final loadedAtlas = AtlasManager.instance.getAtlas(_selectedAtlasId);
        final availableAtlases = AtlasManager.instance.allLoadedAtlases;

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Nexus Mortis — Catálogos Visuales'),
              backgroundColor: const Color(0xFF1B1A17),
              foregroundColor: const Color(0xFFEDE8DF),
              actions: [
                if (availableAtlases.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: DropdownButton<String>(
                      value: _selectedAtlasId,
                      dropdownColor: const Color(0xFF262422),
                      style: const TextStyle(color: Color(0xFFEDE8DF), fontSize: 13),
                      underline: const SizedBox(),
                      icon: const Icon(Icons.layers_rounded, color: Color(0xFFB55D44)),
                      items: availableAtlases.map((atlas) {
                        return DropdownMenuItem(
                          value: atlas.definition.id,
                          child: Text(atlas.definition.id),
                        );
                      }).toList(),
                      onChanged: (newId) {
                        if (newId != null) {
                          setState(() => _selectedAtlasId = newId);
                        }
                      },
                    ),
                  ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                indicatorColor: Color(0xFFB55D44),
                labelColor: Color(0xFFEDE8DF),
                unselectedLabelColor: Color(0xFFA89F91),
                tabs: [
                  Tab(text: 'Mobiliario'),
                  Tab(text: 'Decoración'),
                  Tab(text: 'Suelos'),
                  Tab(text: 'Hoja & Diagnóstico'),
                  Tab(text: 'Tablero'),
                ],
              ),
            ),
            backgroundColor: const Color(0xFF262422),
            body: TabBarView(
              children: [
                _buildFurnitureTab(),
                _buildDecorationTab(),
                _buildFloorsTab(),
                loadedAtlas != null
                    ? _buildDiagnosticsTab(loadedAtlas)
                    : const Center(
                        child: Text(
                          'No hay atlas seleccionado cargado.',
                          style: TextStyle(color: Color(0xFFA89F91)),
                        ),
                      ),
                const BoardVisualPreviewTab(),
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
        final atlas = AtlasRegistry.instance.getAtlas(entry.atlasId);
        final region = atlas?.getRegion(entry.regionName);

        return SpriteCardWidget(
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
        return SpriteCardWidget(
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

  Widget _buildDiagnosticsTab(LoadedAtlas loadedAtlas) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Color(0xFFB55D44),
            labelColor: Color(0xFFEDE8DF),
            unselectedLabelColor: Color(0xFFA89F91),
            tabs: [
              Tab(text: 'Diagnóstico Geométrico'),
              Tab(text: 'Visor de Imagen'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                AtlasDiagnosticsWidget(loadedAtlas: loadedAtlas),
                AtlasFullImageViewer(loadedAtlas: loadedAtlas),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

