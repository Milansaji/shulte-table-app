import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/daily_challenge_provider.dart';
import '../providers/game_provider.dart';
import '../../data/repositories/high_score_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/snackbar_utils.dart';

/// Settings screen with toggles for sound, vibration, notifications, dark mode,
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? Colors.white : Colors.black;
    final bg = isDark ? Colors.black : Colors.white;
    final subtle = isDark ? Colors.white54 : Colors.black45;
    final tileBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: fg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<SettingsProvider, ThemeProvider>(
        builder: (context, settings, theme, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionLabel('Preferences', fg),
              const SizedBox(height: 8),

              // Dark Mode
              _SettingsTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                value: theme.isDarkMode,
                onChanged: (_) => theme.toggleTheme(),
                bg: tileBg,
                fg: fg,
              ),
              const SizedBox(height: 8),

              // Sound
              _SettingsTile(
                icon: Icons.volume_up_rounded,
                title: 'Sound',
                value: settings.soundEnabled,
                onChanged: (v) => settings.setSoundEnabled(v),
                bg: tileBg,
                fg: fg,
              ),
              const SizedBox(height: 8),

              // Vibration
              _SettingsTile(
                icon: Icons.vibration_rounded,
                title: 'Vibration',
                value: settings.vibrationEnabled,
                onChanged: (v) {
                  settings.setVibrationEnabled(v);
                  // Sync to game provider.
                  context.read<GameProvider>().vibrationEnabled = v;
                },
                bg: tileBg,
                fg: fg,
              ),
              const SizedBox(height: 8),

              // Notifications
              _SettingsTile(
                icon: Icons.notifications_rounded,
                title: 'Daily Reminder (7:00 AM)',
                value: settings.notificationsEnabled,
                onChanged: (v) async {
                  if (v) {
                    final granted =
                        await NotificationService.instance.requestPermission();
                    if (!granted) return;
                    await NotificationService.instance.scheduleDailyReminder();
                  } else {
                    await NotificationService.instance.cancelDailyReminder();
                  }
                  settings.setNotificationsEnabled(v);
                },
                bg: tileBg,
                fg: fg,
              ),

              const SizedBox(height: 32),
              _SectionLabel('Data', fg),
              const SizedBox(height: 8),

              // Reset Progress
              GestureDetector(
                onTap: () => _showResetDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.delete_forever_rounded,
                          color: Colors.red.shade400, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset All Progress',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Clears scores, stats, streaks, and achievements',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App info
              Center(
                child: Text(
                  'Schulte Master v1.0.0',
                  style: TextStyle(fontSize: 12, color: subtle),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Train daily. Think faster. Stay sharp.',
                  style: TextStyle(fontSize: 11, color: subtle),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset All Progress?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'This will delete all your high scores, statistics, streaks, and achievements. This cannot be undone.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _resetAllProgress(context);
              if (context.mounted) {
                SnackbarUtils.showInfo(context, MessageConstants.progressReset);
              }
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllProgress(BuildContext context) async {
    await HighScoreRepository().clearAllHighScores();
    if (context.mounted) {
      context.read<StatsProvider>().resetStats();
      context.read<StreakProvider>().resetStreak();
      context.read<AchievementProvider>().resetAll();
      context.read<DailyChallengeProvider>().resetAll();
      context.read<GameProvider>().restartGame();
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color.withValues(alpha: 0.5),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color bg;
  final Color fg;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: fg,
          ),
        ],
      ),
    );
  }
}
