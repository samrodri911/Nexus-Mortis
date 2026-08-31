import 'package:flutter/material.dart';
import 'package:nexus_mortis/features/case_selection/resume_game_page.dart';
import 'package:nexus_mortis/features/home/home_page.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/models/puzzle_difficulty.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/models/game_session.dart';
import 'package:nexus_mortis/game/session/models/game_session_status.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';

class CaseSelectionPage extends StatefulWidget {
  const CaseSelectionPage({
    super.key,
    required this.progressionService,
    required this.saveGameService,
    required this.economyService,
    required this.proceduralCaseService,
    required this.sessionService,
  });

  final ProgressionService progressionService;
  final SaveGameService saveGameService;
  final HintEconomyService economyService;
  final ProceduralCaseService proceduralCaseService;
  final GameSessionService sessionService;

  @override
  State<CaseSelectionPage> createState() => _CaseSelectionPageState();
}

class _CaseSelectionPageState extends State<CaseSelectionPage> {
  late Future<List<CaseData>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  void _loadCases() {
    _casesFuture = widget.proceduralCaseService.getAvailableCases();
  }

  Future<void> _startCase(BuildContext context, CaseData caseData) async {
    if (widget.sessionService.hasActiveSession) return;
    try {
      await widget.sessionService.startNewGame(caseData);
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(
            economyService: widget.economyService,
            proceduralCaseService: widget.proceduralCaseService,
            sessionService: widget.sessionService,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar el expediente: $e')),
      );
    }
  }

  void _resumePaused(BuildContext context) {
    final activeState = widget.sessionService.activeState;
    if (activeState == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResumeGamePage(
          saveState: activeState,
          progressionService: widget.progressionService,
          saveGameService: widget.saveGameService,
          economyService: widget.economyService,
          proceduralCaseService: widget.proceduralCaseService,
          sessionService: widget.sessionService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121216),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<PlayerProgress>(
              valueListenable: widget.progressionService.progressNotifier,
              builder: (context, progress, child) => _Header(progress: progress),
            ),
            Expanded(
              child: ValueListenableBuilder<GameSession?>(
                valueListenable: widget.sessionService.sessionNotifier,
                builder: (context, session, _) {
                  return ValueListenableBuilder<PlayerProgress>(
                    valueListenable: widget.progressionService.progressNotifier,
                    builder: (context, progress, _) {
                      return FutureBuilder<List<CaseData>>(
                        future: _casesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.amber),
                            );
                          }

                          final cases = snapshot.data ?? [];

                          return _Body(
                            cases: cases,
                            progress: progress,
                            session: session,
                            progressionService: widget.progressionService,
                            onStartCase: (c) => _startCase(context, c),
                            onResumePaused: () => _resumePaused(context),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});

  final PlayerProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF181822),
        border: Border(bottom: BorderSide(color: Color(0xFF282838), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Row(
              children: [
                Icon(Icons.menu_book, color: Color(0xFFFFD700), size: 20),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'NEXUS MORTIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.totalStars}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${progress.coins}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.cases,
    required this.progress,
    required this.session,
    required this.progressionService,
    required this.onStartCase,
    required this.onResumePaused,
  });

  final List<CaseData> cases;
  final PlayerProgress progress;
  final GameSession? session;
  final ProgressionService progressionService;
  final void Function(CaseData) onStartCase;
  final VoidCallback onResumePaused;

  bool get _hasPausedSession =>
      session?.status == GameSessionStatus.paused || session?.status == GameSessionStatus.playing;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: [
        if (_hasPausedSession) ...[
          _PausedBanner(onResume: onResumePaused),
          const SizedBox(height: 16),
        ],

        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'EXPEDIENTES DE INVESTIGACIÓN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ...cases.asMap().entries.map((entry) {
          final index = entry.key;
          final caseData = entry.value;
          final isUnlocked = progressionService.isCaseUnlocked(
            caseData,
            allCases: cases,
            index: index,
          );
          final caseProgress = progress.completedCases[caseData.id];
          final isCompleted = caseProgress != null;
          final stars = caseProgress?.starsEarned ?? 0;

          return _CaseCard(
            caseData: caseData,
            isUnlocked: isUnlocked,
            isCompleted: isCompleted,
            starsEarned: stars,
            onTap: isUnlocked ? () => onStartCase(caseData) : null,
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _PausedBanner extends StatelessWidget {
  const _PausedBanner({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2235),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3D5AFE), width: 1.5),
      ),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill, color: Color(0xFF3D5AFE), size: 36),
        title: const Text(
          'Investigación en curso',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text(
          'Tienes una investigación en curso',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: ElevatedButton(
          onPressed: onResume,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D5AFE),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('CONTINUAR'),
        ),
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({
    required this.caseData,
    required this.isUnlocked,
    required this.isCompleted,
    required this.starsEarned,
    this.onTap,
  });

  final CaseData caseData;
  final bool isUnlocked;
  final bool isCompleted;
  final int starsEarned;
  final VoidCallback? onTap;

  Color _difficultyColor(PuzzleDifficulty diff) {
    switch (diff) {
      case PuzzleDifficulty.easy:
        return const Color(0xFF4CAF50);
      case PuzzleDifficulty.medium:
        return const Color(0xFFFF9800);
      case PuzzleDifficulty.hard:
        return const Color(0xFFF44336);
    }
  }

  String _difficultyLabel(PuzzleDifficulty diff) {
    switch (diff) {
      case PuzzleDifficulty.easy:
        return 'FÁCIL';
      case PuzzleDifficulty.medium:
        return 'MEDIO';
      case PuzzleDifficulty.hard:
        return 'DIFÍCIL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _difficultyColor(caseData.difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF1B1B26) : const Color(0xFF14141A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFB8860B)
              : isUnlocked
                  ? const Color(0xFF33334A)
                  : const Color(0xFF22222E),
          width: isCompleted ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF2A2312)
                        : isUnlocked
                            ? const Color(0xFF232336)
                            : const Color(0xFF1A1A22),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFFFFD700)
                          : isUnlocked
                              ? const Color(0xFF4D4D6E)
                              : const Color(0xFF2A2A38),
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 24)
                        : isUnlocked
                            ? const Icon(Icons.play_arrow, color: Colors.white, size: 24)
                            : const Icon(Icons.lock, color: Colors.white30, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              caseData.title,
                              style: TextStyle(
                                color: isUnlocked ? Colors.white : Colors.white38,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUnlocked ? diffColor.withAlpha(51) : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isUnlocked ? diffColor : Colors.white24,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              _difficultyLabel(caseData.difficulty),
                              style: TextStyle(
                                color: isUnlocked ? diffColor : Colors.white24,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        caseData.description,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white60 : Colors.white24,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(3, (index) {
                            return Icon(
                              index < starsEarned ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
