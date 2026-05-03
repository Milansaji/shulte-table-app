import 'package:flutter/material.dart';
import '../../presentation/providers/game_provider.dart';

/// Completion controls shown after the game ends.
class GameCompletedControlsWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const GameCompletedControlsWidget({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            gameProvider.isNewRecord
                ? Icons.emoji_events_rounded
                : Icons.celebration_rounded,
            color: isDark ? Colors.white : Colors.black,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            gameProvider.isNewRecord
                ? '🏆 New Record! 🏆'
                : '🎉 Congratulations! 🎉',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Grid: ${gameProvider.gridSize}×${gameProvider.gridSize}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Time: ${gameProvider.formattedTime}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => gameProvider.restartGame(),
            icon: const Icon(Icons.restart_alt_rounded, size: 24),
            label: const Text('Restart Game'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black,
              foregroundColor: isDark ? Colors.black : Colors.white,
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