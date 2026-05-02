
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulte_table/presentation/widgets/levelsector_widget.dart';
import 'package:schulte_table/presentation/widgets/new_record_widget.dart';
import '../../presentation/providers/game_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/widgets/high_scores_widget.dart';
import '../../presentation/widgets/circular_timer_widget.dart';
import '../../presentation/widgets/game_grid_widget.dart';

class SchulteTableScreen extends StatefulWidget {
  const SchulteTableScreen({super.key});

  @override
  State<SchulteTableScreen> createState() => _SchulteTableScreenState();
}

class _SchulteTableScreenState extends State<SchulteTableScreen> {
  bool _overlayShown = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Schulte Master',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        actions: const [_ThemeToggleButton()],
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, _) {

          // 🔁 RESET overlay when new game starts
          if (!gameProvider.isGameStarted) {
            _overlayShown = false;
          }

          // 🎉 SHOW overlay
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (gameProvider.isGameCompleted &&
                gameProvider.isNewRecord &&
                !_overlayShown) {

              _overlayShown = true;

              NewRecordOverlay.show(
                context,
                time: gameProvider.formattedTime,
                level: gameProvider.currentLevel,
              );
            }
          });

          final isDarkMode =
              Theme.of(context).brightness == Brightness.dark;

          return Container(
            color: isDarkMode ? Colors.black : Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Level selector
                    LevelSelectorWidget(gameProvider: gameProvider),
                    const SizedBox(height: 10),

                    // Timer
                    Center(
                      child: CircularTimerWidget(
                        time: gameProvider.formattedTime,
                        currentNumber: gameProvider.currentNumber,
                        totalNumbers: gameProvider.totalNumbers,
                        gameProvider: gameProvider,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Grid
                    GameGridWidget(gameProvider: gameProvider),
                    const SizedBox(height: 32),

                    // High scores
                    SizedBox(
                      height: 300,
                      child: HighScoresWidget(
                        highScores: gameProvider.getHighScoresForLevel(
                          gameProvider.currentLevel,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Theme toggle
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              size: 24,
            ),
            onPressed: themeProvider.toggleTheme,
            tooltip:
                themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        );
      },
    );
  }
}

