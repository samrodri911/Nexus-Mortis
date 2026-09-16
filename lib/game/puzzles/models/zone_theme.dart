/// Sets temáticos cerrados de ambientación para los escenarios de Nexus Mortis.
///
/// Cada nivel/caso instancia exactamente UN único tema ambiental y todas sus
/// habitaciones proceden exclusivamente del conjunto definido para ese tema.
///
/// Este modelo actúa exclusivamente como contexto visual/narrativo y no altera
/// bajo ninguna circunstancia las reglas lógicas, el solver ni las deducciones.
enum ZoneTheme {
  classicMansion,
  theaterOpera,
  botanicalGarden,
  museumArchive;

  /// Nombre amigable del tema para la interfaz o presentación.
  String get displayName {
    switch (this) {
      case ZoneTheme.classicMansion:
        return 'La Mansión Clásica';
      case ZoneTheme.theaterOpera:
        return 'Teatro / Ópera';
      case ZoneTheme.botanicalGarden:
        return 'Jardín Botánico / Invernadero';
      case ZoneTheme.museumArchive:
        return 'Museo / Archivo Histórico';
    }
  }

  /// Lista exhaustiva y cerrada de habitaciones oficiales correspondientes al tema.
  List<String> get availableZoneNames {
    switch (this) {
      case ZoneTheme.classicMansion:
        return const [
          'Salón Principal',
          'Biblioteca',
          'Comedor',
          'Cocina',
          'Dormitorio',
          'Despacho',
          'Sala de Juegos',
          'Vestíbulo',
        ];
      case ZoneTheme.theaterOpera:
        return const [
          'Escenario',
          'Palcos',
          'Platea',
          'Camerinos',
          'Foso de Orquesta',
          'Vestíbulo',
          'Sala de Ensayos',
        ];
      case ZoneTheme.botanicalGarden:
        return const [
          'Rosaleda',
          'Orquideario',
          'Pabellón Tropical',
          'Huerto',
          'Cobertizo',
          'Vivero',
          'Estanque',
        ];
      case ZoneTheme.museumArchive:
        return const [
          'Galería de Arte',
          'Bóveda',
          'Sala Clásica',
          'Taller de Restauración',
          'Sala Egipcia',
          'Archivo',
        ];
    }
  }

  /// Habitaciones visualmente nobles o principales del tema (prioritarias para alfombras).
  Set<String> get nobleZoneNames {
    switch (this) {
      case ZoneTheme.classicMansion:
        return const {'Salón Principal', 'Biblioteca', 'Dormitorio'};
      case ZoneTheme.theaterOpera:
        return const {'Escenario', 'Palcos'};
      case ZoneTheme.botanicalGarden:
        return const {'Rosaleda', 'Pabellón Tropical'};
      case ZoneTheme.museumArchive:
        return const {'Galería de Arte', 'Bóveda'};
    }
  }
}
