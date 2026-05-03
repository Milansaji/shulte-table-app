import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../domain/entities/schulte_game.dart';
import '../../domain/entities/high_score.dart';
import '../../domain/usecases/game_usecase.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/high_score_repository.dart';
import '../../core/constants/game_constants.dart';

/// Provider for game state management.
///
/// Manages the core gameplay loop: grid initialisation, tap handling,
/// timer, wrong-tap feedback, and high-score persistence.
class GameProvider extends ChangeNotifier {
  late GameUseCase _gameUseCase;
  late SchulteGame _game;
  late Stopwatch _stopwatch;
  Timer? _timer;
  Timer? _wrongTapTimer;
  late HighScoreRepository _highScoreRepository;
  late List<HighScore> _highScores;
  bool _gameStarted = false;
  int _gridSize = GameConstants.defaultGridSize;

  /// Whether vibration feedback is enabled (set from SettingsProvider).
  bool vibrationEnabled = true;

  // Tracks whether the last completed game beat the previous best.
  bool _isNewRecord = false;

  // ── Getters ──────────────────────────────────────────────────────────────

  SchulteGame get game => _game;
  int get currentNumber => _game.currentNumber;
  int get totalNumbers => _game.totalNumbers;
  int get foundCount => _game.foundCount;
  List<int> get numbers => _game.numbers;
  List<bool> get found => _game.found;
  int? get wrongTapIndex => _game.wrongTapIndex;
  bool get isGameCompleted => _game.state == GameConstants.stateCompleted;
  bool get isGameStarted => _gameStarted;
  String get formattedTime => _formatTime(_stopwatch.elapsedMilliseconds);
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
  List<HighScore> get highScores => _highScores;
  int get gridSize => _gridSize;
  String get gameState => _game.state;
  bool get isNewRecord => _isNewRecord;

  /// Whether a specific grid size is unlocked based on high scores.
  bool isGridSizeUnlocked(int size) {
    if (size == 3) return true;
    final threshold = GameConstants.unlockThresholds[size];
    if (threshold == null) return true;

    final bestOnPrevious = bestTimeForGrid(size - 1);
    return bestOnPrevious != null && bestOnPrevious < threshold;
  }

  /// Get the condition text to unlock a size (e.g. "Score < 12.0s on 3x3").
  String getUnlockCondition(int size) {
    if (size == 3) return "";
    final threshold = GameConstants.unlockThresholds[size];
    if (threshold == null) return "";
    final s = threshold / 1000;
    return "Score < ${s.toStringAsFixed(1)}s on ${size - 1}×${size - 1}";
  }

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

  List<HighScore> getHighScoresForGrid(int gridSize) {
    return _highScores.where((s) => s.gridSize == gridSize).toList();
  }

  int? bestTimeForGrid(int gridSize) {
    final scores = getHighScoresForGrid(gridSize);
    if (scores.isEmpty) return null;
    return scores.map((s) => s.time).reduce((a, b) => a < b ? a : b);
  }

  Future<void> _loadHighScores() async {
    _highScores = await _highScoreRepository.getAllHighScores();
    notifyListeners();
  }

  // ── Game lifecycle ────────────────────────────────────────────────────────

  void _initializeGame() {
    _game = _gameUseCase.initializeGame(gridSize: _gridSize);
    _gameStarted = false;
    _isNewRecord = false;
    _stopwatch.reset();
  }

  /// Start the game with freshly shuffled numbers.
  void startGame() {
    if (!_gameStarted) {
      _initializeGame();
      _gameStarted = true;
      _stopwatch.start();
      _startTimer();
      notifyListeners();
    }
  }

  /// End the game manually.
  void endGame() {
    if (_gameStarted) {
      _gameStarted = false;
      _stopTimer();
      notifyListeners();
    }
  }

  /// Handle a cell tap at [index].
  void tapNumber(int index) {
    if (!_gameStarted) return;

    final prevState = _game;
    _game = _gameUseCase.handleNumberTap(_game, index);

    // Wrong tap detected.
    if (_game.wrongTapIndex != null && prevState.wrongTapIndex != _game.wrongTapIndex) {
      if (vibrationEnabled) {
        HapticFeedback.heavyImpact();
      }
      // Auto-clear wrong tap after a short delay.
      _wrongTapTimer?.cancel();
      _wrongTapTimer = Timer(GameConstants.wrongTapDuration, () {
        _game = _gameUseCase.clearWrongTap(_game);
        notifyListeners();
      });
    }

    // Correct tap — light haptic.
    if (_game.currentNumber > prevState.currentNumber) {
      if (vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
    }

    notifyListeners();

    if (isGameCompleted) {
      _stopTimer();
      _gameStarted = false;
      _saveHighScore();
    }
  }

  /// Restart the game to the initial (pre-start) state.
  void restartGame() {
    _stopTimer();
    _wrongTapTimer?.cancel();
    _stopwatch.reset();
    _initializeGame();
    notifyListeners();
  }

  /// Change grid size. No-op while a game is running or if target size is locked.
  void setGridSize(int size) {
    if (_gameStarted) return;
    if (!GameConstants.availableGridSizes.contains(size)) return;
    if (!isGridSizeUnlocked(size)) return;
    _gridSize = size;
    _stopTimer();
    _wrongTapTimer?.cancel();
    _stopwatch.reset();
    _initializeGame();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _saveHighScore() async {
    final elapsed = _stopwatch.elapsedMilliseconds;

    final previous = bestTimeForGrid(_gridSize);
    _isNewRecord = previous == null || elapsed < previous;

    final highScore = HighScore(
      time: elapsed,
      date: DateTime.now(),
      gridSize: _gridSize,
    );
    await _highScoreRepository.saveHighScore(highScore);
    _highScores = await _highScoreRepository.getAllHighScores();

    notifyListeners();
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
    _wrongTapTimer?.cancel();
    super.dispose();
  }
}