import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' show IconData, Icons;

/// Arquetipos arquitectónicos para ambientación contextual de habitaciones.
enum ZoneArchetype {
  library,
  kitchen,
  garden,
  bedroom,
  laboratory,
  gallery,
  lounge,
}

/// Abstracción visual exclusiva para el tipo de superficie/suelo de la habitación.
enum TileType {
  woodPlanks,
  checkerboard,
  classicTiles,
  stone,
  carpet,
}

/// Tema visual integral para una habitación de la escena del crimen.
class ZoneVisualTheme {
  const ZoneVisualTheme({
    required this.archetype,
    required this.displayName,
    required this.tintColor,
    required this.accentColor,
    required this.tileType,
    required this.icon,
  });

  final ZoneArchetype archetype;
  final String displayName;
  final ui.Color tintColor;
  final ui.Color accentColor;
  final TileType tileType;
  final IconData icon;

  /// Infiere el tema arquitectónico a partir del nombre o identificador de la zona.
  factory ZoneVisualTheme.fromZoneName(String? name, int zoneIndex) {
    final lower = (name ?? '').toLowerCase().trim();

    // 1. Biblioteca / Estudio / Archivo / Despacho / Cartografía
    if (lower.contains('biblio') ||
        lower.contains('lectura') ||
        lower.contains('archivo') ||
        lower.contains('despacho') ||
        lower.contains('cartograf') ||
        lower.contains('estudio') ||
        lower.contains('libro')) {
      return ZoneVisualTheme(
        archetype: ZoneArchetype.library,
        displayName: name ?? 'ESTUDIO',
        tintColor: const ui.Color(0xFFEFE6DC), // Roble claro cálido
        accentColor: const ui.Color(0xFF9E6B38), // Ámbar cuero suave
        tileType: TileType.woodPlanks,
        icon: Icons.menu_book_rounded,
      );
    }

    // 2. Cocina / Comedor / Bodega / Despensa
    if (lower.contains('cocina') ||
        lower.contains('comedor') ||
        lower.contains('bodega') ||
        lower.contains('despensa') ||
        lower.contains('foso') ||
        lower.contains('restaura')) {
      return ZoneVisualTheme(
        archetype: ZoneArchetype.kitchen,
        displayName: name ?? 'COCINA',
        tintColor: const ui.Color(0xFFF5F3EE), // Baldosa suave
        accentColor: const ui.Color(0xFFB55D44), // Terracota cálido
        tileType: TileType.checkerboard,
        icon: Icons.restaurant_rounded,
      );
    }

    // 3. Jardín / Invernadero / Botánico / Rosaleda / Patio / Taller
    if (lower.contains('jard') ||
        lower.contains('botán') ||
        lower.contains('botan') ||
        lower.contains('inverna') ||
        lower.contains('rosaleda') ||
        lower.contains('cenador') ||
        lower.contains('estanque') ||
        lower.contains('loto') ||
        lower.contains('orquíd') ||
        lower.contains('vivero') ||
        lower.contains('terraza') ||
        lower.contains('patio') ||
        lower.contains('taller')) {
      return ZoneVisualTheme(
        archetype: ZoneArchetype.garden,
        displayName: name ?? 'JARDÍN',
        tintColor: const ui.Color(0xFFE8EFE6), // Piedra clara salvia
        accentColor: const ui.Color(0xFF477353), // Verde botánico
        tileType: TileType.stone,
        icon: Icons.yard_rounded,
      );
    }

    // 4. Habitación / Dormitorio / Hotel / Camerinos / Aposentos
    if (lower.contains('habitaci') ||
        lower.contains('hotel') ||
        lower.contains('dormitorio') ||
        lower.contains('cuarto') ||
        lower.contains('aposento') ||
        lower.contains('camerino') ||
        lower.contains('baño')) {
      return ZoneVisualTheme(
        archetype: ZoneArchetype.bedroom,
        displayName: name ?? 'DORMITORIO',
        tintColor: const ui.Color(0xFFF3ECE6), // Marfil lino cálido
        accentColor: const ui.Color(0xFF8C5C6F), // Malva empolvado
        tileType: TileType.woodPlanks,
        icon: Icons.bed_rounded,
      );
    }

    // 5. Laboratorio / Observatorio / Cúpula / Óptica / Sala de máquinas
    if (lower.contains('laborat') ||
        lower.contains('observat') ||
        lower.contains('cúpula') ||
        lower.contains('cupula') ||
        lower.contains('óptic') ||
        lower.contains('optic') ||
        lower.contains('máquina') ||
        lower.contains('celestial')) {
      return ZoneVisualTheme(
        archetype: ZoneArchetype.laboratory,
        displayName: name ?? 'LABORATORIO',
        tintColor: const ui.Color(0xFFE9F1F5), // Azul blueprint técnico claro
        accentColor: const ui.Color(0xFF32688C), // Cian pizarra sobrio
        tileType: TileType.classicTiles,
        icon: Icons.science_rounded,
      );
    }

    // 6. Galería / Museo / Bóveda / Reliquias / Teatro / Escenario
    if (lower.contains('galer') ||
        lower.contains('museo') ||
        lower.contains('bóveda') ||
        lower.contains('boveda') ||
        lower.contains('reliquia') ||
        lower.contains('egipcia') ||
        lower.contains('renacentista') ||
        lower.contains('clásic') ||
        lower.contains('clasic') ||
        lower.contains('medieval') ||
        lower.contains('escult') ||
        lower.contains('columna') ||
        lower.contains('numism') ||
        lower.contains('escenario') ||
        lower.contains('teatro')) {
      return ZoneVisualTheme(
        archetype: ZoneArchetype.gallery,
        displayName: name ?? 'GALERÍA',
        tintColor: const ui.Color(0xFFF6EFE3), // Travertino / mármol pálido
        accentColor: const ui.Color(0xFF967336), // Bronce clásico suave
        tileType: TileType.classicTiles,
        icon: Icons.museum_rounded,
      );
    }

    // 7. Fallback elegante por defecto (Lounge / Salón)
    final defaultTints = [
      const ui.Color(0xFFECE6DE),
      const ui.Color(0xFFEFE8E1),
      const ui.Color(0xFFEBE6DC),
      const ui.Color(0xFFEEE8E4),
    ];
    final defaultAccents = [
      const ui.Color(0xFF5A6675),
      const ui.Color(0xFF8B6B55),
      const ui.Color(0xFF507567),
      const ui.Color(0xFF85637B),
    ];

    final tint = defaultTints[zoneIndex % defaultTints.length];
    final accent = defaultAccents[zoneIndex % defaultAccents.length];

    return ZoneVisualTheme(
      archetype: ZoneArchetype.lounge,
      displayName: name ?? 'SALÓN',
      tintColor: tint,
      accentColor: accent,
      tileType: TileType.carpet,
      icon: Icons.meeting_room_rounded,
    );
  }

  /// Dibuja la textura sutil del suelo dentro de la habitación usando el path como clip.
  void renderFloorTexture(
    ui.Canvas canvas,
    ui.Path roomClipPath,
    ui.Rect bounds,
    double tileSize,
  ) {
    canvas.save();
    canvas.clipPath(roomClipPath);

    // 1. Tinte base de suelo claro
    final bgPaint = ui.Paint()
      ..color = tintColor
      ..style = ui.PaintingStyle.fill;
    canvas.drawRect(bounds, bgPaint);

    // 2. Patrón de suelo sutil, elegante y de bajo contraste
    final linePaint = ui.Paint()
      ..color = const ui.Color(0xFF2C2825).withAlpha(14)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = (tileSize * 0.015).clamp(0.7, 1.2);

    switch (tileType) {
      case TileType.woodPlanks:
        final plankSpacing = (tileSize * 0.35).clamp(16.0, 26.0);
        final jointSpacing = plankSpacing * 2.6;
        for (double y = bounds.top; y <= bounds.bottom; y += plankSpacing) {
          canvas.drawLine(ui.Offset(bounds.left, y), ui.Offset(bounds.right, y), linePaint);
        }
        int rowIdx = 0;
        final jointPaint = ui.Paint()
          ..color = const ui.Color(0xFF2C2825).withAlpha(10)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = (tileSize * 0.012).clamp(0.6, 1.0);
        for (double y = bounds.top; y <= bounds.bottom; y += plankSpacing, rowIdx++) {
          final offset = (rowIdx % 2 == 0) ? 0.0 : jointSpacing / 2;
          for (double x = bounds.left + offset; x <= bounds.right; x += jointSpacing) {
            canvas.drawLine(ui.Offset(x, y), ui.Offset(x, y + plankSpacing), jointPaint);
          }
        }
        break;

      case TileType.checkerboard:
        final checkSize = (tileSize * 0.44).clamp(18.0, 30.0);
        final checkFill = ui.Paint()
          ..color = const ui.Color(0xFF2C2825).withAlpha(9)
          ..style = ui.PaintingStyle.fill;
        int row = 0;
        for (double y = bounds.top; y < bounds.bottom; y += checkSize, row++) {
          int col = 0;
          for (double x = bounds.left; x < bounds.right; x += checkSize, col++) {
            if ((row + col) % 2 == 0) {
              canvas.drawRect(ui.Rect.fromLTWH(x, y, checkSize, checkSize), checkFill);
            }
          }
        }
        break;

      case TileType.classicTiles:
        final gridStep = (tileSize * 0.48).clamp(20.0, 34.0);
        for (double y = bounds.top; y <= bounds.bottom; y += gridStep) {
          canvas.drawLine(ui.Offset(bounds.left, y), ui.Offset(bounds.right, y), linePaint);
        }
        for (double x = bounds.left; x <= bounds.right; x += gridStep) {
          canvas.drawLine(ui.Offset(x, bounds.top), ui.Offset(x, bounds.bottom), linePaint);
        }
        break;

      case TileType.stone:
        final stepY = (tileSize * 0.40).clamp(18.0, 28.0);
        final stepX = stepY * 1.8;
        for (double y = bounds.top; y <= bounds.bottom; y += stepY) {
          canvas.drawLine(ui.Offset(bounds.left, y), ui.Offset(bounds.right, y), linePaint);
        }
        int r = 0;
        for (double y = bounds.top; y <= bounds.bottom; y += stepY, r++) {
          final shift = (r % 2 == 0) ? 0.0 : stepX * 0.5;
          for (double x = bounds.left + shift; x <= bounds.right; x += stepX) {
            canvas.drawLine(ui.Offset(x, y), ui.Offset(x, y + stepY), linePaint);
          }
        }
        break;

      case TileType.carpet:
        final step = (tileSize * 0.30).clamp(14.0, 22.0);
        final weavePaint = ui.Paint()
          ..color = const ui.Color(0xFF2C2825).withAlpha(8)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.7;
        for (double d = bounds.left - bounds.height; d < bounds.right; d += step) {
          canvas.drawLine(ui.Offset(d, bounds.top), ui.Offset(d + bounds.height, bounds.bottom), weavePaint);
        }
        break;
    }

    // 3. Oclusión ambiental perimetral interior muy sutil
    final shadowPaint = ui.Paint()
      ..color = const ui.Color(0xFF000000).withAlpha(14)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(roomClipPath, shadowPaint);

    canvas.restore();
  }

  /// Dibuja una alfombra enriquecida como elemento decorativo del escenario.
  ///
  /// Mantiene la jerarquía visual estricta:
  /// Suspect / Candidate / X > Alfombra > Decoración
  void renderRug(
    ui.Canvas canvas,
    ui.Rect bounds,
    double cellW,
    double cellH,
  ) {
    final shouldHaveRug = archetype == ZoneArchetype.bedroom ||
        archetype == ZoneArchetype.lounge ||
        archetype == ZoneArchetype.library ||
        archetype == ZoneArchetype.gallery;

    if (!shouldHaveRug) return;
    if (bounds.width < cellW * 0.82 || bounds.height < cellH * 0.82) return;

    final ui.Color rugBaseColor;
    switch (archetype) {
      case ZoneArchetype.bedroom:
        rugBaseColor = const ui.Color(0xFF8B4747); // Carmín tenue / terracota
        break;
      case ZoneArchetype.lounge:
        rugBaseColor = const ui.Color(0xFF3F5A70); // Azul pizarra vintage
        break;
      case ZoneArchetype.library:
        rugBaseColor = const ui.Color(0xFF7A5C36); // Ámbar cuero envejecido
        break;
      case ZoneArchetype.gallery:
        rugBaseColor = const ui.Color(0xFF6B4D68); // Violeta/amatista apagado
        break;
      default:
        rugBaseColor = const ui.Color(0xFF555B63);
    }

    final rugW = min(bounds.width * 0.74, cellW * 2.2);
    final rugH = min(bounds.height * 0.74, cellH * 2.2);
    final rugRect = ui.Rect.fromCenter(
      center: bounds.center,
      width: rugW,
      height: rugH,
    );
    final rrect = ui.RRect.fromRectAndRadius(rugRect, const ui.Radius.circular(5.0));

    // 1. Sombra suave arrojada por la alfombra
    canvas.drawRRect(
      rrect.shift(const ui.Offset(0, 1.8)),
      ui.Paint()..color = const ui.Color(0x20000000)..style = ui.PaintingStyle.fill,
    );

    // 2. Relleno textil noble de bajo contraste (controlado para gameplay)
    canvas.drawRRect(
      rrect,
      ui.Paint()..color = rugBaseColor.withAlpha(50)..style = ui.PaintingStyle.fill,
    );

    // 3. Borde decorativo visible
    final borderWidth = (cellW * 0.024).clamp(1.2, 2.0);
    canvas.drawRRect(
      rrect,
      ui.Paint()
        ..color = rugBaseColor.withAlpha(160)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // 4. Cenefa interior
    if (rugW > 32 && rugH > 32) {
      canvas.drawRRect(
        rrect.deflate(3.5),
        ui.Paint()
          ..color = rugBaseColor.withAlpha(110)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // 5. Medallón central sutil
    if (rugW > 45 && rugH > 45) {
      final medallionSize = min(min(rugW, rugH) * 0.35, 34.0);
      final medallion = ui.RRect.fromRectAndRadius(
        ui.Rect.fromCenter(
          center: rugRect.center,
          width: medallionSize,
          height: medallionSize,
        ),
        const ui.Radius.circular(3.0),
      );
      canvas.drawRRect(
        medallion,
        ui.Paint()
          ..color = rugBaseColor.withAlpha(65)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.7,
      );
    }
  }

  /// Dibuja detalles arquitectónicos decorativos discretos (no colisionables).
  void renderAmbientDecoration(
    ui.Canvas canvas,
    ui.Rect bounds,
    double cellW,
    double cellH,
  ) {
    final decorPaint = ui.Paint()
      ..color = accentColor.withAlpha(50)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = (cellW * 0.015).clamp(0.8, 1.2);

    final fillPaint = ui.Paint()
      ..color = accentColor.withAlpha(14)
      ..style = ui.PaintingStyle.fill;

    const pad = 6.0;

    switch (archetype) {
      case ZoneArchetype.kitchen:
        final counterRect = ui.Rect.fromLTWH(bounds.left + pad, bounds.top + pad, cellW * 0.40, cellH * 0.30);
        canvas.drawRect(counterRect, fillPaint);
        canvas.drawRect(counterRect, decorPaint);
        final cx1 = counterRect.left + counterRect.width * 0.3;
        final cx2 = counterRect.left + counterRect.width * 0.7;
        final cy = counterRect.center.dy;
        canvas.drawCircle(ui.Offset(cx1, cy), 2.5, decorPaint);
        canvas.drawCircle(ui.Offset(cx2, cy), 2.5, decorPaint);
        break;

      case ZoneArchetype.library:
        final shelfRect = ui.Rect.fromLTWH(bounds.left + pad, bounds.top + pad, min(bounds.width - pad * 2, cellW * 0.70), 5.0);
        canvas.drawRect(shelfRect, fillPaint);
        canvas.drawRect(shelfRect, decorPaint);
        for (double x = shelfRect.left + 5; x < shelfRect.right - 4; x += 6) {
          canvas.drawLine(ui.Offset(x, shelfRect.top), ui.Offset(x, shelfRect.bottom), decorPaint);
        }
        break;

      case ZoneArchetype.bedroom:
        final rugRect = ui.Rect.fromLTWH(bounds.left + pad, bounds.top + pad, cellW * 0.35, cellH * 0.35);
        canvas.drawRRect(ui.RRect.fromRectAndRadius(rugRect, const ui.Radius.circular(3)), fillPaint);
        canvas.drawRRect(ui.RRect.fromRectAndRadius(rugRect, const ui.Radius.circular(3)), decorPaint);
        break;

      case ZoneArchetype.garden:
        final center = ui.Offset(bounds.right - pad - 10, bounds.bottom - pad - 10);
        canvas.drawCircle(center, 5.5, fillPaint);
        canvas.drawCircle(center, 5.5, decorPaint);
        for (int i = 0; i < 4; i++) {
          final rad = (i * pi / 2) + (pi / 4);
          canvas.drawLine(center, ui.Offset(center.dx + cos(rad) * 7, center.dy + sin(rad) * 7), decorPaint);
        }
        break;

      case ZoneArchetype.laboratory:
        final deskRect = ui.Rect.fromLTWH(bounds.left + pad, bounds.top + pad, cellW * 0.38, cellH * 0.28);
        canvas.drawRect(deskRect, fillPaint);
        canvas.drawRect(deskRect, decorPaint);
        canvas.drawLine(ui.Offset(deskRect.left + 4, deskRect.center.dy), ui.Offset(deskRect.right - 4, deskRect.center.dy), decorPaint);
        break;

      case ZoneArchetype.gallery:
        final pedestal = ui.Rect.fromLTWH(bounds.left + pad, bounds.top + pad, 14, 14);
        canvas.drawRect(pedestal, fillPaint);
        canvas.drawRect(pedestal, decorPaint);
        canvas.drawRect(pedestal.deflate(2.5), decorPaint);
        break;

      case ZoneArchetype.lounge:
        final rug = ui.Rect.fromLTWH(bounds.left + pad, bounds.top + pad, min(bounds.width * 0.38, cellW * 0.50), min(bounds.height * 0.38, cellH * 0.50));
        canvas.drawRRect(ui.RRect.fromRectAndRadius(rug, const ui.Radius.circular(3)), fillPaint);
        canvas.drawRRect(ui.RRect.fromRectAndRadius(rug, const ui.Radius.circular(3)), decorPaint);
        break;
    }
  }

  /// Estampa el nombre de la habitación como un Robust Text Component multi-línea,
  /// con tipografía pesada w900, sombra de alto contraste y sin truncamiento por ellipsis.
  void renderRoomWatermark({
    required ui.Canvas canvas,
    required ui.Offset visualCenter,
    required ui.Rect roomBounds,
    required double cellWidth,
    required double cellHeight,
  }) {
    final text = displayName.toUpperCase().trim();
    if (text.isEmpty) return;

    final words = text.split(RegExp(r'\s+'));

    // Ancho y alto máximos disponibles dentro de la habitación
    final availW = max(min(roomBounds.width - cellWidth * 0.20, cellWidth * 2.5), cellWidth * 0.72);
    final availH = max(roomBounds.height - cellHeight * 0.20, cellHeight * 0.72);

    // 1. División inteligente por palabras completas (1, 2 o hasta 3 líneas)
    final lines = _splitWordsIntoLines(words, availW, cellWidth);

    // 2. Cálculo adaptativo de tamaño de fuente
    final maxCharCount = lines.map((l) => l.length).reduce(max);
    var fontSize = (min(cellWidth, cellHeight) * 0.17).clamp(8.5, 12.5);

    // Reducción proporcional si alguna línea excede el ancho disponible
    final estimatedW = maxCharCount * fontSize * 0.65;
    if (estimatedW > availW) {
      fontSize = (availW / (maxCharCount * 0.65)).clamp(7.5, 12.5);
    }
    // Verificación de altura disponible
    final estimatedH = lines.length * fontSize * 1.25;
    if (estimatedH > availH) {
      fontSize = (availH / (lines.length * 1.25)).clamp(7.0, fontSize);
    }

    final formattedText = lines.join('\n');

    // 3. Construcción del párrafo
    // Pase 1: Sombra/relieve de contorno para máximo contraste
    final shadowPb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: fontSize,
        height: 1.12,
        maxLines: 3,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: const ui.Color(0x65000000),
        fontWeight: ui.FontWeight.w900,
        letterSpacing: 1.1,
        fontFamily: 'Roboto',
      ))
      ..addText(formattedText);

    final shadowParagraph = shadowPb.build()..layout(ui.ParagraphConstraints(width: availW + 10));

    // Pase 2: Tinta frontal blueprint en carbón nítido
    final forePb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: fontSize,
        height: 1.12,
        maxLines: 3,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: const ui.Color(0xFF262422).withAlpha(185),
        fontWeight: ui.FontWeight.w900,
        letterSpacing: 1.1,
        fontFamily: 'Roboto',
      ))
      ..addText(formattedText);

    final foreParagraph = forePb.build()..layout(ui.ParagraphConstraints(width: availW + 10));

    // 4. Centrado y contención estricta dentro de los límites interiores de la habitación
    final textW = foreParagraph.maxIntrinsicWidth;
    final textH = foreParagraph.height;
    final halfW = textW / 2;
    final halfH = textH / 2;

    final safeMarginX = cellWidth * 0.08;
    final safeMarginY = cellHeight * 0.08;

    final minX = roomBounds.left + safeMarginX;
    final maxX = roomBounds.right - safeMarginX - textW;
    final minY = roomBounds.top + safeMarginY;
    final maxY = roomBounds.bottom - safeMarginY - textH;

    final clampedX = (visualCenter.dx - halfW).clamp(minX, max(minX, maxX)).toDouble();
    final clampedY = (visualCenter.dy - halfH).clamp(minY, max(minY, maxY)).toDouble();

    final drawOffset = ui.Offset(clampedX, clampedY);

    // Dibujar sombra dura/relieve
    canvas.drawParagraph(shadowParagraph, drawOffset + const ui.Offset(0.9, 1.2));
    // Dibujar texto principal
    canvas.drawParagraph(foreParagraph, drawOffset);
  }

  static List<String> _splitWordsIntoLines(List<String> words, double availW, double cellWidth) {
    if (words.length <= 1) return words;

    // Si son dos palabras, colocarlas en 2 líneas si una sola línea resultaría muy apretada
    if (words.length == 2) {
      if (words[0].length + words[1].length > 10 || availW < cellWidth * 1.5) {
        return [words[0], words[1]];
      }
      return ['${words[0]} ${words[1]}'];
    }

    if (words.length == 3) {
      if (words[0].length + words[1].length <= 8) {
        return ['${words[0]} ${words[1]}', words[2]];
      } else {
        return [words[0], '${words[1]} ${words[2]}'];
      }
    }

    // Para 4 o más palabras, empacar en 2 o 3 líneas balanceadas
    final totalChars = words.fold<int>(0, (sum, w) => sum + w.length) + words.length - 1;
    final targetPerLine = (totalChars / 3).ceil();
    final lines = <String>[];
    var currentLine = words.first;

    for (int i = 1; i < words.length; i++) {
      if (lines.length < 2 && (currentLine.length + 1 + words[i].length) > targetPerLine) {
        lines.add(currentLine);
        currentLine = words[i];
      } else {
        currentLine = '$currentLine ${words[i]}';
      }
    }
    lines.add(currentLine);
    return lines;
  }
}
