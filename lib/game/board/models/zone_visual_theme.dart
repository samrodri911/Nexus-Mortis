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
    this.hasRug = false,
  });

  final ZoneArchetype archetype;
  final String displayName;
  final ui.Color tintColor;
  final ui.Color accentColor;
  final TileType tileType;
  final IconData icon;
  final bool hasRug;

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
        hasRug: true,
      );
    }

    // 2. Cocina / Comedor / Bodega / Despensa / Trabajo (Suelo limpio siempre)
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
        hasRug: false,
      );
    }

    // 3. Jardín / Invernadero / Botánico / Rosaleda / Patio / Taller (Piedra limpia)
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
        hasRug: false,
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
      final isNobleBedroom = lower.contains('dormitorio') || lower.contains('aposento') || lower.contains('suite');
      return ZoneVisualTheme(
        archetype: ZoneArchetype.bedroom,
        displayName: name ?? 'DORMITORIO',
        tintColor: const ui.Color(0xFFF3ECE6), // Marfil lino cálido
        accentColor: const ui.Color(0xFF8C5C6F), // Malva empolvado
        tileType: isNobleBedroom ? TileType.woodPlanks : TileType.classicTiles,
        icon: Icons.bed_rounded,
        hasRug: isNobleBedroom,
      );
    }

    // 5. Laboratorio / Observatorio / Cúpula / Óptica / Sala de máquinas (Baldosas limpias)
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
        hasRug: false,
      );
    }

    // 6. Galería / Museo / Bóveda / Reliquias / Teatro / Escenario (Mármol limpio)
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
        hasRug: false,
      );
    }

    // 7. Fallback elegante por defecto (Lounge / Salón / Zonas genéricas)
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

    final isExplicitLounge = lower.contains('salón') || lower.contains('salon');
    final genericTileTypes = [
      TileType.woodPlanks,
      TileType.classicTiles,
      TileType.stone,
      TileType.checkerboard,
    ];

    return ZoneVisualTheme(
      archetype: ZoneArchetype.lounge,
      displayName: name ?? 'SALÓN',
      tintColor: tint,
      accentColor: accent,
      tileType: isExplicitLounge ? TileType.carpet : genericTileTypes[zoneIndex % genericTileTypes.length],
      icon: Icons.meeting_room_rounded,
      // Solo habitaciones que explícitamente son salones o como mucho 1 habitación de acento (<= 30%)
      hasRug: isExplicitLounge || (zoneIndex == 0),
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
  /// Confinada estrictamente dentro del perímetro arquitectónico de la habitación
  /// mediante [roomClipPath] para evitar que cruce muros en geometrías L, T o irregulares.
  void renderRug(
    ui.Canvas canvas,
    ui.Path roomClipPath,
    ui.Rect rugRect,
    double cellW,
    double cellH, {
    ui.Offset? visualCenter,
  }) {
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

    final rrect = ui.RRect.fromRectAndRadius(rugRect, const ui.Radius.circular(5.0));

    canvas.save();
    canvas.clipPath(roomClipPath);

    // 1. Sombra suave arrojada por la alfombra
    canvas.drawRRect(
      rrect.shift(const ui.Offset(0, 1.8)),
      ui.Paint()..color = const ui.Color(0x20000000)..style = ui.PaintingStyle.fill,
    );

    // 2. Relleno textil noble de bajo contraste
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
    if (rugRect.width > 32 && rugRect.height > 32) {
      canvas.drawRRect(
        rrect.deflate(3.5),
        ui.Paint()
          ..color = rugBaseColor.withAlpha(110)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }

    // 5. Medallón central sutil
    if (rugRect.width > 45 && rugRect.height > 45) {
      final medallionSize = min(min(rugRect.width, rugRect.height) * 0.35, 34.0);
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

    canvas.restore();
  }

  /// Ambientación contextual del escenario.
  /// Neutralizada en su origen para erradicar cualquier artefacto residual en esquinas.
  void renderAmbientDecoration(
    ui.Canvas canvas,
    ui.Path roomClipPath,
    ui.Rect bounds,
    double cellW,
    double cellH,
  ) {
    // No-op deliberado: la arquitectura limpia no dibuja primitivas ambiguas en esquinas
  }

  /// Estampa el nombre de la habitación con estilo cómic/detective de alta visibilidad:
  /// - Auto-fit dinámico estrictamente acotado entre 9.0 y 13.0 px.
  /// - Word wrapping limpio entre palabras completas (1–3 líneas, cero ellipsis).
  /// - Margen de seguridad respecto a muros (proporcional, >= 6px).
  /// - Borde exterior negro grueso (2.5px) + relleno blanco nítido.
  void renderRoomWatermark({
    required ui.Canvas canvas,
    required ui.Offset visualCenter,
    required ui.Rect roomBounds,
    required double cellWidth,
    required double cellHeight,
    ui.Path? roomClipPath,
  }) {
    final rawText = displayName.toUpperCase().trim();
    if (rawText.isEmpty) return;

    final words = rawText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return;

    // Detectar si la posición visual está confinada en el margen superior de la celda
    final localCellY = visualCenter.dy % cellHeight;
    final isConstrainedTop = localCellY < cellHeight * 0.28;

    // Margen de seguridad respecto a los muros negros: >= 6px, proporcional a tileSize
    final safeMargin = max(6.0, cellWidth * 0.09);
    final maxAvailW = max(30.0, cellWidth - (safeMargin * 2));
    final maxAvailH = isConstrainedTop
        ? max(12.0, cellHeight * 0.22)
        : max(30.0, cellHeight - (safeMargin * 2));

    // 1. Partición estricta entre palabras completas (máximo 3 líneas)
    final lines = isConstrainedTop
        ? words.take(2).toList()
        : _wrapWordsIntoLines(words, maxAvailW, cellWidth);

    // 2. Auto-fit de tamaño de fuente en el rango estricto de 9.0 a 13.0 px
    final longestWordLen = words.map((w) => w.length).reduce(max);
    final longestLineLen = lines.map((l) => l.length).reduce(max);

    double fontSize;
    if (isConstrainedTop) {
      fontSize = (cellWidth * 0.80 / max(longestWordLen, 3)).clamp(7.5, 8.5);
    } else {
      final widthFactor = (maxAvailW * 0.88) / (longestLineLen * 0.58);
      final heightFactor = (maxAvailH * 0.88) / (lines.length * 1.25);
      final wordLimit = (maxAvailW * 0.95) / max(longestWordLen, 3);
      fontSize = min(13.0, min(widthFactor, min(heightFactor, wordLimit))).clamp(9.0, 13.0);
    }

    final formattedText = lines.join('\n');
    final outlineStrokeWidth = (cellWidth * 0.038).clamp(2.0, 2.8);

    // 3. Pasada 1: Contorno exterior negro grueso (2.5px) con remates redondos
    final strokePb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: fontSize,
        height: 1.15,
      ),
    )
      ..pushStyle(ui.TextStyle(
        foreground: ui.Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = outlineStrokeWidth
          ..strokeCap = ui.StrokeCap.round
          ..strokeJoin = ui.StrokeJoin.round
          ..color = const ui.Color(0xFF000000),
        fontWeight: ui.FontWeight.w900,
        letterSpacing: 0.8,
        fontFamily: 'Roboto',
      ))
      ..addText(formattedText);

    final strokeParagraph = strokePb.build()..layout(ui.ParagraphConstraints(width: maxAvailW + 20));

    // 4. Pasada 2: Relleno blanco nítido de alto contraste
    final fillPb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: fontSize,
        height: 1.15,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: const ui.Color(0xFFFFFFFF),
        fontWeight: ui.FontWeight.w900,
        letterSpacing: 0.8,
        fontFamily: 'Roboto',
      ))
      ..addText(formattedText);

    final fillParagraph = fillPb.build()..layout(ui.ParagraphConstraints(width: maxAvailW + 20));

    // 5. Centrado sobre visualCenter
    final textW = fillParagraph.maxIntrinsicWidth;
    final textH = fillParagraph.height;
    final drawOffset = ui.Offset(
      visualCenter.dx - (textW / 2),
      visualCenter.dy - (textH / 2),
    );

    canvas.save();
    if (roomClipPath != null) {
      canvas.clipPath(roomClipPath);
    }
    // Sombra sutil proyectada
    canvas.drawParagraph(strokeParagraph, drawOffset + const ui.Offset(0.5, 1.0));
    // Contorno exterior negro
    canvas.drawParagraph(strokeParagraph, drawOffset);
    // Relleno blanco
    canvas.drawParagraph(fillParagraph, drawOffset);
    canvas.restore();
  }

  /// Distribuye palabras completas en 1, 2 o hasta 3 líneas balanceadas,
  /// garantizando que ninguna palabra se corte a la mitad y cero ellipsis.
  static List<String> _wrapWordsIntoLines(List<String> words, double availW, double cellW) {
    if (words.length <= 1) return words;

    if (words.length == 2) {
      // Si son 2 palabras, preferir 2 líneas a menos que ambas sean muy cortas
      final combinedLen = words[0].length + words[1].length + 1;
      if (combinedLen <= 7 && availW >= cellW * 0.75) {
        return ['${words[0]} ${words[1]}'];
      }
      return [words[0], words[1]];
    }

    if (words.length == 3) {
      // Evaluar si unir las dos primeras o las dos últimas
      if (words[0].length + words[1].length <= 8) {
        return ['${words[0]} ${words[1]}', words[2]];
      } else if (words[1].length + words[2].length <= 8) {
        return [words[0], '${words[1]} ${words[2]}'];
      } else {
        return [words[0], words[1], words[2]];
      }
    }

    // 4 o más palabras: distribuir en 2 o máximo 3 líneas balanceadas
    final totalLen = words.fold<int>(0, (sum, w) => sum + w.length) + words.length - 1;
    final targetLineLen = (totalLen / 2).ceil();
    final lines = <String>[];
    var currentLine = words.first;

    for (int i = 1; i < words.length; i++) {
      final nextWord = words[i];
      final projectedLen = currentLine.length + 1 + nextWord.length;

      if (lines.length < 2 && projectedLen > targetLineLen) {
        lines.add(currentLine);
        currentLine = nextWord;
      } else {
        currentLine = '$currentLine $nextWord';
      }
    }
    lines.add(currentLine);
    return lines.take(3).toList();
  }
}
