import 'package:nexus_mortis/game/difficulty/models/difficulty_level.dart';

/// Metadatos necesarios para reconstruir matemáticamente un caso procedimental
/// idéntico sin tener que serializar la estructura completa en la base de datos.
class GeneratedCaseMetadata {
  const GeneratedCaseMetadata({
    required this.rows,
    required this.columns,
    required this.suspects,
    required this.objects,
    required this.difficulty,
    required this.seed,
  });

  final int rows;
  final int columns;
  final int suspects;
  final int objects;
  final DifficultyLevel difficulty;
  final int seed;

  factory GeneratedCaseMetadata.fromJson(Map<String, dynamic> json) {
    return GeneratedCaseMetadata(
      rows: json['rows'] as int,
      columns: json['columns'] as int,
      suspects: json['suspects'] as int,
      objects: json['objects'] as int,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      seed: json['seed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'columns': columns,
      'suspects': suspects,
      'objects': objects,
      'difficulty': difficulty.name,
      'seed': seed,
    };
  }
}
