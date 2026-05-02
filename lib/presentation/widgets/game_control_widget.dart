import 'package:flutter/material.dart';
import 'package:schulte_table/presentation/widgets/new_record_widget.dart';
import '../../presentation/providers/game_provider.dart';
import '../../core/constants/game_constants.dart';

/// Shown before the game starts (timer at 00:00)
class StartButtonWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const StartButtonWidget({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _GameControlContainer(
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          Text(
            'Ready to Challenge Your Brain?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => gameProvider.startGame(),
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: const Text(
              'Start Game',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown while the game is active
class ActiveGameControlsWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const ActiveGameControlsWidget({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => gameProvider.endGame(),
            icon: const Icon(Icons.stop_circle_rounded),
            label: const Text('End Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDarkMode ? Colors.grey.shade200 : Colors.grey.shade900,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown after the game is manually ended (paused state)
class GameEndedControlsWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const GameEndedControlsWidget({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _GameControlContainer(
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          Text(
            'Game Paused - ${gameProvider.formattedTime}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => gameProvider.startGame(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Start New Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the game is successfully completed.
/// Automatically fires [NewRecordOverlay] when [gameProvider.isNewRecord] is true.
class GameCompletedControlsWidget extends StatefulWidget {
  final GameProvider gameProvider;

  const GameCompletedControlsWidget({super.key, required this.gameProvider});

  @override
  State<GameCompletedControlsWidget> createState() =>
      _GameCompletedControlsWidgetState();
}

class _GameCompletedControlsWidgetState
    extends State<GameCompletedControlsWidget> {
  @override
  void initState() {
    super.initState();
    // Show overlay on the next frame so the Overlay widget is ready.
    if (widget.gameProvider.isNewRecord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        NewRecordOverlay.show(
          context,
          time: widget.gameProvider.formattedTime,
          level: widget.gameProvider.currentLevel,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _GameControlContainer(
      isDarkMode: isDarkMode,
      extraShadowOpacity: 0.15,
      extraBlurRadius: 12,
      extraOffset: const Offset(0, 6),
      child: Column(
        children: [
          Icon(
            widget.gameProvider.isNewRecord
                ? Icons.emoji_events_rounded
                : Icons.celebration_rounded,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            widget.gameProvider.isNewRecord
                ? '🏆 New Record! 🏆'
                : '🎉 Congratulations! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Level: ${widget.gameProvider.currentLevel} / ${widget.gameProvider.totalLevels}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Time: ${widget.gameProvider.formattedTime}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => widget.gameProvider.restartGame(),
            icon: const Icon(Icons.restart_alt_rounded, size: 24),
            label: const Text('Restart Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared container decoration used by all game control widgets
class _GameControlContainer extends StatelessWidget {
  final bool isDarkMode;
  final Widget child;
  final double extraShadowOpacity;
  final double extraBlurRadius;
  final Offset extraOffset;

  const _GameControlContainer({
    required this.isDarkMode,
    required this.child,
    this.extraShadowOpacity = 0.1,
    this.extraBlurRadius = 8,
    this.extraOffset = const Offset(0, 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.white : Colors.black)
                .withValues(alpha: extraShadowOpacity),
            blurRadius: extraBlurRadius,
            offset: extraOffset,
          ),
        ],
      ),
      child: child,
    );
  }
}