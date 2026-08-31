import 'dart:math';

/// Generador temático determinista de premisas, títulos y nombres ambientales para casos.
class MysteryGenerator {
  const MysteryGenerator();

  static const List<_ScenarioTemplate> _scenarios = [
    _ScenarioTemplate(
      title: 'El Secreto de la Mansión Blackwood',
      description:
          'Un crimen sacudió los salones principales durante la noche de tormenta. Deduce la posición de cada persona y descubre quién estaba a solas con la víctima.',
      zoneNames: ['Salón Principal', 'Galería de Arte', 'Biblioteca', 'Conservatorio', 'Bodega'],
    ),
    _ScenarioTemplate(
      title: 'La Sombra en el Observatorio',
      description:
          'La cúpula astronómica se convirtió en la escena de un misterio. Reconstruye el paradero de los presentes para desenmascarar al culpable.',
      zoneNames: ['Cúpula Central', 'Laboratorio Óptico', 'Sala de Cartografía', 'Terraza Este', 'Archivo Celestial'],
    ),
    _ScenarioTemplate(
      title: 'La Última Función del Teatro',
      description:
          'Tras el ensayo general, la víctima fue hallada entre bastidores. Ubica a los sospechosos en el recinto para esclarecer los hechos.',
      zoneNames: ['Escenario', 'Palcos Reales', 'Camerinos', 'Foso de Orquesta', 'Vestíbulo'],
    ),
    _ScenarioTemplate(
      title: 'El Enigma de la Gran Galería',
      description:
          'Varios visitantes recorrían las salas de exhibición cuando ocurrió el incidente. Deduce sus posiciones mediante las pistas recopiladas.',
      zoneNames: ['Sala Egipcia', 'Pabellón Renacentista', 'Bóveda de Reliquias', 'Taller de Restauración', 'Patio de Esculturas'],
    ),
    _ScenarioTemplate(
      title: 'Misterio en el Real Jardín',
      description:
          'La víctima fue hallada sin vida entre los senderos y estanques del botánico. Reconstruye los movimientos de cada sospechoso.',
      zoneNames: ['Pabellón Tropical', 'Rosaleda Victoriana', 'Estanque de Lotos', 'Vivero de Orquídeas', 'Laboratorio Botánico'],
    ),
    _ScenarioTemplate(
      title: 'La Intriga del Museo Arqueológico',
      description:
          'En mitad de la noche, las alarmas de las bóvedas se activaron. Averigua dónde se hallaba cada testigo para resolver el enigma.',
      zoneNames: ['Cámara Funeraria', 'Ala Clásica', 'Sala Medieval', 'Patio de Columnas', 'Gabinete Numismático'],
    ),
  ];

  /// Genera un contexto narrativo completo a partir de una semilla.
  GeneratedMystery generate(int seed, int zoneCount) {
    final rand = Random(seed);
    final template = _scenarios[rand.nextInt(_scenarios.length)];

    final shuffledZones = List<String>.from(template.zoneNames)..shuffle(rand);
    final selectedZones = <String>[];

    for (int i = 0; i < zoneCount; i++) {
      if (i < shuffledZones.length) {
        selectedZones.add(shuffledZones[i]);
      } else {
        selectedZones.add('Área #${i + 1}');
      }
    }

    return GeneratedMystery(
      title: template.title,
      description: template.description,
      zoneNames: selectedZones,
    );
  }
}

class _ScenarioTemplate {
  const _ScenarioTemplate({
    required this.title,
    required this.description,
    required this.zoneNames,
  });

  final String title;
  final String description;
  final List<String> zoneNames;
}

class GeneratedMystery {
  const GeneratedMystery({
    required this.title,
    required this.description,
    required this.zoneNames,
  });

  final String title;
  final String description;
  final List<String> zoneNames;
}
