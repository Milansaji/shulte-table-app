import 'package:flutter/material.dart';
import '../../presentation/providers/game_provider.dart';
import '../../core/constants/game_constants.dart';

/// Circular timer widget that also displays game controls in its center.
///
/// The center area shows:
/// - Current number to find + progress arc  (always visible)
/// - A compact action button based on game state (start / end / restart)
class CircularTimerWidget extends StatelessWidget {
  final String time;
  final int currentNumber;
  final int totalNumbers;
  final GameProvider gameProvider;

  const CircularTimerWidget({
    super.key,
    required this.time,
    required this.currentNumber,
    required this.totalNumbers,
    required this.gameProvider,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress =
        totalNumbers > 0 ? (currentNumber - 1) / totalNumbers : 0.0;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
          ),
          // Progress arc
          SizedBox(
            width: 220,
            height: 220,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          // Center content
          _TimerCenter(
            time: time,
            currentNumber: currentNumber,
            totalNumbers: totalNumbers,
            isDarkMode: isDark,
            gameProvider: gameProvider,
          ),
        ],
      ),
    );
  }
}

/// Inner content of the circular timer: time, progress label, and inline button.
class _TimerCenter extends StatelessWidget {
  final String time;
  final int currentNumber;
  final int totalNumbers;
  final bool isDarkMode;
  final GameProvider gameProvider;

  const _TimerCenter({
    required this.time,
    required this.currentNumber,
    required this.totalNumbers,
    required this.isDarkMode,
    required this.gameProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timer display
        Text(
          time,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: isDarkMode ? Colors.white : Colors.black,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        // Progress label
        Text(
          '$currentNumber / $totalNumbers',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.grey.shade400 : Colors.black54,
          ),
        ),
        const SizedBox(height: 10),
        // Inline game control button
        _InlineGameControlButton(
          gameProvider: gameProvider,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }
}

/// A compact button rendered inside the timer based on the current game state.
class _InlineGameControlButton extends StatelessWidget {
  final GameProvider gameProvider;
  final bool isDarkMode;

  const _InlineGameControlButton({
    required this.gameProvider,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final config = _resolveConfig();

    return GestureDetector(
      onTap: config.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.white : Colors.black)
                  .withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              config.icon,
              size: 16,
              color: isDarkMode ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              config.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ButtonConfig _resolveConfig() {
    if (gameProvider.isGameCompleted) {
      return _ButtonConfig(
        icon: Icons.restart_alt_rounded,
        label: 'Restart',
        onTap: gameProvider.restartGame,
      );
    }
    if (gameProvider.isGameStarted) {
      return _ButtonConfig(
        icon: Icons.stop_circle_rounded,
        label: 'End',
        onTap: gameProvider.endGame,
      );
    }
    // Not started — fresh or manual end
    final bool isFresh =
        gameProvider.gameState == GameConstants.stateRunning ||
        gameProvider.gameState == GameConstants.stateInitial;
    return _ButtonConfig(
      icon: Icons.play_arrow_rounded,
      label: isFresh ? 'Start' : 'New Game',
      onTap: gameProvider.startGame,
    );
  }
}

class _ButtonConfig {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ButtonConfig({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}