import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/progression/models/player_progress.dart';
import 'package:nexus_mortis/game/progression/progression_service.dart';
import 'package:nexus_mortis/game/puzzles/models/case_data.dart';
import 'package:nexus_mortis/game/puzzles/case_registry.dart';
import 'package:nexus_mortis/features/home/home_page.dart';
import 'package:nexus_mortis/features/case_selection/resume_game_page.dart';
import 'package:nexus_mortis/game/hints/services/hint_economy_service.dart';
import 'package:nexus_mortis/game/puzzles/services/procedural_case_service.dart';
import 'package:nexus_mortis/game/session/services/game_session_service.dart';
import 'package:nexus_mortis/game/save_state/save_game_service.dart';
import 'package:nexus_mortis/game/session/models/game_session.dart';
import 'package:nexus_mortis/game/session/models/game_session_status.dart';

class CaseSelectionPage extends StatelessWidget {
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

  Future<void> _startCase(BuildContext context, CaseData caseData) async {
    if (!progressionService.isCaseUnlocked(caseData)) return;
    if (sessionService.hasActiveSession) return;
    await sessionService.startNewGame(caseData);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ),
    );
  }

  Future<void> _startProcedural(BuildContext context) async {
    final nextCase = await proceduralCaseService.getNextCase();
    if (sessionService.hasActiveSession) return;
    await sessionService.startNewGame(nextCase);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ),
    );
  }

  void _resumePaused(BuildContext context) {
    final activeState = sessionService.activeState;
    if (activeState == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResumeGamePage(
          saveState: activeState,
          progressionService: progressionService,
          saveGameService: saveGameService,
          economyService: economyService,
          proceduralCaseService: proceduralCaseService,
          sessionService: sessionService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder<PlayerProgress>(
              valueListenable: progressionService.progressNotifier,
              builder: (context, progress, child) => _Header(progress: progress),
            ),
            Expanded(
              child: ValueListenableBuilder<GameSession?>(
                valueListenable: sessionService.sessionNotifier,
                builder: (context, session, _) {
                  return ValueListenableBuilder<PlayerProgress>(
                    valueListenable: progressionService.progressNotifier,
                    builder: (context, progress, _) {
                      return _Body(
                        progress: progress,
                        session: session,
                        progressionService: progressionService,
                        onStartCase: (c) => _startCase(context, c),
                        onStartProcedural: () => _startProcedural(context),
                        onResumePaused: () => _resumePaused(context),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${progress.totalStars}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                '${progress.coins}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
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
    required this.progress,
    required this.session,
    required this.progressionService,
    required this.onStartCase,
    required this.onStartProcedural,
    required this.onResumePaused,
  });

  final PlayerProgress progress;
  final GameSession? session;
  final ProgressionService progressionService;
  final void Function(CaseData) onStartCase;
  final VoidCallback onStartProcedural;
  final VoidCallback onResumePaused;

  bool get _hasPausedSession =>
      session?.status == GameSessionStatus.paused || session?.status == GameSessionStatus.playing;

  bool get _campaignComplete =>
      progressionService.getNextCampaignCase(CaseRegistry.cases) == null;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        if (_hasPausedSession) ...[
          _PausedBanner(onResume: onResumePaused),
          const SizedBox(height: 12),
        ],

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'EXPEDIENTES',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        ...CaseRegistry.cases.map((caseData) {
          final isUnlocked = progressionService.isCaseUnlocked(caseData);
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

        if (_campaignComplete) ...[
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'INVESTIGACIÓN INFINITA',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _InfiniteInvestigationCard(onTap: onStartProcedural),
        ],

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pause_circle_outline, color: Colors.amber),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tienes una investigación en curso',
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: onResume,
            style: TextButton.styleFrom(foregroundColor: Colors.amber),
            child: const Text('CONTINUAR'),
          ),
        ],
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
    required this.onTap,
  });

  final CaseData caseData;
  final bool isUnlocked;
  final bool isCompleted;
  final int starsEarned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCompleted
                  ? Colors.amber.withValues(alpha: 0.4)
                  : const Color(0xFF2E2E3E),
            ),
          ),
          child: Row(
            children: [
              _StatusIcon(
                isUnlocked: isUnlocked,
                isCompleted: isCompleted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseData.title,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (isUnlocked) ...[
                      const SizedBox(height: 2),
                      Text(
                        caseData.description,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isUnlocked)
                _StarRow(stars: starsEarned, completed: isCompleted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.isUnlocked, required this.isCompleted});

  final bool isUnlocked;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (!isUnlocked) {
      return const Icon(Icons.lock_outline, color: Colors.white24, size: 28);
    }
    if (isCompleted) {
      return const Icon(Icons.check_circle_outline,
          color: Colors.amber, size: 28);
    }
    return const Icon(Icons.folder_outlined, color: Colors.white70, size: 28);
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.stars, required this.completed});

  final int stars;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final earned = completed && i < stars;
        return Icon(
          earned ? Icons.star : Icons.star_border,
          color: earned ? Colors.amber : Colors.white24,
          size: 16,
        );
      }),
    );
  }
}

class _InfiniteInvestigationCard extends StatelessWidget {
  const _InfiniteInvestigationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A0A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.all_inclusive, color: Colors.amber, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Investigación Infinita',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Un nuevo caso te espera',
                    style: TextStyle(
                      color: Colors.amber.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.amber, size: 16),
          ],
        ),
      ),
    );
  }
}
