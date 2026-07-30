import 'package:nexus_mortis/game/progression/models/player_progress.dart';

/// Define las operaciones de persistencia del progreso del jugador.
/// Permite aislar el dominio de la tecnología específica de almacenamiento (Isar, Hive, SQL, etc.).
abstract class ProgressRepository {
  /// Carga el progreso del jugador desde el almacenamiento.
  /// Si no existe, debe retornar una instancia vacía (ej: `PlayerProgress.empty()`).
  Future<PlayerProgress> loadProgress();

  /// Guarda el estado actual del progreso del jugador.
  Future<void> saveProgress(PlayerProgress progress);

  /// Elimina todo el progreso (útil para pruebas o reseteos).
  Future<void> clearProgress();
}
