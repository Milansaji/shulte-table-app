import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/daily_challenge_provider.dart';
import '../widgets/high_scores_widget.dart';
import '../widgets/circular_timer_widget.dart';
import '../widgets/game_grid_widget.dart';
import '../widgets/grid_size_picker.dart';
import '../widgets/new_record_widget.dart';
import 'package:confetti/confetti.dart';
import '../../core/services/notification_service.dart';
import '../../core/constants/achievement_definitions.dart';

class SchulteTableScreen extends StatefulWidget {
  const SchulteTableScreen({super.key});

  @override
  State<SchulteTableScreen> createState() => _SchulteTableScreenState();
}

class _SchulteTableScreenState extends State<SchulteTableScreen> {
  bool _recordOverlayShown = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.watch<GameProvider>().isGameStarted,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Schulte Master',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded, size: 24),
              onPressed: () => Navigator.pushNamed(context, '/stats'),
              tooltip: 'Stats',
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded, size: 24),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              tooltip: 'Settings',
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Consumer<GameProvider>(
          builder: (context, gameProvider, _) {
            // Reset overlay flag when game resets.
            if (!gameProvider.isGameStarted && !gameProvider.isGameCompleted) {
              _recordOverlayShown = false;
            }

            // Post-frame: handle overlays and achievement checks.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!gameProvider.isGameCompleted) return;
              if (!mounted) return;

              // New record overlay.
              if (gameProvider.isNewRecord && !_recordOverlayShown) {
                _recordOverlayShown = true;
                NewRecordOverlay.show(
                  context,
                  time: gameProvider.formattedTime,
                  gridSize: gameProvider.gridSize,
                );
              }

              // Record stats, streak, and check achievements.
              _onGameCompleted(context, gameProvider);
            });

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Stack(
              children: [
                Container(
                  color: isDark ? Colors.black : Colors.white,
                  child: SingleChildScrollView(
                    child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Daily challenge banner.
                      _DailyChallengeBanner(),
                      const SizedBox(height: 12),

                      // Grid size picker.
                      GridSizePicker(
                        selectedSize: gameProvider.gridSize,
                        disabled: gameProvider.isGameStarted,
                        onSelected: (size) => gameProvider.setGridSize(size),
                        isUnlocked: (size) =>
                            gameProvider.isGridSizeUnlocked(size),
                        getUnlockCondition: (size) =>
                            gameProvider.getUnlockCondition(size),
                      ),
                      const SizedBox(height: 16),

                      // Timer.
                      Center(
                        child: CircularTimerWidget(
                          time: gameProvider.formattedTime,
                          currentNumber: gameProvider.currentNumber,
                          totalNumbers: gameProvider.totalNumbers,
                          gameProvider: gameProvider,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Grid.
                      GameGridWidget(gameProvider: gameProvider),
                      const SizedBox(height: 32),

                      // High scores.
                      SizedBox(
                        height: 300,
                        child: HighScoresWidget(
                          highScores: gameProvider.getHighScoresForGrid(
                            gameProvider.gridSize,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    maxBlastForce: 100,
                    minBlastForce: 80,
                    gravity: 0.1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _completionHandled = false;

  Future<void> _onGameCompleted(BuildContext context, GameProvider gameProvider) async {
    if (_completionHandled) return;
    _completionHandled = true;

    // Reset flag when game restarts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!gameProvider.isGameCompleted) {
        _completionHandled = false;
      }
    });

    // Record stats.
    final statsProvider = context.read<StatsProvider>();
    statsProvider.recordGame(
      gridSize: gameProvider.gridSize,
      timeMs: gameProvider.elapsedMilliseconds,
    );

    // Update streak.
    final streakProvider = context.read<StreakProvider>();
    final oldStreak = streakProvider.currentStreak;
    await streakProvider.recordPlay();
    final newStreak = streakProvider.currentStreak;

    // Check achievements.
    final achievementProvider = context.read<AchievementProvider>();
    await achievementProvider.checkAndUnlock(
      stats: statsProvider.stats,
      streak: streakProvider.streak,
    );

    bool shouldPlayConfetti = false;

    if (achievementProvider.justUnlocked.isNotEmpty) {
      shouldPlayConfetti = true;
      for (final id in achievementProvider.justUnlocked) {
        final def = AchievementCatalog.byId(id);
        if (def != null) {
          NotificationService.instance.showAchievementNotification(
            'Achievement Unlocked!',
            def.title,
          );
        }
      }
      achievementProvider.clearJustUnlocked();
    }

    if (newStreak > oldStreak) {
      shouldPlayConfetti = true;
      if (newStreak % 3 == 0 || newStreak == 1) { // Notify on milestones or first play
        NotificationService.instance.showStreakNotification(
          'Streak Updated!',
          'You are on a $newStreak day streak! 🔥',
        );
      }
    }

    if (shouldPlayConfetti && mounted) {
      _confettiController.play();
    }
  }
}

/// Theme toggle button.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return IconButton(
          icon: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            size: 24,
          ),
          onPressed: themeProvider.toggleTheme,
          tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
        );
      },
    );
  }
}

/// Banner linking to daily challenge.
class _DailyChallengeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DailyChallengeProvider>(
      builder: (context, provider, _) {
        if (!provider.isInitialized) return const SizedBox.shrink();

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final completed = provider.isTodayCompleted;

        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/daily'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: completed
                  ? (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.06)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  completed
                      ? Icons.check_circle_rounded
                      : Icons.calendar_today_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    completed
                        ? 'Daily Challenge Completed! ✅  (${provider.todayChallenge?.formattedBestTime ?? '--'})'
                        : '🔥 Daily Challenge Available — Tap to play!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
