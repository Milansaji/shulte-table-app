class GameConstants {
  // Grid sizes
  static const int defaultGridSize = 5;
  static const int defaultTotalNumbers = 25;

  // Timer update interval
  static const Duration timerUpdateInterval = Duration(milliseconds: 100);

  // Game states
  static const String stateInitial = 'initial';
  static const String stateRunning = 'running';
  static const String stateCompleted = 'completed';

  // Game levels (3 levels with increasing difficulty)
  static const int totalLevels = 3;
  static const List<int> levelGridSizes = [5, 8, 9];
  static const List<int> levelTotalNumbers = [25, 56, 81];

  // Level unlock thresholds in milliseconds
  // Level 2 unlocks when Level 1 best time <= 25s
  // Level 3 unlocks when Level 2 best time <= 60s
  static const List<int?> levelUnlockThresholds = [
    null,    // Level 1 is always unlocked
    25000,   // Level 2: beat Level 1 in 25s
    60000,   // Level 3: beat Level 2 in 60s
  ];

  /// Human-readable unlock requirement for a level (e.g. "Beat Lv 1 in 25s")
  static String unlockHint(int level) {
    final threshold = levelUnlockThresholds[level - 1];
    if (threshold == null) return '';
    final secs = threshold ~/ 1000;
    return 'Beat Lv ${level - 1} in ${secs}s';
  }

  // Get grid size for a specific level (1-indexed)
  static int getGridSizeForLevel(int level) {
    if (level < 1 || level > totalLevels) return defaultGridSize;
    return levelGridSizes[level - 1];
  }

  // Get total numbers for a specific level (1-indexed)
  static int getTotalNumbersForLevel(int level) {
    if (level < 1 || level > totalLevels) return defaultTotalNumbers;
    return levelTotalNumbers[level - 1];
  }
}