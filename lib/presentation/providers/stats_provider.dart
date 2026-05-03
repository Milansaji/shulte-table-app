import 'package:flutter/material.dart';
import '../../domain/entities/game_stats.dart';
import '../../data/repositories/stats_repository.dart';

/// Provider exposing aggregate game statistics.
class StatsProvider extends ChangeNotifier {
  final StatsRepository _repo = StatsRepository();
  GameStats _stats = const GameStats();
  bool _isInitialized = false;

  GameStats get stats => _stats;
  bool get isInitialized => _isInitialized;

  /// Load stats from disk. Call once at app start.
  Future<void> initialize() async {
    _stats = await _repo.getStats();
    _isInitialized = true;
    notifyListeners();
  }

  /// Record a completed game.
  Future<void> recordGame({
    required int gridSize,
    required int timeMs,
    bool isDailyChallenge = false,
  }) async {
    _stats = _stats.recordGame(
      gridSize: gridSize,
      timeMs: timeMs,
      isDailyChallenge: isDailyChallenge,
    );
    await _repo.saveStats(_stats);
    notifyListeners();
  }

  /// Reset all stats.
  Future<void> resetStats() async {
    await _repo.resetStats();
    _stats = const GameStats();
    notifyListeners();
  }
}
