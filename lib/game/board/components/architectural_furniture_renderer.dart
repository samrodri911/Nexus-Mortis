import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart'
    show
        Canvas,
        Color,
        Offset,
        Paint,
        PaintingStyle,
        Radius,
        Rect,
        RRect;

/// Renderizador vectorial de mobiliario arquitectónico top-down para objetos lógicos.
///
/// Estilo visual: Cómic + Outline + Ilustración Top-Down + 2.5D sutil (Murdoku / Layton / Ace Attorney).
/// - Siluetas limpias, legibles y reconocibles a primera vista (sin etiquetas de texto).
/// - Sombras elípticas translúcidas arrojadas en la base para separar el mueble del piso.
/// - Contornos de tinta negra responsive (2–3px) con remates y uniones redondeadas.
/// - Ocupa entre el 65% y 80% de la celda, con margen generoso para interacción y marcas.
class ArchitecturalFurnitureRenderer {
  const ArchitecturalFurnitureRenderer();

  // Paleta arquitectónica estilizada para cómic detective
  static const _outlineColor = Color(0xFF161514);
  static const _woodLight = Color(0xFFDAC7B2);
  static const _woodMedium = Color(0xFFB89F86);
  static const _woodDark = Color(0xFF7A6552);
  static const _woodShadow = Color(0xFF5A493B);
  static const _linenLight = Color(0xFFFAF7F0);
  static const _linenFold = Color(0xFFE8DFD0);
  static const _linenShadow = Color(0xFFD4C8B6);
  static const _metalAccent = Color(0xFF54504B);
  static const _metalHighlight = Color(0xFF88847E);
  static const _brassAccent = Color(0xFFC4A45A);

  void render({
    required Canvas canvas,
    required String objectId,
    String? objectLabel,
    required Rect cellRect,
    required double tileSize,
  }) {
    final lowerId = objectId.toLowerCase();

    // Grosores responsive calculados a partir de tileSize
    final outlineWidth = (tileSize * 0.038).clamp(1.8, 3.0);
    final detailWidth = (tileSize * 0.020).clamp(0.9, 1.6);

    final outlinePaint = Paint()
      ..color = _outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineWidth
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeCap = ui.StrokeCap.round;

    final detailPaint = Paint()
      ..color = _outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = detailWidth
      ..strokeJoin = ui.StrokeJoin.round
      ..strokeCap = ui.StrokeCap.round;

    canvas.save();
    canvas.translate(cellRect.left, cellRect.top);

    if (lowerId.contains('cama') || lowerId.contains('bed')) {
      _renderBed(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('silla') || lowerId.contains('chair')) {
      _renderChair(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('mesa') && !lowerId.contains('noche')) {
      _renderTable(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('escritorio') || lowerId.contains('desk')) {
      _renderDesk(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('librero') || lowerId.contains('estante') || lowerId.contains('book')) {
      _renderBookshelf(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('armario') || lowerId.contains('wardrobe') || lowerId.contains('closet')) {
      _renderWardrobe(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('lampara') || lowerId.contains('lámpara') || lowerId.contains('lamp')) {
      _renderLamp(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('caja') || lowerId.contains('baul') || lowerId.contains('baúl') || lowerId.contains('chest')) {
      _renderChest(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('nevera') || lowerId.contains('frigor') || lowerId.contains('fridge')) {
      _renderFridge(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('fregadero') || lowerId.contains('lavabo') || lowerId.contains('sink')) {
      _renderSink(canvas, tileSize, outlinePaint, detailPaint);
    } else {
      _renderGenericCabinet(canvas, tileSize, outlinePaint, detailPaint);
    }

    canvas.restore();
  }

  /// Dibuja la sombra elíptica arrojada en la base del mueble para separarlo visualmente del piso.
  void _drawDepthShadow(Canvas canvas, double cx, double cy, double width, double height) {
    final shadowRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: width,
      height: height,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = const Color(0x30000000)
        ..style = PaintingStyle.fill,
    );
  }

  /// Cama top-down 2.5D: cabecero con relieve, dos almohadas tridimensionales y edredón doblado.
  void _renderBed(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.70;
    final h = size * 0.82;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    // 1. Sombra elíptica arrojada bajo la base de la cama
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.06), w * 0.96, h * 0.26);

    // 2. Cabecero de madera en la parte superior (con efecto 2.5D)
    final headboardH = h * 0.13;
    final headboardRect = Rect.fromLTWH(x, y, w, headboardH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headboardRect, const Radius.circular(2.5)),
      Paint()..color = _woodDark,
    );
    // Veta / highlight superior de la madera
    canvas.drawLine(
      Offset(x + 2, y + 1.2),
      Offset(x + w - 2, y + 1.2),
      Paint()..color = _woodLight.withAlpha(150)..strokeWidth = 1.0,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headboardRect, const Radius.circular(2.5)),
      outlinePaint,
    );

    // 3. Colchón / base
    final mattressRect = Rect.fromLTWH(x + 1.5, y + headboardH - 1, w - 3, h - headboardH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(mattressRect, const Radius.circular(3.5)),
      Paint()..color = _linenLight,
    );
    // Sombra en el canto derecho e inferior del colchón
    canvas.drawRRect(
      RRect.fromRectAndRadius(mattressRect, const Radius.circular(3.5)),
      outlinePaint,
    );

    // 4. Dos almohadas con volumen y sombra
    final pillowW = (w - 10) / 2;
    final pillowH = h * 0.18;
    final pillowY = y + headboardH + 2.5;

    for (int i = 0; i < 2; i++) {
      final px = x + 3.5 + (i * (pillowW + 3));
      final pRect = Rect.fromLTWH(px, pillowY, pillowW, pillowH);
      final rrect = RRect.fromRectAndRadius(pRect, const Radius.circular(2.5));

      // Sombra propia de la almohada
      canvas.drawRRect(
        rrect.shift(const Offset(0, 1.2)),
        Paint()..color = const Color(0x18000000),
      );
      // Relleno blanco lino
      canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFFFFD));
      // Contorno suave de la almohada
      canvas.drawRRect(rrect, detailPaint);
    }

    // 5. Edredón / colcha doblada en la mitad inferior
    final duvetY = pillowY + pillowH + 3.0;
    final duvetH = (y + h) - duvetY;
    if (duvetH > 5) {
      final duvetRect = Rect.fromLTWH(x + 1.5, duvetY, w - 3, duvetH);
      final duvetRRect = RRect.fromRectAndRadius(duvetRect, const Radius.circular(3.0));

      canvas.drawRRect(duvetRRect, Paint()..color = _linenFold);
      // Sombra inferior del embozo
      canvas.drawRect(
        Rect.fromLTWH(x + 2, duvetY, w - 4, 3.0),
        Paint()..color = _linenShadow,
      );
      // Línea de embozo / pliegue de la sábana
      canvas.drawLine(
        Offset(x + 1.5, duvetY),
        Offset(x + w - 1.5, duvetY),
        outlinePaint,
      );
    }
  }

  /// Silla / sillón top-down 2.5D: asiento acolchado con respaldo envolvente curvado.
  void _renderChair(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final s = size * 0.65;
    final x = (size - s) / 2;
    final y = (size - s) / 2;

    // 1. Sombra elíptica arrojada bajo la silla
    _drawDepthShadow(canvas, size / 2, y + s - (s * 0.05), s * 0.92, s * 0.30);

    // 2. Asiento acolchado
    final seatRect = Rect.fromLTWH(x + 3.5, y + 6.5, s - 7, s - 9);
    final seatRRect = RRect.fromRectAndRadius(seatRect, const Radius.circular(4.5));

    canvas.drawRRect(seatRRect, Paint()..color = _linenFold);
    // Sombra interior de profundidad en el asiento
    canvas.drawRRect(
      seatRRect.deflate(2.0),
      Paint()..color = _linenShadow.withAlpha(120),
    );
    canvas.drawRRect(seatRRect, detailPaint);

    // 3. Respaldo curvado superior y brazos envolventes (estilo cómic con trazo grueso)
    final backPath = ui.Path();
    backPath.moveTo(x + 1.5, y + s * 0.68);
    backPath.lineTo(x + 1.5, y + 5);
    backPath.quadraticBezierTo(size / 2, y - 2.5, x + s - 1.5, y + 5);
    backPath.lineTo(x + s - 1.5, y + s * 0.68);

    final backPaint = Paint()
      ..color = _woodDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(2.8, size * 0.065)
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round;

    canvas.drawPath(backPath, backPaint);
    canvas.drawPath(backPath, outlinePaint);
  }

  /// Mesa de comedor / reuniones: tablero biselado 2.5D con highlight y sombra.
  void _renderTable(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.74;
    final h = size * 0.70;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final tableRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(tableRect, const Radius.circular(6.0));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.06), w * 0.96, h * 0.28);

    // 2. Base / canto inferior 2.5D
    final edgeRect = Rect.fromLTWH(x, y + 2.0, w, h);
    canvas.drawRRect(
      RRect.fromRectAndRadius(edgeRect, const Radius.circular(6.0)),
      Paint()..color = _woodDark,
    );

    // 3. Tablero principal
    canvas.drawRRect(rrect, Paint()..color = _woodLight);
    canvas.drawRRect(rrect, outlinePaint);

    // 4. Bisel interior elegante
    canvas.drawRRect(
      rrect.deflate(max(2.5, size * 0.05)),
      Paint()
        ..color = _woodMedium.withAlpha(160)
        ..style = PaintingStyle.stroke
        ..strokeWidth = detailPaint.strokeWidth,
    );

    // 5. Pequeño detalle: veta central o centro pulido
    canvas.drawCircle(tableRect.center, 3.0, Paint()..color = _brassAccent.withAlpha(150));
  }

  /// Escritorio de detective: mesa de trabajo con tapete de cuero, cajoneras y dossier.
  void _renderDesk(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.78;
    final h = size * 0.66;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final deskRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(deskRect, const Radius.circular(3.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.98, h * 0.26);

    // 2. Canto 2.5D inferior
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y + 2.0, w, h), const Radius.circular(3.5)),
      Paint()..color = _woodDark,
    );

    // 3. Tablero de madera noble
    canvas.drawRRect(rrect, Paint()..color = _woodMedium);
    canvas.drawRRect(rrect, outlinePaint);

    // 4. Tapete de cuero de investigación en el centro
    final padW = w * 0.52;
    final padH = h * 0.62;
    final padRect = Rect.fromCenter(center: deskRect.center, width: padW, height: padH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(2.0)),
      Paint()..color = _woodShadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(2.0)),
      detailPaint,
    );

    // 5. Documento / hoja de detective sobre el tapete
    final docRect = Rect.fromLTWH(padRect.left + 3.0, padRect.top + 3.0, padW * 0.38, padH * 0.55);
    canvas.drawRect(docRect, Paint()..color = const Color(0xFFF9F7F1));
    canvas.drawRect(docRect, detailPaint);

    // 6. Líneas divisorias de cajoneras laterales con tiradores de latón
    final drawerOffset = w * 0.18;
    canvas.drawLine(Offset(x + drawerOffset, y), Offset(x + drawerOffset, y + h), detailPaint);
    canvas.drawLine(Offset(x + w - drawerOffset, y), Offset(x + w - drawerOffset, y + h), detailPaint);

    final leftHandle = Offset(x + drawerOffset / 2, deskRect.center.dy);
    final rightHandle = Offset(x + w - (drawerOffset / 2), deskRect.center.dy);
    canvas.drawCircle(leftHandle, 1.4, Paint()..color = _brassAccent);
    canvas.drawCircle(rightHandle, 1.4, Paint()..color = _brassAccent);
  }

  /// Librero / estantería: baldas de madera con lomos de libros multicolores sobrios.
  void _renderBookshelf(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.80;
    final h = size * 0.64;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final shelfRect = Rect.fromLTWH(x, y, w, h);

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.98, h * 0.25);

    // 2. Estructura exterior de roble oscuro
    canvas.drawRRect(
      RRect.fromRectAndRadius(shelfRect, const Radius.circular(2.5)),
      Paint()..color = _woodDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shelfRect, const Radius.circular(2.5)),
      outlinePaint,
    );

    // 3. Fondo interior del estante
    final innerRect = shelfRect.deflate(2.8);
    canvas.drawRect(innerRect, Paint()..color = _linenFold);

    // 4. Libros ordenados con paleta sobria detective
    final bookColors = [
      const Color(0xFF6B3E43), // Burdeos
      const Color(0xFF344A63), // Azul marino
      const Color(0xFF435741), // Verde bosque
      const Color(0xFF826E3E), // Ámbar
      const Color(0xFF564966), // Púrpura apagado
      const Color(0xFF695444), // Cuero pardo
    ];

    final bookW = max(3.2, (innerRect.width - 4) / 10);
    double curX = innerRect.left + 2;
    int idx = 0;

    while (curX + bookW <= innerRect.right - 2) {
      final color = bookColors[idx % bookColors.length];
      final bRect = Rect.fromLTWH(curX, innerRect.top + 1, bookW - 0.5, innerRect.height - 2);
      canvas.drawRect(bRect, Paint()..color = color);
      canvas.drawRect(
        bRect,
        Paint()
          ..color = _outlineColor.withAlpha(100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6,
      );
      curX += bookW;
      idx++;
    }
  }

  /// Armario / ropero: moldura superior biselada, puertas con bisagras y tiradores.
  void _renderWardrobe(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.78;
    final h = size * 0.70;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final wardRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(wardRect, const Radius.circular(2.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.98, h * 0.26);

    // 2. Madera del cuerpo
    canvas.drawRRect(rrect, Paint()..color = _woodMedium);
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Moldura de cornisa superior biselada
    final corniceRect = Rect.fromLTWH(x, y, w, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(corniceRect, const Radius.circular(2.0)),
      Paint()..color = _woodDark,
    );
    canvas.drawLine(
      Offset(x + 2, y + 1.2),
      Offset(x + w - 2, y + 1.2),
      Paint()..color = _woodLight.withAlpha(140)..strokeWidth = 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(corniceRect, const Radius.circular(2.0)),
      detailPaint,
    );

    // 4. Línea de división central de puertas
    final midX = wardRect.center.dx;
    canvas.drawLine(
      Offset(midX, y + h * 0.16),
      Offset(midX, y + h - 2),
      outlinePaint,
    );

    // 5. Tiradores de latón
    final handleY = y + h * 0.55;
    final handlePaint = Paint()..color = _brassAccent;
    canvas.drawCircle(Offset(midX - 3.0, handleY), 1.6, handlePaint);
    canvas.drawCircle(Offset(midX + 3.0, handleY), 1.6, handlePaint);
  }

  /// Lámpara de pie: base de latón, fuste y tulipa con halo cálido radial sutil.
  void _renderLamp(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final cx = size / 2;
    final cy = size / 2;
    final r = size * 0.30;

    // 1. Halo cálido sutil de luz
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.35,
      Paint()
        ..color = const Color(0xFFFFD54F).withAlpha(38)
        ..style = PaintingStyle.fill,
    );

    // 2. Sombra elíptica arrojada
    _drawDepthShadow(canvas, cx, cy + r * 0.70, r * 2.0, r * 0.70);

    // 3. Pantalla circular cónica top-down
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = _linenLight);
    canvas.drawCircle(Offset(cx, cy), r, outlinePaint);

    // 4. Anillo interior biselado
    canvas.drawCircle(Offset(cx, cy), r * 0.58, Paint()..color = const Color(0xFFFFF9E6));
    canvas.drawCircle(Offset(cx, cy), r * 0.58, detailPaint);

    // 5. Remate de latón central
    canvas.drawCircle(Offset(cx, cy), 2.5, Paint()..color = _brassAccent);
  }

  /// Baúl / caja fuerte: cofre acorazado con esquineras de metal, remaches y cerradura.
  void _renderChest(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.70;
    final h = size * 0.60;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final chestRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(chestRect, const Radius.circular(2.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.94, h * 0.28);

    // 2. Madera maciza
    canvas.drawRRect(rrect, Paint()..color = _woodMedium);
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Banda transversal metálica
    final slatY = y + h * 0.50;
    canvas.drawLine(Offset(x, slatY), Offset(x + w, slatY), detailPaint);

    // 4. Refuerzos en las 4 esquinas con metal
    final cornerSize = 4.8;
    final cornerPaint = Paint()..color = _metalAccent;
    canvas.drawRect(Rect.fromLTWH(x, y, cornerSize, cornerSize), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(x + w - cornerSize, y, cornerSize, cornerSize), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(x, y + h - cornerSize, cornerSize, cornerSize), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(x + w - cornerSize, y + h - cornerSize, cornerSize, cornerSize), cornerPaint);

    // 5. Cerradura de latón o dial
    final lockRect = Rect.fromCenter(center: Offset(chestRect.center.dx, slatY), width: 5.0, height: 5.0);
    canvas.drawRect(lockRect, Paint()..color = _brassAccent);
    canvas.drawRect(lockRect, detailPaint);
  }

  /// Nevera / frigorífico vintage: silueta top-down con esquinas redondeadas y tirador cromado.
  void _renderFridge(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.68;
    final h = size * 0.66;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final fridgeRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(fridgeRect, const Radius.circular(5.0));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.94, h * 0.26);

    // 2. Superficie esmaltada clara
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFF1EDE4));
    // Sombreado de volumen 2.5D en el lado derecho
    canvas.drawRect(
      Rect.fromLTWH(x + w - 4, y + 2, 4, h - 4),
      Paint()..color = const Color(0xFFDDD7CC),
    );
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Línea divisoria de puerta frontal
    canvas.drawLine(
      Offset(x + 2, y + h * 0.38),
      Offset(x + w - 2, y + h * 0.38),
      detailPaint,
    );

    // 4. Tirador vertical cromado
    final handleRect = Rect.fromLTWH(x + w - 5.5, y + h * 0.44, 2.4, h * 0.28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(1.0)),
      Paint()..color = _metalHighlight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(1.0)),
      detailPaint,
    );
  }

  /// Fregadero / encimera: superficie con poza de agua y grifo cromado top-down.
  void _renderSink(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.74;
    final h = size * 0.66;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final sinkRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(sinkRect, const Radius.circular(3.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.96, h * 0.26);

    // 2. Encimera de piedra o acero inoxidable
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFDFD9D0));
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Poza / cubeta del fregadero
    final basinRect = Rect.fromCenter(
      center: Offset(sinkRect.center.dx, sinkRect.center.dy + 3),
      width: w * 0.62,
      height: h * 0.58,
    );
    final basinRRect = RRect.fromRectAndRadius(basinRect, const Radius.circular(3.0));
    canvas.drawRRect(basinRRect, Paint()..color = const Color(0xFFC7C0B4));
    canvas.drawRRect(basinRRect, detailPaint);

    // 4. Desagüe central
    canvas.drawCircle(basinRect.center, 2.0, Paint()..color = _metalAccent);

    // 5. Grifo cromado en el borde superior
    final faucetBase = Offset(sinkRect.center.dx, y + 4.5);
    canvas.drawCircle(faucetBase, 2.5, Paint()..color = _metalHighlight);
    canvas.drawLine(
      faucetBase,
      Offset(faucetBase.dx, faucetBase.dy + 4.5),
      Paint()
        ..color = _metalHighlight
        ..strokeWidth = 2.0
        ..strokeCap = ui.StrokeCap.round,
    );
  }

  /// Mueble genérico biselado (fallback elegante).
  void _renderGenericCabinet(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.72;
    final h = size * 0.65;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final rect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.05), w * 0.94, h * 0.26);

    // 2. Tablero de madera
    canvas.drawRRect(rrect, Paint()..color = _woodLight);
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Bisel interior
    canvas.drawRRect(
      rrect.deflate(3.0),
      Paint()
        ..color = _woodMedium.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = detailPaint.strokeWidth,
    );
  }
}
