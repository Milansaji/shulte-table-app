import 'package:flutter/material.dart';
import '../../presentation/providers/game_provider.dart';
import '../../presentation/widgets/schulte_game_cell.dart';
import '../../core/constants/game_constants.dart';

/// Displays the Schulte table grid.
class GameGridWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const GameGridWidget({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gridSize = gameProvider.game.gridSize;

    // Use GameConstants thresholds: level 1 = 5, level 2 = 8, level 3 = 9
    final double fontSize = gridSize <= GameConstants.levelGridSizes[0]
        ? 24.0
        : gridSize <= GameConstants.levelGridSizes[1]
            ? 16.0
            : 12.0;
    final double spacing = gridSize <= GameConstants.levelGridSizes[0]
        ? 10.0
        : gridSize <= GameConstants.levelGridSizes[1]
            ? 6.0
            : 4.0;
    final double padding = gridSize <= GameConstants.levelGridSizes[0]
        ? 12.0
        : gridSize <= GameConstants.levelGridSizes[1]
            ? 8.0
            : 6.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.white : Colors.black)
                .withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: gameProvider.totalNumbers,
            itemBuilder: (context, index) {
              return SchulteGameCell(
                number: gameProvider.numbers[index],
                isFound: gameProvider.found[index],
                onTap: () => gameProvider.tapNumber(index),
                fontSize: fontSize,
              );
            },
          ),
        ],
      ),
    );
  }
}