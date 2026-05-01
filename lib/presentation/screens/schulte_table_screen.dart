import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/providers/game_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/widgets/schulte_game_cell.dart';
import '../../presentation/widgets/high_scores_widget.dart';
import '../../presentation/widgets/circular_timer_widget.dart';

/// Main game screen with black and white UI
class SchulteTableScreen extends StatelessWidget {
  const SchulteTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schulte Master',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        actions: [
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  size: 24,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Circular Timer
                  Center(
                    child: CircularTimerWidget(
                      time: gameProvider.formattedTime,
                      currentNumber: gameProvider.currentNumber,
                      totalNumbers: gameProvider.totalNumbers,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Game Start/End Controls
                  if (!gameProvider.isGameStarted && gameProvider.formattedTime == '00:00' && !gameProvider.isGameCompleted)
                    _buildStartButton(gameProvider),
                  if (gameProvider.isGameStarted && !gameProvider.isGameCompleted)
                    _buildGameControls(gameProvider),
                  if (!gameProvider.isGameStarted && gameProvider.formattedTime != '00:00' && !gameProvider.isGameCompleted)
                    _buildGameEndedControls(gameProvider),
                  if (gameProvider.isGameCompleted)
                    _buildGameCompletedControls(gameProvider),

                  const SizedBox(height: 32),

                  // Game Grid
                  _buildGameGrid(gameProvider),
                  const SizedBox(height: 32),

                  // High Scores Display
                  SizedBox(
                    height: 300,
                    child: HighScoresWidget(highScores: gameProvider.highScores),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build start game button
  Widget _buildStartButton(GameProvider gameProvider) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFF00D9FF) : Colors.black).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Ready to Challenge Your Brain?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
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
                  backgroundColor: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  elevation: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build game control buttons (during game)
  Widget _buildGameControls(GameProvider gameProvider) {
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// Build game ended controls
  Widget _buildGameEndedControls(GameProvider gameProvider) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFF00D9FF) : Colors.black).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Game Paused - ${gameProvider.formattedTime}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => gameProvider.startGame(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Start New Game'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  elevation: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build game completed controls
  Widget _buildGameCompletedControls(GameProvider gameProvider) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFF00D9FF) : Colors.black).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.celebration_rounded,
                color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '🎉 Congratulations! 🎉',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${gameProvider.formattedTime}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => gameProvider.restartGame(),
                icon: const Icon(Icons.restart_alt_rounded, size: 24),
                label: const Text('Restart Game'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  elevation: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build game grid
  Widget _buildGameGrid(GameProvider gameProvider) {
    return Builder(
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? const Color(0xFF00D9FF) : Colors.black).withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gameProvider.game.gridSize,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: gameProvider.totalNumbers,
            itemBuilder: (context, index) {
              return SchulteGameCell(
                number: gameProvider.numbers[index],
                isFound: gameProvider.found[index],
                onTap: () => gameProvider.tapNumber(index),
              );
            },
          ),
        );
      },
    );
  }
}
