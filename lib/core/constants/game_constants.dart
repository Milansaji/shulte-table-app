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
}
