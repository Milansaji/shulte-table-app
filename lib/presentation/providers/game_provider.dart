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

  // ── High scores ───────────────────────────────────────────────────────────

  /// Get high scores for a specific level.
  List<HighScore> getHighScoresForLevel(int level) {
    return _highScores.where((score) => score.level == level).toList();
  }

  /// Returns the current best time (ms) for [level], or null if none exists.
  int? _bestTimeForLevel(int level) {
    final scores = getHighScoresForLevel(level);
    if (scores.isEmpty) return null;
    return scores
        .map((s) => s.time)
        .reduce((a, b) => a < b ? a : b);
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

  /// Set the active level (1-indexed). No-op while a game is running.
  void setLevel(int level) {
    if (level >= 1 && level <= GameConstants.totalLevels && !_gameStarted) {
      _currentLevel = level;
      _stopTimer();
      _stopwatch.reset();
      _initializeGame();
      notifyListeners();
    }
  }

  /// Advance to the next level.
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

  /// Save score and determine whether it is a new record.
  Future<void> _saveHighScore() async {
    final elapsed = _stopwatch.elapsedMilliseconds;

    // Check before saving so the list still reflects previous bests.
    final previous = _bestTimeForLevel(_currentLevel);
    _isNewRecord = previous == null || elapsed < previous;

    final highScore = HighScore(
      time: elapsed,
      date: DateTime.now(),
      level: _currentLevel,
    );
    await _highScoreRepository.saveHighScore(highScore);
    await _loadHighScores(); // refreshes _highScores and calls notifyListeners
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
    final seconds = milliseconds ~/ 1000;
    final msec = milliseconds % 1000;
    return '${seconds.toString().padLeft(2, '0')}:${(msec ~/ 10).toString().padLeft(2, '0')}';
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}