import 'dart:async';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';

/// Define una fuente abstracta de casos, aislando al orquestador de cómo se
/// crean, almacenan o generan matemáticamente.
abstract class CaseSource {
  /// Recupera un caso por su identificador.
  /// La asincronía está preparada para futuras implementaciones como descargas (Cloud).
  FutureOr<CaseData?> getCase(String id);
}
