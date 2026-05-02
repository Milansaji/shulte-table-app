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
