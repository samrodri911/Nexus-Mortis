import 'dart:math';

import 'package:nexus_mortis/game/puzzles/models/zone_theme.dart';

/// Generador temático determinista de premisas, títulos y nombres ambientales para casos.
///
/// Cada caso selecciona UN único [ZoneTheme] ambiental cerrado y todas sus habitaciones
/// proceden exclusivamente de dicho conjunto temático sin mezclas entre sets.
class MysteryGenerator {
  const MysteryGenerator();

  static const Map<ZoneTheme, List<_ScenarioPremise>> _premisesByTheme = {
    ZoneTheme.classicMansion: [
      _ScenarioPremise(
        title: 'El Secreto de la Mansión Blackwood',
        description:
            'Un crimen sacudió los salones principales durante la noche de tormenta. Deduce la posición de cada persona y descubre quién estaba a solas con la víctima.',
      ),
      _ScenarioPremise(
        title: 'La Conspiración Solariega',
        description:
            'Entre los ecos de la vieja mansión victoriana, la víctima fue hallada en silencio. Reconstruye los movimientos de cada sospechoso para esclarecer los hechos.',
      ),
      _ScenarioPremise(
        title: 'Intriga en la Residencia',
        description:
            'Una velada aristocrática se transformó en un misterio impenetrable. Deduce el paradero exacto de cada invitado mediante las pistas recopiladas.',
      ),
    ],
    ZoneTheme.theaterOpera: [
      _ScenarioPremise(
        title: 'La Última Función del Teatro',
        description:
            'Tras el ensayo general, la víctima fue hallada entre bastidores. Ubica a los sospechosos en el recinto para esclarecer los hechos.',
      ),
      _ScenarioPremise(
        title: 'Crimen en el Foso de la Ópera',
        description:
            'Las notas finales dieron paso a una repentina tragedia en la sala. Determina la ubicación de cada sospechoso para desenmascarar al culpable.',
      ),
      _ScenarioPremise(
        title: 'Misterio Entre Bambalinas',
        description:
            'Durante el intermedio de la gran función, un sospechoso actuó en las sombras. Reconstruye las posiciones para resolver el enigma.',
      ),
    ],
    ZoneTheme.botanicalGarden: [
      _ScenarioPremise(
        title: 'Misterio en el Real Jardín',
        description:
            'La víctima fue hallada sin vida entre los senderos y estanques del botánico. Reconstruye los movimientos de cada sospechoso.',
      ),
      _ScenarioPremise(
        title: 'La Sombra del Invernadero',
        description:
            'Bajo las cristaleras del pabellón botánico ocurrió un suceso fatal. Deduce el paradero de cada persona en las distintas áreas verdes.',
      ),
      _ScenarioPremise(
        title: 'El Enigma de la Rosaleda',
        description:
            'Entre las flores exóticas y la vegetación tupida yacen las respuestas del caso. Ubica a cada testigo con rigor deductivo.',
      ),
    ],
    ZoneTheme.museumArchive: [
      _ScenarioPremise(
        title: 'La Intriga del Museo Histórico',
        description:
            'En mitad de la noche, las alarmas de las bóvedas se activaron. Averigua dónde se hallaba cada testigo para resolver el enigma.',
      ),
      _ScenarioPremise(
        title: 'El Enigma de la Gran Galería',
        description:
            'Varios visitantes recorrían las salas de exhibición cuando ocurrió el incidente. Deduce sus posiciones mediante las pistas recopiladas.',
      ),
      _ScenarioPremise(
        title: 'El Secreto del Archivo Central',
        description:
            'Entre documentos antiguos y reliquias invaluables, un crimen fue perpetrado. Deduce la posición de cada sospechoso.',
      ),
    ],
  };

  /// Genera un contexto narrativo completo y un conjunto cerrado de habitaciones a partir de una semilla.
  GeneratedMystery generate(int seed, int zoneCount, {ZoneTheme? forcedTheme}) {
    final rand = Random(seed);
    final theme = forcedTheme ?? ZoneTheme.values[rand.nextInt(ZoneTheme.values.length)];
    final premises = _premisesByTheme[theme] ?? _premisesByTheme[ZoneTheme.classicMansion]!;
    final premise = premises[rand.nextInt(premises.length)];

    final allNames = theme.availableZoneNames;
    // La habitación principal (noble) siempre se incluye como primera opción,
    // y el resto de habitaciones del set se barajan determinísticamente.
    final primaryRoom = allNames.first;
    final otherRooms = allNames.sublist(1).toList()..shuffle(rand);
    final candidatePool = [primaryRoom, ...otherRooms];

    final selectedZones = <String>[];
    for (int i = 0; i < zoneCount; i++) {
      if (i < candidatePool.length) {
        selectedZones.add(candidatePool[i]);
      } else {
        selectedZones.add(candidatePool[i % candidatePool.length]);
      }
    }

    return GeneratedMystery(
      title: premise.title,
      description: premise.description,
      zoneNames: selectedZones,
      theme: theme,
    );
  }
}

class _ScenarioPremise {
  const _ScenarioPremise({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class GeneratedMystery {
  const GeneratedMystery({
    required this.title,
    required this.description,
    required this.zoneNames,
    required this.theme,
  });

  final String title;
  final String description;
  final List<String> zoneNames;
  final ZoneTheme theme;
}
