import 'package:nexus_mortis/game/puzzles/data/demo_case_001.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_002.dart';
import 'package:nexus_mortis/game/puzzles/data/demo_case_003.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Registro estático temporal de los casos disponibles en el juego.
///
/// Más adelante, estos casos podrían ser cargados dinámicamente o provenir
/// del PuzzleGenerator, pero por ahora se definen en memoria.
class CaseRegistry {
  CaseRegistry._();

  /// Lista ordenada de casos que componen la "campaña" actual.
  static final List<CaseData> cases = [
    demoCase001,
    demoCase002,
    demoCase003,
  ];

  /// Busca un caso por su ID. Retorna null si no existe.
  static CaseData? getCase(String id) {
    for (final caseData in cases) {
      if (caseData.id == id) return caseData;
    }
    return null;
  }
}
