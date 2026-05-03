import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/game_constants.dart';
import '../providers/stats_provider.dart';
import '../providers/streak_provider.dart';

/// Statistics screen showing best/average times, total games, and streak info.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final bg = isDark ? Colors.black : Colors.white;
    final subtle = isDark ? Colors.white54 : Colors.black45;
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Statistics',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_rounded),
            onPressed: () => Navigator.pushNamed(context, '/achievements'),
            tooltip: 'Achievements',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer2<StatsProvider, StreakProvider>(
        builder: (context, statsProvider, streakProvider, _) {
          final stats = statsProvider.stats;
          final streak = streakProvider.streak;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary cards row.
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '🎮',
                      label: 'Games Played',
                      value: stats.totalGamesPlayed.toString(),
                      bg: cardBg,
                      fg: fg,
                      subtle: subtle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '⏱️',
                      label: 'Total Time',
                      value: _formatTotalTime(stats.totalTimePlayedMs),
                      bg: cardBg,
                      fg: fg,
                      subtle: subtle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '🔥',
                      label: 'Current Streak',
                      value: '${streak.currentStreak} days',
                      bg: cardBg,
                      fg: fg,
                      subtle: subtle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '🏆',
                      label: 'Best Streak',
                      value: '${streak.longestStreak} days',
                      bg: cardBg,
                      fg: fg,
                      subtle: subtle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      emoji: '🎯',
                      label: 'Daily Challenges',
                      value: stats.dailyChallengesCompleted.toString(),
                      bg: cardBg,
                      fg: fg,
                      subtle: subtle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      emoji: '🧩',
                      label: 'Grid Sizes Played',
                      value:
                          '${stats.gridSizesPlayed.length}/${GameConstants.availableGridSizes.length}',
                      bg: cardBg,
                      fg: fg,
                      subtle: subtle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Per-grid best/avg table.
              Text(
                'TIMES BY GRID SIZE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: fg.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      // Header row.
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        child: Row(
                          children: [
                            _HeaderCell('Grid', fg, flex: 2),
                            _HeaderCell('Best', fg),
                            _HeaderCell('Avg', fg),
                            _HeaderCell('Games', fg),
                          ],
                        ),
                      ),
                      // Data rows.
                      ...GameConstants.availableGridSizes.map((size) {
                        final best = stats.bestTimePerGridSize[size];
                        final avg = stats.averageTimeForGrid(size);
                        final count = stats.gamesPerGridSize[size] ?? 0;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 11),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color:
                                    isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$size×$size',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: fg,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  best != null
                                      ? _formatMs(best)
                                      : '--',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: best != null ? fg : subtle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  avg != null
                                      ? _formatMs(avg.round())
                                      : '--',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: avg != null ? fg : subtle,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  count > 0 ? count.toString() : '--',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: count > 0 ? fg : subtle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatMs(int ms) {
    final s = ms / 1000;
    if (s < 60) return '${s.toStringAsFixed(1)}s';
    final mins = s ~/ 60;
    final secs = (s % 60).toStringAsFixed(0);
    return '${mins}m ${secs}s';
  }

  String _formatTotalTime(int ms) {
    if (ms == 0) return '0s';
    final totalSeconds = ms ~/ 1000;
    if (totalSeconds < 60) return '${totalSeconds}s';
    final mins = totalSeconds ~/ 60;
    if (mins < 60) return '${mins}m';
    final hours = mins ~/ 60;
    final remMins = mins % 60;
    return '${hours}h ${remMins}m';
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color bg;
  final Color fg;
  final Color subtle;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.bg,
    required this.fg,
    required this.subtle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: subtle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  final Color fg;
  final int flex;

  const _HeaderCell(this.text, this.fg, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: fg.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
