import 'package:flutter/material.dart';
import 'package:nexus_mortis/game/achievements/models/achievement_definition.dart';
import 'package:nexus_mortis/game/results/models/game_result.dart';

/// Pantalla de presentación cinematográfica y moderna para los resultados de la partida.
class ResultsPage extends StatefulWidget {
  const ResultsPage({
    super.key,
    required this.result,
    required this.unlockedAchievements,
    required this.onContinue,
  });

  final GameResult result;
  final List<AchievementDefinition> unlockedAchievements;
  final void Function(BuildContext) onContinue;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _headerFade;
  late final Animation<double> _starsScale;
  late final Animation<double> _metricsFade;
  late final Animation<double> _rewardsScale;
  late final Animation<double> _achievementsSlide;
  late final Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _starsScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
    );

    _metricsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );

    _rewardsScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 0.85, curve: Curves.easeOutBack),
    );

    _achievementsSlide = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.75, 0.95, curve: Curves.easeOut),
    );

    _buttonFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.result;

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Título
                  FadeTransition(
                    opacity: _headerFade,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified,
                          color: Colors.amber,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'CASO RESUELTO',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expediente: ${res.caseId}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 2. Estrellas
                  ScaleTransition(
                    scale: _starsScale,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isEarned = index < res.stars;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            isEarned ? Icons.star : Icons.star_border,
                            color: isEarned ? Colors.amber : Colors.white24,
                            size: 44,
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 3. Métricas de la partida
                  FadeTransition(
                    opacity: _metricsFade,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _MetricItem(
                            icon: Icons.timer_outlined,
                            label: 'Tiempo',
                            value: _formatDuration(res.duration),
                          ),
                          _MetricItem(
                            icon: Icons.lightbulb_outline,
                            label: 'Pistas',
                            value: '${res.hintsUsed}',
                          ),
                          _MetricItem(
                            icon: Icons.cancel_outlined,
                            label: 'Errores',
                            value: '${res.mistakes}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Recompensas obtenidas
                  ScaleTransition(
                    scale: _rewardsScale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${res.coinsEarned} Monedas',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 24),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${res.stars} Estrellas',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Logros desbloqueados (si hay)
                  if (widget.unlockedAchievements.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _achievementsSlide,
                      child: Column(
                        children: widget.unlockedAchievements.map((ach) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2418),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '¡LOGRO DESBLOQUEADO: ${ach.title.toUpperCase()}!',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ach.description,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 6. Botón Continuar
                  FadeTransition(
                    opacity: _buttonFade,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => widget.onContinue(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        child: const Text('CONTINUAR'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
