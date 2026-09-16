import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart'
    show
        Canvas,
        Color,
        Offset,
        Paint,
        PaintingStyle,
        Path,
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

  // Paleta botánica y elementos especiales
  static const _leafGreenDark = Color(0xFF386341);
  static const _leafGreenMid = Color(0xFF4A8553);
  static const _leafGreenLight = Color(0xFF67A971);
  static const _potTerracotta = Color(0xFFC46A49);
  static const _potSoil = Color(0xFF3B2A1E);
  static const _waterBlue = Color(0xFF459DB3);
  static const _waterRipple = Color(0xFF8CD4E6);
  static const _marbleLight = Color(0xFFF2EEE8);
  static const _marbleShadow = Color(0xFFD8D2C7);

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
    // Salvaguarda visual: garantizar que ningún trazo sobrepase la celda física
    canvas.clipRect(Rect.fromLTWH(0, 0, tileSize, tileSize));

    if (lowerId.contains('cama') || lowerId.contains('bed')) {
      _renderBed(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('silla') || lowerId.contains('chair') || lowerId.contains('sillon') || lowerId.contains('sillón')) {
      _renderChair(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('mesa') && !lowerId.contains('noche')) {
      _renderTable(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('escritorio') || lowerId.contains('desk')) {
      _renderDesk(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('librero') || lowerId.contains('estante') || lowerId.contains('book')) {
      _renderBookshelf(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('armario') || lowerId.contains('wardrobe') || lowerId.contains('closet')) {
      _renderWardrobe(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('maceta') || lowerId.contains('planta') || lowerId.contains('plant') || lowerId.contains('pot')) {
      _renderPlant(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('reloj') || lowerId.contains('clock')) {
      _renderClock(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('fuente') || lowerId.contains('fountain')) {
      _renderFountain(canvas, tileSize, outlinePaint, detailPaint);
    } else if (lowerId.contains('estatua') || lowerId.contains('statue')) {
      _renderStatue(canvas, tileSize, outlinePaint, detailPaint);
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
    final w = size * 0.66;
    final h = size * 0.72;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    // 1. Sombra elíptica arrojada bajo la base de la cama
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

    // 2. Cabecero de madera en la parte superior (con efecto 2.5D)
    final headboardH = h * 0.13;
    final headboardRect = Rect.fromLTWH(x, y, w, headboardH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(headboardRect, const Radius.circular(2.5)),
      Paint()..color = _woodDark,
    );
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

      canvas.drawRRect(
        rrect.shift(const Offset(0, 1.2)),
        Paint()..color = const Color(0x18000000),
      );
      canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFFFFD));
      canvas.drawRRect(rrect, detailPaint);
    }

    // 5. Edredón / colcha doblada en la mitad inferior
    final duvetY = pillowY + pillowH + 3.0;
    final duvetH = (y + h) - duvetY;
    if (duvetH > 5) {
      final duvetRect = Rect.fromLTWH(x + 1.5, duvetY, w - 3, duvetH);
      final duvetRRect = RRect.fromRectAndRadius(duvetRect, const Radius.circular(3.0));

      canvas.drawRRect(duvetRRect, Paint()..color = _linenFold);
      canvas.drawRect(
        Rect.fromLTWH(x + 2, duvetY, w - 4, 3.0),
        Paint()..color = _linenShadow,
      );
      canvas.drawLine(
        Offset(x + 1.5, duvetY),
        Offset(x + w - 1.5, duvetY),
        outlinePaint,
      );
    }
  }

  /// Silla / sillón top-down 2.5D: cojín central, apoyabrazos laterales y respaldo envolvente.
  void _renderChair(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final s = size * 0.64;
    final x = (size - s) / 2;
    final y = (size - s) / 2;

    // 1. Sombra elíptica arrojada bajo el sillón
    _drawDepthShadow(canvas, size / 2, y + s - (s * 0.04), s * 0.90, s * 0.22);

    // 2. Respaldo curvado exterior (cascarón de madera oscura envolvente)
    final backRect = Rect.fromLTWH(x, y, s, s * 0.88);
    final backRRect = RRect.fromRectAndRadius(backRect, Radius.circular(s * 0.35));
    canvas.drawRRect(backRRect, Paint()..color = _woodDark);
    canvas.drawRRect(backRRect, outlinePaint);

    // 3. Cojín central acolchado con volumen y sombra de separación
    final cushionW = s * 0.58;
    final cushionH = s * 0.52;
    final cushionRect = Rect.fromCenter(
      center: Offset(size / 2, y + s * 0.50),
      width: cushionW,
      height: cushionH,
    );
    final cushionRRect = RRect.fromRectAndRadius(cushionRect, const Radius.circular(4.0));

    // Sombra interna del cojín
    canvas.drawRRect(
      cushionRRect.shift(const Offset(0, 1.5)),
      Paint()..color = const Color(0x35000000),
    );
    // Superficie del cojín
    canvas.drawRRect(cushionRRect, Paint()..color = _linenLight);
    // Volumen sutil del asiento
    canvas.drawRRect(
      cushionRRect.deflate(2.0),
      Paint()..color = _linenFold,
    );
    canvas.drawRRect(cushionRRect, detailPaint);

    // 4. Apoyabrazos laterales visibles desde arriba
    final armW = s * 0.16;
    final armH = s * 0.44;
    final armY = y + s * 0.28;

    final leftArm = Rect.fromLTWH(x + 1.5, armY, armW, armH);
    final rightArm = Rect.fromLTWH(x + s - armW - 1.5, armY, armW, armH);

    final leftArmRRect = RRect.fromRectAndRadius(leftArm, const Radius.circular(3.0));
    final rightArmRRect = RRect.fromRectAndRadius(rightArm, const Radius.circular(3.0));

    canvas.drawRRect(leftArmRRect, Paint()..color = _woodMedium);
    canvas.drawRRect(rightArmRRect, Paint()..color = _woodMedium);
    canvas.drawRRect(leftArmRRect, detailPaint);
    canvas.drawRRect(rightArmRRect, detailPaint);
  }

  /// Mesa de comedor / reuniones: tablero biselado 2.5D con highlight y sombra.
  void _renderTable(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.68;
    final h = size * 0.64;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final tableRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(tableRect, const Radius.circular(6.0));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

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

    // 5. Centro pulido de latón
    canvas.drawCircle(tableRect.center, 3.0, Paint()..color = _brassAccent.withAlpha(150));
  }

  /// Escritorio de detective: mesa de trabajo con tapete de cuero, cajoneras y dossier.
  void _renderDesk(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.72;
    final h = size * 0.60;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final deskRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(deskRect, const Radius.circular(3.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

    // 2. Canto 2.5D inferior para sensación de grosor
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y + 2.2, w, h), const Radius.circular(3.5)),
      Paint()..color = _woodDark,
    );

    // 3. Tablero de madera noble
    canvas.drawRRect(rrect, Paint()..color = _woodMedium);
    canvas.drawRRect(rrect, outlinePaint);

    // 4. Líneas divisorias de cajoneras laterales con tiradores de latón
    final drawerOffset = w * 0.20;
    canvas.drawLine(Offset(x + drawerOffset, y), Offset(x + drawerOffset, y + h), detailPaint);
    canvas.drawLine(Offset(x + w - drawerOffset, y), Offset(x + w - drawerOffset, y + h), detailPaint);

    final leftHandle = Offset(x + drawerOffset / 2, deskRect.center.dy);
    final rightHandle = Offset(x + w - (drawerOffset / 2), deskRect.center.dy);
    canvas.drawCircle(leftHandle, 1.5, Paint()..color = _brassAccent);
    canvas.drawCircle(rightHandle, 1.5, Paint()..color = _brassAccent);

    // 5. Tapete de cuero de investigación en el centro
    final padW = w * 0.48;
    final padH = h * 0.65;
    final padRect = Rect.fromCenter(center: deskRect.center, width: padW, height: padH);
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(2.0)),
      Paint()..color = _woodShadow,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(2.0)),
      detailPaint,
    );

    // 6. Hoja / dossier de caso sobre el tapete
    final docRect = Rect.fromLTWH(padRect.left + 3.0, padRect.top + 3.0, padW * 0.42, padH * 0.58);
    canvas.drawRect(docRect, Paint()..color = const Color(0xFFF9F7F1));
    canvas.drawRect(docRect, detailPaint);
  }

  /// Planta / maceta top-down 2.5D: maceta terracota con tierra visible y hojas verdes en abanico.
  void _renderPlant(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final cx = size / 2;
    final cy = size / 2;
    final potRadius = size * 0.23;

    // 1. Sombra elíptica arrojada bajo la maceta
    _drawDepthShadow(canvas, cx, cy + potRadius * 0.35, potRadius * 2.2, potRadius * 0.80);

    // 2. Borde exterior de la maceta de terracota
    canvas.drawCircle(Offset(cx, cy), potRadius, Paint()..color = _potTerracotta);
    canvas.drawCircle(Offset(cx, cy), potRadius, outlinePaint);

    // 3. Tierra oscura de cultivo visible en el interior
    final soilRadius = potRadius * 0.72;
    canvas.drawCircle(Offset(cx, cy), soilRadius, Paint()..color = _potSoil);
    canvas.drawCircle(Offset(cx, cy), soilRadius, detailPaint);

    // 4. Hojas verdes estilizadas que sobresalen en distintas direcciones
    final leafAngles = [
      -pi / 4,
      pi / 4,
      3 * pi / 4,
      -3 * pi / 4,
      -pi / 2,
      pi / 2,
    ];

    final leafLen = size * 0.28;
    final leafWidth = size * 0.09;

    for (int i = 0; i < leafAngles.length; i++) {
      final angle = leafAngles[i];
      final cosA = cos(angle);
      final sinA = sin(angle);

      // Eje de la hoja
      final tipX = cx + cosA * leafLen;
      final tipY = cy + sinA * leafLen;

      final normX = -sinA * leafWidth;
      final normY = cosA * leafWidth;

      final leafPath = Path()
        ..moveTo(cx + cosA * (soilRadius * 0.5), cy + sinA * (soilRadius * 0.5))
        ..quadraticBezierTo(
          cx + cosA * (leafLen * 0.55) + normX,
          cy + sinA * (leafLen * 0.55) + normY,
          tipX,
          tipY,
        )
        ..quadraticBezierTo(
          cx + cosA * (leafLen * 0.55) - normX,
          cy + sinA * (leafLen * 0.55) - normY,
          cx + cosA * (soilRadius * 0.5),
          cy + sinA * (soilRadius * 0.5),
        );

      // Color alternado para volumen
      final leafColor = (i % 2 == 0) ? _leafGreenMid : _leafGreenLight;
      canvas.drawPath(leafPath, Paint()..color = leafColor);
      canvas.drawPath(leafPath, outlinePaint);

      // Nervadura central sutil
      canvas.drawLine(
        Offset(cx, cy),
        Offset(tipX, tipY),
        detailPaint,
      );
    }

    // 5. Brote central
    canvas.drawCircle(Offset(cx, cy), 3.0, Paint()..color = _leafGreenDark);
    canvas.drawCircle(Offset(cx, cy), 3.0, detailPaint);
  }

  /// Reloj de pie antiguo top-down: mueble de madera noble con esfera de reloj y agujas.
  void _renderClock(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.50;
    final h = size * 0.66;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    // 1. Sombra arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

    // 2. Mueble de madera noble
    final bodyRect = Rect.fromLTWH(x, y, w, h);
    final bodyRRect = RRect.fromRectAndRadius(bodyRect, const Radius.circular(4.0));
    canvas.drawRRect(bodyRRect, Paint()..color = _woodDark);
    canvas.drawRRect(bodyRRect, outlinePaint);

    // 3. Cornisa superior de remate
    final corniceRect = Rect.fromLTWH(x - 1.5, y, w + 3.0, h * 0.16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(corniceRect, const Radius.circular(2.0)),
      Paint()..color = _woodMedium,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(corniceRect, const Radius.circular(2.0)),
      detailPaint,
    );

    // 4. Esfera circular del reloj con bisel de latón
    final dialRadius = min(w * 0.36, h * 0.28);
    final dialCenter = Offset(size / 2, y + h * 0.54);

    canvas.drawCircle(dialCenter, dialRadius + 1.5, Paint()..color = _brassAccent);
    canvas.drawCircle(dialCenter, dialRadius, Paint()..color = const Color(0xFFFFFDE7));
    canvas.drawCircle(dialCenter, dialRadius, detailPaint);

    // Manecillas del reloj marcando las 10:10
    canvas.drawLine(
      dialCenter,
      Offset(dialCenter.dx - dialRadius * 0.50, dialCenter.dy - dialRadius * 0.50),
      Paint()..color = _outlineColor..strokeWidth = 1.4..strokeCap = ui.StrokeCap.round,
    );
    canvas.drawLine(
      dialCenter,
      Offset(dialCenter.dx + dialRadius * 0.55, dialCenter.dy - dialRadius * 0.35),
      Paint()..color = _outlineColor..strokeWidth = 1.2..strokeCap = ui.StrokeCap.round,
    );
    canvas.drawCircle(dialCenter, 1.2, Paint()..color = _outlineColor);
  }

  /// Fuente ornamental de jardín: pilón circular de piedra con agua y ondas.
  void _renderFountain(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final cx = size / 2;
    final cy = size / 2;
    final basinRadius = size * 0.32;

    // 1. Sombra arrojada
    _drawDepthShadow(canvas, cx, cy + basinRadius * 0.30, basinRadius * 2.1, basinRadius * 0.80);

    // 2. Brocal de piedra
    canvas.drawCircle(Offset(cx, cy), basinRadius, Paint()..color = const Color(0xFFD3CCC3));
    canvas.drawCircle(Offset(cx, cy), basinRadius, outlinePaint);

    // 3. Poza de agua
    final waterRadius = basinRadius * 0.80;
    canvas.drawCircle(Offset(cx, cy), waterRadius, Paint()..color = _waterBlue);

    // 4. Ondas concéntricas de agua
    canvas.drawCircle(
      Offset(cx, cy),
      waterRadius * 0.55,
      Paint()..color = _waterRipple..style = PaintingStyle.stroke..strokeWidth = 1.0,
    );

    // 5. Surtidor central
    canvas.drawCircle(Offset(cx, cy), basinRadius * 0.22, Paint()..color = const Color(0xFFB5ADA3));
    canvas.drawCircle(Offset(cx, cy), basinRadius * 0.22, detailPaint);
    canvas.drawCircle(Offset(cx, cy), 2.0, Paint()..color = const Color(0xFFFFFFFF));
  }

  /// Estatua / busto sobre pedestal: pedestal de mármol con busto esculpido estrictamente centrado.
  void _renderStatue(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final s = size * 0.60;
    final cx = size / 2;
    final cy = size / 2;

    // 1. Pedestal de mármol centrado
    final plinthRect = Rect.fromCenter(center: Offset(cx, cy), width: s, height: s * 0.80);
    final plinthRRect = RRect.fromRectAndRadius(plinthRect, const Radius.circular(4.0));

    // Sombra arrojada bajo la base del pedestal
    _drawDepthShadow(canvas, cx, plinthRect.bottom - (s * 0.04), s * 0.92, s * 0.22);

    canvas.drawRRect(plinthRRect, Paint()..color = _marbleShadow);
    canvas.drawRRect(plinthRRect, outlinePaint);

    // Plinto superior biselado centrado
    final topRect = Rect.fromCenter(center: Offset(cx, cy), width: s - 4, height: s * 0.74);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(2.5)),
      Paint()..color = _marbleLight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(2.5)),
      detailPaint,
    );

    // 2. Busto clásico esculpido top-down centrado
    final bustCenter = Offset(cx, cy);
    // Hombros
    final shoulders = Rect.fromCenter(center: bustCenter, width: s * 0.62, height: s * 0.30);
    canvas.drawOval(shoulders, Paint()..color = const Color(0xFFEBE5DB));
    canvas.drawOval(shoulders, outlinePaint);

    // Cabeza esculpida
    canvas.drawCircle(bustCenter, s * 0.17, Paint()..color = const Color(0xFFFAF7F2));
    canvas.drawCircle(bustCenter, s * 0.17, outlinePaint);
  }

  /// Librero / estantería: baldas de madera con lomos de libros multicolores sobrios.
  void _renderBookshelf(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.72;
    final h = size * 0.58;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final shelfRect = Rect.fromLTWH(x, y, w, h);

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

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
    final w = size * 0.70;
    final h = size * 0.64;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final wardRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(wardRect, const Radius.circular(2.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

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
    final r = size * 0.25;

    // 1. Halo cálido sutil de luz
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.25,
      Paint()
        ..color = const Color(0xFFFFD54F).withAlpha(38)
        ..style = PaintingStyle.fill,
    );

    // 2. Sombra elíptica arrojada
    _drawDepthShadow(canvas, cx, cy + r * 0.60, r * 1.8, r * 0.60);

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
    final w = size * 0.66;
    final h = size * 0.54;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final chestRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(chestRect, const Radius.circular(2.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

    // 2. Madera maciza
    canvas.drawRRect(rrect, Paint()..color = _woodMedium);
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Banda transversal metálica
    final slatY = y + h * 0.50;
    canvas.drawLine(Offset(x, slatY), Offset(x + w, slatY), detailPaint);

    // 4. Refuerzos en las 4 esquinas con metal
    final cornerSize = 4.5;
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
    final w = size * 0.64;
    final h = size * 0.62;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final fridgeRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(fridgeRect, const Radius.circular(5.0));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

    // 2. Superficie esmaltada clara
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFF1EDE4));
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
    final w = size * 0.68;
    final h = size * 0.60;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final sinkRect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(sinkRect, const Radius.circular(3.5));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

    // 2. Encimera de piedra o acero inoxidable
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFDFD9D0));
    canvas.drawRRect(rrect, outlinePaint);

    // 3. Poza / cubeta del fregadero
    final basinRect = Rect.fromCenter(
      center: Offset(sinkRect.center.dx, sinkRect.center.dy + 2.5),
      width: w * 0.62,
      height: h * 0.58,
    );
    final basinRRect = RRect.fromRectAndRadius(basinRect, const Radius.circular(3.0));
    canvas.drawRRect(basinRRect, Paint()..color = const Color(0xFFC7C0B4));
    canvas.drawRRect(basinRRect, detailPaint);

    // 4. Desagüe central
    canvas.drawCircle(basinRect.center, 2.0, Paint()..color = _metalAccent);

    // 5. Grifo cromado en el borde superior centrado
    final faucetBase = Offset(size / 2, y + 3.5);
    canvas.drawCircle(faucetBase, 2.5, Paint()..color = _metalHighlight);
    canvas.drawLine(
      faucetBase,
      Offset(faucetBase.dx, faucetBase.dy + 4.0),
      Paint()
        ..color = _metalHighlight
        ..strokeWidth = 2.0
        ..strokeCap = ui.StrokeCap.round,
    );
  }

  /// Mueble genérico biselado (fallback elegante).
  void _renderGenericCabinet(Canvas canvas, double size, Paint outlinePaint, Paint detailPaint) {
    final w = size * 0.66;
    final h = size * 0.58;
    final x = (size - w) / 2;
    final y = (size - h) / 2;

    final rect = Rect.fromLTWH(x, y, w, h);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3.0));

    // 1. Sombra elíptica arrojada
    _drawDepthShadow(canvas, size / 2, y + h - (h * 0.04), w * 0.92, h * 0.20);

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
