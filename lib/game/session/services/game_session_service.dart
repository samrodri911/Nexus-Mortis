import 'package:flutter/foundation.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_definition.dart';
import 'package:nexus_mortis/game/achievements/services/achievement_service.dart';
import 'package:nexus_mortis/game/board/controllers/board_controller.dart';
import 'package:nexus_mortis/game/progression/models/reward_data.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';
import 'package:nexus_mortis/game/results/services/star_calculator.dart';
import 'package:nexus_mortis/game/save_state/models/active_game_state.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/models/game_session.dart';
import 'package:nexus_mortis/game/session/models/game_session_status.dart';
import 'package:nexus_mortis/game/statistics/services/statistics_service.dart';

/// Servicio orquestador del ciclo de vida de una partida en Nexus Mortis.
///
/// Coordina la transición entre estados (start, resume, pause, complete, abandon),
/// asegurando la sincronización atómica e idempotente entre el estado lógico, persistencia,
/// progresión, estadísticas y logros.
class GameSessionService {
  GameSessionService({
    required this.progressionService,
    required this.saveGameService,
    required this.statisticsService,
    required this.achievementService,
    this.starCalculator = const StarCalculator(),
  });

  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final StatisticsService statisticsService;
  final AchievementService achievementService;
  final StarCalculator starCalculator;

  final ValueNotifier<GameSession?> sessionNotifier = ValueNotifier<GameSession?>(null);

  BoardController? _activeController;
  CaseData? _currentCase;
  ActiveGameState? _activeState;

  // Métricas de la sesión actual en memoria
  int _hintsUsed = 0;
  int _mistakes = 0;
  Duration _accumulatedDuration = Duration.zero;
  DateTime? _lastActiveSegmentStart;

  GameResult? _lastResult;
  List<AchievementDefinition> _lastUnlockedAchievements = [];

  GameSession? get currentSession => sessionNotifier.value;

  bool get hasActiveSession =>
      currentSession != null &&
      (currentSession!.status == GameSessionStatus.playing ||
       currentSession!.status == GameSessionStatus.awaitingKiller);

  CaseData? get currentCase => _currentCase;

  ActiveGameState? get activeState => _activeState;

  int get hintsUsed => _hintsUsed;

  int get mistakes => _mistakes;

  GameResult? get lastResult => _lastResult;

  List<AchievementDefinition> get lastUnlockedAchievements => _lastUnlockedAchievements;

  /// Registra el uso exitoso de una pista.
  void recordHintUsed() {
    _hintsUsed++;
  }

  /// Registra una acción errónea o corrección explícita del jugador.
  void recordMistake() {
    _mistakes++;
  }

  /// Registra el [BoardController] activo y enlaza eventos de error.
  void registerController(BoardController controller) {
    _activeController = controller;
    _activeController?.onMistakeOccurred = recordMistake;
  }

  /// Desregistra el [BoardController] al salir o destruir la vista del juego.
  void unregisterController() {
    _activeController?.onMistakeOccurred = null;
    _activeController = null;
  }

  /// Inicia una nueva sesión de juego para un [CaseData].
  Future<GameSession> startNewGame(CaseData caseData) async {
    // Si ya existe una sesión en juego para este mismo caso, la retornamos (idempotente).
    if (hasActiveSession) {
      if (currentSession!.caseId == caseData.id) {
        return currentSession!;
      }
      throw StateError('Cannot start a new game session while another session is playing.');
    }

    // Proteger contra sobreescritura accidental de otra partida guardada en disco.
    final savedGame = await saveGameService.loadGame();
    if (savedGame != null && savedGame.caseId != caseData.id) {
      throw StateError('Cannot start a new game session because a different game is saved on disk.');
    }

    final now = DateTime.now();
    _hintsUsed = 0;
    _mistakes = 0;
    _accumulatedDuration = Duration.zero;
    _lastActiveSegmentStart = now;
    _lastResult = null;
    _lastUnlockedAchievements = [];

    final session = GameSession(
      caseId: caseData.id,
      origin: caseData.origin,
      status: GameSessionStatus.playing,
      startedAt: now,
    );

    _currentCase = caseData;
    _activeState = null;
    sessionNotifier.value = session;
    return session;
  }

  /// Reanuda una partida existente a partir de su [ActiveGameState] y [CaseData].
  Future<GameSession> resumeGame(
    ActiveGameState activeState,
    CaseData caseData,
  ) async {
    if (hasActiveSession) {
      if (currentSession!.caseId == caseData.id) {
        return currentSession!;
      }
      throw StateError('Cannot resume a game session while another session is active.');
    }

    final now = DateTime.now();
    _lastActiveSegmentStart = now;
    _lastResult = null;
    _lastUnlockedAchievements = [];

    final session = GameSession(
      caseId: caseData.id,
      origin: caseData.origin,
      status: GameSessionStatus.playing,
      startedAt: activeState.savedAt,
      lastResumedAt: now,
    );

    _currentCase = caseData;
    _activeState = activeState;
    sessionNotifier.value = session;
    return session;
  }

  /// Pasa la sesión al estado de espera de acusación del asesino.
  void setAwaitingKiller() {
    final session = currentSession;
    if (session == null ||
        (session.status != GameSessionStatus.playing &&
         session.status != GameSessionStatus.paused)) {
      return;
    }

    sessionNotifier.value = session.copyWith(
      status: GameSessionStatus.awaitingKiller,
    );
  }

  /// Procesa la deducción del asesino por parte del jugador.
  ///
  /// Retorna el [GameResult] si la acusación fue correcta (completando la partida),
  /// o null si fue incorrecta (incrementando errores y permitiendo reintentar).
  Future<GameResult?> submitKillerDeduction(String suspectId) async {
    final session = currentSession;
    if (session == null) {
      throw StateError('No active session for killer deduction.');
    }

    if (session.status != GameSessionStatus.playing &&
        session.status != GameSessionStatus.awaitingKiller &&
        session.status != GameSessionStatus.paused) {
      throw StateError('Cannot submit killer deduction in state: ${session.status}');
    }

    final caseData = _currentCase;
    if (caseData == null) {
      throw StateError('Current case data is missing.');
    }

    if (suspectId == caseData.killerId) {
      // Deducción correcta: completar caso y otorgar recompensas
      return await completeGame();
    } else {
      // Deducción incorrecta: penalizar y permitir reintentar
      recordMistake();
      return null;
    }
  }

  bool _isPausing = false;

  /// Pausa la partida activa actual y persiste el estado del tablero.
  /// Es idempotente y seguro ante múltiples llamadas de ciclo de vida.
  Future<void> pauseGame() async {
    if (_isPausing) return;

    final session = currentSession;
    if (session == null) {
      return;
    }

    // Solo se permite pausar si el estado es 'playing' o 'awaitingKiller'.
    if (session.status != GameSessionStatus.playing &&
        session.status != GameSessionStatus.awaitingKiller) {
      return;
    }

    _isPausing = true;
    try {
      if (_lastActiveSegmentStart != null) {
        _accumulatedDuration += DateTime.now().difference(_lastActiveSegmentStart!);
        _lastActiveSegmentStart = null;
      }

      if (_activeController != null) {
        await saveGameService.saveCurrentGame(session.caseId, _activeController!);
      }

      sessionNotifier.value = session.copyWith(
        status: GameSessionStatus.paused,
        pausedAt: DateTime.now(),
      );
    } finally {
      _isPausing = false;
    }
  }

  /// Abandona la partida actual, eliminando el estado guardado en disco y limpiando la sesión.
  /// No otorga progreso ni recompensas.
  Future<void> abandonGame() async {
    await saveGameService.clearGame();

    final session = currentSession;
    if (session != null) {
      sessionNotifier.value = session.copyWith(
        status: GameSessionStatus.abandoned,
      );
    }

    clearSession();
  }

  bool _isCompleting = false;

  /// Completa la partida actual de forma atómica e idempotente.
  ///
  /// Calcula estrellas, recompensas, genera el [GameResult], actualiza el progreso,
  /// registra estadísticas, evalúa logros y limpia el guardado en disco.
  Future<GameResult> completeGame() async {
    if (_isCompleting) {
      throw StateError('Game is already being completed.');
    }

    final session = currentSession;
    if (session == null) {
      throw StateError('No active session to complete.');
    }

    // Idempotencia: si ya está resuelto, retornamos el resultado previo sin duplicar nada.
    if (session.status == GameSessionStatus.solved && _lastResult != null) {
      return _lastResult!;
    }

    if (session.status != GameSessionStatus.playing &&
        session.status != GameSessionStatus.paused &&
        session.status != GameSessionStatus.awaitingKiller) {
      throw StateError('Cannot complete game from state: ${session.status}');
    }

    _isCompleting = true;
    try {
      // 1. Calcular duración total activa
      if (_lastActiveSegmentStart != null) {
        _accumulatedDuration += DateTime.now().difference(_lastActiveSegmentStart!);
        _lastActiveSegmentStart = null;
      }

      final caseData = _currentCase;
      if (caseData == null) {
        throw StateError('Current case data is missing.');
      }

      // 2. Calcular estrellas y monedas de forma centralizada y determinista
      final stars = starCalculator.calculateStars(
        solved: true,
        difficulty: caseData.difficulty,
        hintsUsed: _hintsUsed,
        mistakes: _mistakes,
        duration: _accumulatedDuration,
      );

      final coinsEarned = starCalculator.calculateCoins(
        solved: true,
        difficulty: caseData.difficulty,
        stars: stars,
      );

      // 3. Construir GameResult inmutable
      final result = GameResult(
        caseId: session.caseId,
        caseOrigin: session.origin,
        solved: true,
        stars: stars,
        coinsEarned: coinsEarned,
        hintsUsed: _hintsUsed,
        mistakes: _mistakes,
        duration: _accumulatedDuration,
        difficulty: caseData.difficulty,
      );

      _lastResult = result;

      // 4. Otorgar recompensas en ProgressionService (idempotente)
      await progressionService.completeCase(
        session.caseId,
        RewardData(coins: result.coinsEarned, stars: result.stars),
      );

      // 5. Registrar estadísticas acumuladas
      await statisticsService.recordResult(result);

      // 6. Evaluar y desbloquear logros
      final newlyUnlocked = await achievementService.processResult(
        result: result,
        statistics: statisticsService.statistics,
        playerProgress: progressionService.progress,
      );
      _lastUnlockedAchievements = newlyUnlocked;

      // 7. Limpiar partida guardada activa en disco
      await saveGameService.clearGame();

      // 8. Actualizar estado de la sesión a 'solved'
      sessionNotifier.value = session.copyWith(
        status: GameSessionStatus.solved,
        completedAt: DateTime.now(),
      );

      return result;
    } finally {
      _isCompleting = false;
    }
  }

  /// Limpia las referencias en memoria de la sesión activa.
  void clearSession() {
    sessionNotifier.value = null;
    _activeController = null;
    _currentCase = null;
    _activeState = null;
    _hintsUsed = 0;
    _mistakes = 0;
    _accumulatedDuration = Duration.zero;
    _lastActiveSegmentStart = null;
  }
}
