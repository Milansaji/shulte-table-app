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

  // Getters
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

  GameProvider() {
    _gameUseCase = GameUseCase(GameRepository());
    _highScoreRepository = HighScoreRepository();
    _highScores = [];
    _stopwatch = Stopwatch();
    _timer = null;
    _initializeGame();
    _loadHighScores();
  }

  /// Load high scores from storage
  Future<void> _loadHighScores() async {
    _highScores = await _highScoreRepository.getHighScores();
    notifyListeners();
  }

  /// Initialize game (without starting timer)
  void _initializeGame() {
    _game = _gameUseCase.initializeGame(
      gridSize: GameConstants.defaultGridSize,
      totalNumbers: GameConstants.defaultTotalNumbers,
    );
    _gameStarted = false;
    _gamePaused = false;
    _stopwatch.reset();
  }

  /// Start the game (with fresh numbers)
  void startGame() {
    if (!_gameStarted) {
      // Reinitialize the game with new numbers
      _initializeGame();
      _gameStarted = true;
      _gamePaused = false;
      _stopwatch.start();
      _startTimer();
      notifyListeners();
    }
  }

  /// Start the timer
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

  /// End the game
  void endGame() {
    if (_gameStarted) {
      _gameStarted = false;
      _stopTimer();
      // Keep the time visible - don't reset
      notifyListeners();
    }
  }

  /// Handle number tap
  void tapNumber(int index) {
    // Only allow tapping if game has started
    if (!_gameStarted || _gamePaused) {
      return;
    }

    _game = _gameUseCase.handleNumberTap(_game, index);
    notifyListeners();

    if (isGameCompleted) {
      _stopTimer();
      _gameStarted = false;
      _saveHighScore();
    }
  }

  /// Save the current game's high score
  Future<void> _saveHighScore() async {
    final highScore = HighScore(
      time: _stopwatch.elapsedMilliseconds,
      date: DateTime.now(),
    );
    await _highScoreRepository.saveHighScore(highScore);
    await _loadHighScores();
  }

  /// Restart the game
  void restartGame() {
    _stopTimer();
    _stopwatch.reset();
    _initializeGame();
    notifyListeners();
  }

  /// Stop the timer
  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  /// Format milliseconds to MM:SS format
  String _formatTime(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final msec = milliseconds % 1000;
    return '${seconds.toString().padLeft(2, '0')}:${(msec ~/ 10).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
