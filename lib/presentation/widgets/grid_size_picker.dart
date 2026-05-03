import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../core/utils/snackbar_utils.dart';

/// Horizontal scrollable row of grid-size chips (3×3 → 10×10).
class GridSizePicker extends StatelessWidget {
  final int selectedSize;
  final bool disabled;
  final ValueChanged<int> onSelected;
  final bool Function(int) isUnlocked;
  final String Function(int) getUnlockCondition;

  const GridSizePicker({
    super.key,
    required this.selectedSize,
    required this.onSelected,
    required this.isUnlocked,
    required this.getUnlockCondition,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: GameConstants.availableGridSizes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final size = GameConstants.availableGridSizes[index];
          final isSelected = size == selectedSize;
          final unlocked = isUnlocked(size);

          return GestureDetector(
            onTap: disabled
                ? null
                : () {
                    if (unlocked) {
                      onSelected(size);
                    } else {
                      SnackbarUtils.showWarning(
                        context,
                        '${MessageConstants.levelLocked} ${getUnlockCondition(size)}',
                      );
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : (unlocked
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05))
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.02)
                            : Colors.black.withValues(alpha: 0.02))),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (unlocked
                          ? (isDark ? Colors.white24 : Colors.black12)
                          : (isDark ? Colors.white10 : Colors.black12)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!unlocked) ...[
                    Icon(
                      Icons.lock_rounded,
                      size: 14,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Center(
                    child: Text(
                      '$size×$size',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (unlocked
                                ? (isDark ? Colors.white70 : Colors.black54)
                                : (isDark ? Colors.white24 : Colors.black26)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
