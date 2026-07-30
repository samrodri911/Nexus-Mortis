import 'package:isar/isar.dart';

part 'case_progress_embedded.g.dart';

/// Modelo de base de datos para almacenar el progreso de un caso dentro de la entidad principal.
@embedded
class CaseProgressEmbedded {
  /// El ID del caso completado.
  late String caseId;

  /// Si fue completado (siempre true si está en esta lista, pero se guarda por estructura).
  late bool completed;

  /// Estrellas obtenidas en este caso.
  late int starsEarned;
}
