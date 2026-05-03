import 'package:flutter/material.dart';
import '../../presentation/providers/game_provider.dart';
import '../../core/constants/game_constants.dart';

class LevelSelectorWidget extends StatelessWidget {
  final GameProvider gameProvider;

  const LevelSelectorWidget({super.key, required this.gameProvider});

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
            (index) {
              final level = index + 1;
              final unlocked = gameProvider.isLevelUnlocked(level);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _LevelCard(
                  level: level,
                  isSelected: gameProvider.currentLevel == level,
                  icon: levelIcons[index],
                  gridSize: gridSizes[index],
                  isDarkMode: isDarkMode,
                  isDisabled: gameProvider.isGameStarted || !unlocked,
                  isLocked: !unlocked,
                  unlockHint: GameConstants.unlockHint(level),
                  onTap: () => gameProvider.setLevel(level),
                ),
              );
            },
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
  final bool isLocked;
  final String unlockHint;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.icon,
    required this.gridSize,
    required this.isDarkMode,
    required this.isDisabled,
    required this.isLocked,
    required this.unlockHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Locked cards get a muted colour regardless of selection
    final lockedFg = isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
    final lockedBg = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200;

    return GestureDetector(
      onTap: isDisabled ? (_showLockedToast(context)) : onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.0 : 0.88,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 72,
          height: isLocked ? 96 : 80, // a bit taller to fit hint text
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected && !isLocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      isDarkMode ? Colors.white : Colors.black,
                      isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade800,
                    ],
                  )
                : null,
            color: isLocked
                ? lockedBg
                : (isSelected
                    ? null
                    : (isDarkMode
                        ? Colors.grey.shade900
                        : Colors.grey.shade100)),
            border: Border.all(
              color: isLocked
                  ? (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)
                  : (isSelected
                      ? (isDarkMode ? Colors.white : Colors.black)
                      : (isDarkMode ? Colors.white24 : Colors.black12)),
              width: isSelected && !isLocked ? 2 : 1.5,
            ),
            boxShadow: isSelected && !isLocked
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
          child: isLocked ? _buildLockedContent(lockedFg) : _buildContent(),
        ),
      ),
    );
  }

  /// Content shown when the level is locked
  Widget _buildLockedContent(Color fg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_rounded, size: 20, color: fg),
        const SizedBox(height: 4),
        Text(
          'Lv $level',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            unlockHint,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: fg,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  /// Normal (unlocked) card content
  Widget _buildContent() {
    final fg = isSelected
        ? (isDarkMode ? Colors.black : Colors.white)
        : (isDarkMode ? Colors.white : Colors.black);
    final subFg = isSelected
        ? (isDarkMode ? Colors.black87 : Colors.white70)
        : (isDarkMode ? Colors.grey.shade400 : Colors.black54);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: fg),
        const SizedBox(height: 4),
        Text(
          'Lv $level',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: fg,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$gridSize#',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: subFg,
          ),
        ),
      ],
    );
  }

  /// Show a toast when tapping a locked level (returns null for onTap)
  VoidCallback? _showLockedToast(BuildContext context) {
    if (!isLocked) return null;
    return () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🔒 $unlockHint to unlock this level',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    };
  }
}