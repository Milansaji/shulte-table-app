import 'package:flutter/material.dart';
import '../../presentation/providers/game_provider.dart';
import '../../core/constants/game_constants.dart';

class LevelSelectorWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const LevelSelectorWidget({super.key, required this.gameProvider});

  static const List<String> _levelLabels = ['Easy', 'Medium', 'Hard'];
  static const List<IconData> _levelIcons = [
    Icons.emoji_events,
    Icons.local_fire_department,
    Icons.thunderstorm_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        _LevelCardRow(
          gameProvider: gameProvider,
          isDarkMode: isDarkMode,
          levelIcons: _levelIcons,
          gridSizes: GameConstants.levelTotalNumbers,
        ),
      ],
    );
  }
}

class _LevelInfoHeader extends StatelessWidget {
  final GameProvider gameProvider;
  final bool isDarkMode;
  final List<IconData> levelIcons;
  final List<String> levelLabels;

  const _LevelInfoHeader({
    required this.gameProvider,
    required this.isDarkMode,
    required this.levelIcons,
    required this.levelLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        border: Border.all(
          color: isDarkMode ? Colors.white24 : Colors.black12,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            levelIcons[gameProvider.currentLevel - 1],
            size: 28,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Level ${gameProvider.currentLevel}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                '${levelLabels[gameProvider.currentLevel - 1]} - ${gameProvider.game.totalNumbers} numbers',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.black54,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDarkMode ? Colors.white12 : Colors.black12,
            ),
            child: Text(
              '${gameProvider.currentLevel}/${gameProvider.totalLevels}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCardRow extends StatelessWidget {
  final GameProvider gameProvider;
  final bool isDarkMode;
  final List<IconData> levelIcons;
  final List<int> gridSizes;

  const _LevelCardRow({
    required this.gameProvider,
    required this.isDarkMode,
    required this.levelIcons,
    required this.gridSizes,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            GameConstants.totalLevels,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: _LevelCard(
                level: index + 1,
                isSelected: gameProvider.currentLevel == index + 1,
                icon: levelIcons[index],
                gridSize: gridSizes[index],
                isDarkMode: isDarkMode,
                isDisabled: gameProvider.isGameStarted,
                onTap: () => gameProvider.setLevel(index + 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final bool isSelected;
  final IconData icon;
  final int gridSize;
  final bool isDarkMode;
  final bool isDisabled;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.icon,
    required this.gridSize,
    required this.isDarkMode,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.88,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDarkMode ? Colors.white : Colors.black,
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade800,
                    ],
                  )
                : null,
            color: isSelected
                ? null
                : (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100),
            border: Border.all(
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : (isDarkMode ? Colors.white24 : Colors.black12),
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDarkMode ? Colors.white : Colors.black)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : (isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                'Lv $level',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$gridSize#',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? (isDarkMode ? Colors.black87 : Colors.white70)
                      : (isDarkMode ? Colors.grey.shade400 : Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}