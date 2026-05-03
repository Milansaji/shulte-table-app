import 'package:flutter/material.dart';
import '../../presentation/providers/game_provider.dart';
import '../../presentation/widgets/schulte_game_cell.dart';

/// Displays the Schulte table grid with dynamic sizing for grid sizes 3–10.
class GameGridWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const GameGridWidget({super.key, required this.gameProvider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridSize = gameProvider.game.gridSize;

    // Dynamic sizing based on grid dimension.
    final double fontSize = _fontSizeForGrid(gridSize);
    final double spacing = _spacingForGrid(gridSize);
    final double padding = _paddingForGrid(gridSize);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
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
            isWrongTap: gameProvider.wrongTapIndex == index,
            onTap: () => gameProvider.tapNumber(index),
            fontSize: fontSize,
          );
        },
      ),
    );
  }

  /// Smoothly scales font size from 28 (3×3) down to 10 (10×10).
  double _fontSizeForGrid(int gridSize) {
    const double maxFont = 28;
    const double minFont = 10;
    const int minGrid = 3;
    const int maxGrid = 10;
    final t = (gridSize - minGrid) / (maxGrid - minGrid);
    return maxFont - t * (maxFont - minFont);
  }

  double _spacingForGrid(int gridSize) {
    if (gridSize <= 4) return 10;
    if (gridSize <= 6) return 7;
    if (gridSize <= 8) return 5;
    return 3;
  }

  double _paddingForGrid(int gridSize) {
    if (gridSize <= 4) return 12;
    if (gridSize <= 6) return 8;
    return 6;
  }
}