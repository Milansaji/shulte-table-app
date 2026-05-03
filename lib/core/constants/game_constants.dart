/// Central game configuration — grid sizes, timer, and game states.
class GameConstants {
  GameConstants._();

  // ── Grid sizes ──────────────────────────────────────────────────────────
  /// All selectable grid sizes (NxN).
  static const List<int> availableGridSizes = [3, 4, 5, 6, 7, 8, 9, 10];

  /// Default grid size shown on first launch.
  static const int defaultGridSize = 3;

  /// Time thresholds (in ms) on the PREVIOUS grid size required to unlock the NEXT one.
  /// Map: gridSize -> time needed on (gridSize - 1) to unlock.
  static const Map<int, int> unlockThresholds = {
    5: 25000,  // Need < 25s on 4x4 to unlock 5x5
    6: 45000,  // Need < 45s on 5x5 to unlock 6x6
    7: 70000,  // Need < 70s on 6x6 to unlock 7x7
    8: 100000, // Need < 100s on 7x7 to unlock 8x8
    9: 150000, // Need < 150s on 8x8 to unlock 9x9
    10: 210000,// Need < 210s on 9x9 to unlock 10x10
  };

  /// Total cell count for a given grid size.
  static int totalNumbersForGrid(int gridSize) => gridSize * gridSize;

  // ── Timer ───────────────────────────────────────────────────────────────
  static const Duration timerUpdateInterval = Duration(milliseconds: 100);

  // ── Game states ─────────────────────────────────────────────────────────
  static const String stateInitial = 'initial';
  static const String stateRunning = 'running';
  static const String stateCompleted = 'completed';

  // ── Wrong-tap feedback ──────────────────────────────────────────────────
  /// How long the wrong-tap red flash stays visible.
  static const Duration wrongTapDuration = Duration(milliseconds: 350);

  // ── Daily challenge ─────────────────────────────────────────────────────
  /// Grid size used for the daily challenge.
  static const int dailyChallengeGridSize = 5;
}

/// Centralized UI and notification messages.
class MessageConstants {
  MessageConstants._();

  static const String levelLocked = "Locked!";
  static const String progressReset = "All progress has been reset";
  static const String dailyReminderTitle = "🧠 Time to Train!";
  static const String dailyReminderBody =
      "Your daily Schulte challenge is waiting. Keep your streak alive!";
  static const String newRecord = "NEW RECORD";
  static const String congratulations = "Congratulations!";
  static const String gameCompleted = "🎉 Completed!";
  static const String achievementUnlocked = "🏆 Achievement Unlocked!";
}