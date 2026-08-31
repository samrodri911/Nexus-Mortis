import 'package:isar/isar.dart';

part 'campaign_case_entity.g.dart';

/// Modelo de persistencia en Isar para casos de campaña generados procedimentalmente.
@collection
class CampaignCaseEntity {
  /// ID autoincremental de Isar.
  Id id = Isar.autoIncrement;

  /// ID lógico único del caso (ej: "case_004", "case_005").
  @Index(unique: true, replace: true)
  late String caseId;

  /// Índice ordinal en la campaña (4, 5, 6...).
  late int caseIndex;

  /// Título generado del caso.
  late String title;

  /// Descripción del misterio.
  late String description;

  /// Nombre de la dificultad (easy, medium, hard, etc.).
  late String difficulty;

  /// Puntuación continua de dificultad calculada (0..100).
  int difficultyScore = 0;

  /// Semilla matemática utilizada en la generación.
  late int seed;

  late int rows;
  late int columns;
  late int suspects;
  late int objects;

  /// Snapshot JSON completo e inmutable del CaseData generado.
  String? caseJson;

  /// ID del caso predecesor requerido para desbloquear este caso.
  String? requiredCaseId;
}
