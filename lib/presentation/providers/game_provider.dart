import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/entities/schulte_game.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/usecases/game_usecase.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/high_score_repository.dart';
import '../../core/constants/game_constants.dart';

/// Provider for game state management
class GameProvider extends ChangeNotifier {
  late GameUseCase _gameUseCase;
  late SchulteGame _game;
  late Stopwatch _stopwatch;
  Timer? _timer;
  late HighScoreRepository _highScoreRepository;
  late List<HighScore> _highScores;
  bool _gameStarted = false;
  bool _gamePaused = false;
  int _currentLevel = 1;

  // Tracks whether the last completed game beat the previous best
  bool _isNewRecord = false;

  // Fired once after _saveHighScore detects a newly unlocked level.
  // The screen listens to this and calls LevelUnlockOverlay.show().
  int? _justUnlockedLevel;

  // ── Getters ──────────────────────────────────────────────────────────────

  SchulteGame get game => _game;
  int get currentNumber => _game.currentNumber;
  int get totalNumbers => _game.totalNumbers;
  int get foundCount => _game.foundCount;
  List<int> get numbers => _game.numbers;
  List<bool> get found => _game.found;
  bool get isGameCompleted => _game.state == GameConstants.stateCompleted;
  bool get isGameStarted => _gameStarted;
  bool get isGamePaused => _gamePaused;
  String get formattedTime => _formatTime(_stopwatch.elapsedMilliseconds);
  List<HighScore> get highScores => _highScores;
  int get currentLevel => _currentLevel;
  int get totalLevels => GameConstants.totalLevels;

  /// Returns the current game state string (matches GameConstants state values).
  String get gameState => _game.state;

  /// True when the last completed game set a new best time for its level.
  bool get isNewRecord => _isNewRecord;

  /// The level that was just unlocked by the last game completion, or null.
  /// Consumers should read this value, show the overlay, then call
  /// [clearJustUnlockedLevel] so it doesn't fire again.
  int? get justUnlockedLevel => _justUnlockedLevel;

  // ── Constructor ───────────────────────────────────────────────────────────

  GameProvider() {
    _gameUseCase = GameUseCase(GameRepository());
    _highScoreRepository = HighScoreRepository();
    _highScores = [];
    _stopwatch = Stopwatch();
    _timer = null;
    _initializeGame();
    _loadHighScores();
  }

  // ── Level unlock logic ────────────────────────────────────────────────────

  /// Returns true if [level] is playable based on high score unlock thresholds.
  ///
  /// - Level 1 is always unlocked.
  /// - Level 2 unlocks when the best time on Level 1 is <= 25 000 ms (25 s).
  /// - Level 3 unlocks when the best time on Level 2 is <= 40 000 ms (40 s).
  bool isLevelUnlocked(int level) {
    if (level <= 1) return true;

    final threshold = GameConstants.levelUnlockThresholds[level - 1];
    if (threshold == null) return true;

    final best = _bestTimeForLevel(level - 1);
    return best != null && best <= threshold;
  }

  /// Call this after the UI has consumed [justUnlockedLevel] and shown
  /// the overlay, so it isn't triggered a second time.
  void clearJustUnlockedLevel() {
    _justUnlockedLevel = null;
    // No notifyListeners needed — this is a one-shot signal.
  }

  // ── High scores ───────────────────────────────────────────────────────────

  /// Get high scores for a specific level.
  List<HighScore> getHighScoresForLevel(int level) {
    return _highScores.where((score) => score.level == level).toList();
  }

  /// Returns the current best time (ms) for [level], or null if none exists.
  int? _bestTimeForLevel(int level) {
    final scores = getHighScoresForLevel(level);
    if (scores.isEmpty) return null;
    return scores.map((s) => s.time).reduce((a, b) => a < b ? a : b);
  }

  /// Load high scores from storage.
  Future<void> _loadHighScores() async {
    _highScores = await _highScoreRepository.getHighScores();
    notifyListeners();
  }

  // ── Game lifecycle ────────────────────────────────────────────────────────

  /// Initialize game state (does NOT start the timer).
  void _initializeGame() {
    final gridSize = GameConstants.getGridSizeForLevel(_currentLevel);
    final totalNumbers = GameConstants.getTotalNumbersForLevel(_currentLevel);
    _game = _gameUseCase.initializeGame(
      gridSize: gridSize,
      totalNumbers: totalNumbers,
    );
    _gameStarted = false;
    _gamePaused = false;
    _isNewRecord = false;
    _stopwatch.reset();
  }

  /// Start the game with freshly shuffled numbers.
  void startGame() {
    if (!_gameStarted) {
      _initializeGame();
      _gameStarted = true;
      _gamePaused = false;
      _stopwatch.start();
      _startTimer();
      notifyListeners();
    }
  }

  /// End the game manually (keeps elapsed time visible).
  void endGame() {
    if (_gameStarted) {
      _gameStarted = false;
      _stopTimer();
      notifyListeners();
    }
  }

  /// Handle a cell tap at [index].
  void tapNumber(int index) {
    if (!_gameStarted || _gamePaused) return;

    _game = _gameUseCase.handleNumberTap(_game, index);
    notifyListeners();

    if (isGameCompleted) {
      _stopTimer();
      _gameStarted = false;
      _saveHighScore();
    }
  }

  /// Restart the game back to the initial (pre-start) state.
  void restartGame() {
    _stopTimer();
    _stopwatch.reset();
    _initializeGame();
    notifyListeners();
  }

  /// Set the active level (1-indexed). No-op while a game is running or level is locked.
  void setLevel(int level) {
    if (level >= 1 &&
        level <= GameConstants.totalLevels &&
        !_gameStarted &&
        isLevelUnlocked(level)) {
      _currentLevel = level;
      _stopTimer();
      _stopwatch.reset();
      _initializeGame();
      notifyListeners();
    }
  }

  /// Advance to the next level (only if unlocked).
  void nextLevel() {
    if (_currentLevel < GameConstants.totalLevels) {
      setLevel(_currentLevel + 1);
    }
  }

  /// Go back to the previous level.
  void previousLevel() {
    if (_currentLevel > 1) {
      setLevel(_currentLevel - 1);
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Save score, detect new record, and detect newly unlocked levels.
  Future<void> _saveHighScore() async {
    final elapsed = _stopwatch.elapsedMilliseconds;

    // Snapshot unlock state BEFORE saving so we can diff after.
    final unlockedBefore = List.generate(
      GameConstants.totalLevels,
      (i) => isLevelUnlocked(i + 1),
    );

    // Check for new record before saving.
    final previous = _bestTimeForLevel(_currentLevel);
    _isNewRecord = previous == null || elapsed < previous;

    final highScore = HighScore(
      time: elapsed,
      date: DateTime.now(),
      level: _currentLevel,
    );
    await _highScoreRepository.saveHighScore(highScore);

    // Reload scores — this updates _highScores so isLevelUnlocked re-evaluates.
    _highScores = await _highScoreRepository.getHighScores();

    // Diff: find the first level that just became unlocked this save.
    _justUnlockedLevel = null;
    for (int i = 0; i < GameConstants.totalLevels; i++) {
      final level = i + 1;
      if (!unlockedBefore[i] && isLevelUnlocked(level)) {
        _justUnlockedLevel = level;
        break;
      }
    }

    notifyListeners(); // triggers UI to check justUnlockedLevel
  }

  // ── Timer helpers ─────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      GameConstants.timerUpdateInterval,
      (_) {
        _game = _gameUseCase.updateElapsedTime(
          _game,
          _stopwatch.elapsedMilliseconds,
        );
        notifyListeners();
      },
    );
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  String _formatTime(int milliseconds) {
    final totalSeconds = milliseconds / 1000;
    if (totalSeconds < 60) {
      return '${totalSeconds.toStringAsFixed(1)}s';
    }
    final mins = totalSeconds ~/ 60;
    final secs = (totalSeconds % 60).toStringAsFixed(1);
    return '${mins}m ${secs}s';
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}