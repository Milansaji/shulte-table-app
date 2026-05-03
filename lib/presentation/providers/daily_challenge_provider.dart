import 'package:flutter/material.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/entities/daily_challenge.dart';
import '../../domain/entities/schulte_game.dart';
import '../../domain/usecases/game_usecase.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/daily_challenge_repository.dart';

/// Provider for the daily challenge mode.
class DailyChallengeProvider extends ChangeNotifier {
  final DailyChallengeRepository _repo = DailyChallengeRepository();
  final GameUseCase _gameUseCase = GameUseCase(GameRepository());

  DailyChallenge? _todayChallenge;
  SchulteGame? _game;
  bool _isInitialized = false;
  bool _gameStarted = false;

  DailyChallenge? get todayChallenge => _todayChallenge;
  SchulteGame? get game => _game;
  bool get isInitialized => _isInitialized;
  bool get gameStarted => _gameStarted;
  bool get isTodayCompleted => _todayChallenge?.isCompleted ?? false;

  /// Load today's challenge status from disk.
  Future<void> initialize() async {
    final todayKey = DailyChallenge.todayKey();
    _todayChallenge = await _repo.getResult(todayKey);
    _todayChallenge ??= DailyChallenge(
      dateKey: todayKey,
      gridSize: GameConstants.dailyChallengeGridSize,
    );
    _isInitialized = true;
    notifyListeners();
  }

  /// Initialize the daily challenge game grid (deterministic shuffle).
  void initializeGame() {
    final todayKey = DailyChallenge.todayKey();
    final seed = DailyChallenge.seedForDate(todayKey);
    _game = _gameUseCase.initializeGame(
      gridSize: GameConstants.dailyChallengeGridSize,
      isDailyChallenge: true,
      seed: seed,
    );
    _gameStarted = false;
    notifyListeners();
  }

  void startGame() {
    if (_game == null) initializeGame();
    _gameStarted = true;
    notifyListeners();
  }

  /// Record daily challenge completion.
  Future<void> recordCompletion(int timeMs) async {
    final todayKey = DailyChallenge.todayKey();
    final prev = _todayChallenge?.bestTimeMs;
    final best = (prev == null || timeMs < prev) ? timeMs : prev;

    _todayChallenge = DailyChallenge(
      dateKey: todayKey,
      gridSize: GameConstants.dailyChallengeGridSize,
      bestTimeMs: best,
      isCompleted: true,
    );
    await _repo.saveResult(_todayChallenge!);
    _gameStarted = false;
    notifyListeners();
  }

  /// Reset (for progress reset).
  Future<void> resetAll() async {
    await _repo.resetAll();
    _todayChallenge = null;
    _game = null;
    _gameStarted = false;
    notifyListeners();
  }
}
