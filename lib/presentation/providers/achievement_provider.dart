import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/user_streak.dart';
import '../../domain/usecases/stats_usecase.dart';
import '../../data/repositories/achievement_repository.dart';

/// Provider for the achievement system.
class AchievementProvider extends ChangeNotifier {
  final AchievementRepository _repo = AchievementRepository();
  final StatsUseCase _statsUseCase = StatsUseCase();
  Map<String, Achievement> _unlocked = {};
  bool _isInitialized = false;

  /// IDs of achievements that were just unlocked this session
  /// (cleared after the UI consumes them).
  List<String> _justUnlocked = [];

  Map<String, Achievement> get unlocked => _unlocked;
  List<String> get justUnlocked => _justUnlocked;
  bool get isInitialized => _isInitialized;

  /// Whether a specific achievement is unlocked.
  bool isUnlocked(String id) => _unlocked.containsKey(id);

  /// Load unlocked achievements from disk.
  Future<void> initialize() async {
    _unlocked = await _repo.getUnlocked();
    _isInitialized = true;
    notifyListeners();
  }

  /// Check and unlock any newly earned achievements based on current stats.
  Future<void> checkAndUnlock({
    required GameStats stats,
    required UserStreak streak,
  }) async {
    final newIds = _statsUseCase.checkAchievements(
      stats: stats,
      streak: streak,
      alreadyUnlocked: _unlocked.keys.toSet(),
    );

    if (newIds.isEmpty) return;

    await _repo.unlockAll(newIds);
    _unlocked = await _repo.getUnlocked();
    _justUnlocked = newIds;
    notifyListeners();
  }

  /// Call after the UI has consumed [justUnlocked] to clear the list.
  void clearJustUnlocked() {
    _justUnlocked = [];
  }

  /// Reset all achievements.
  Future<void> resetAll() async {
    await _repo.resetAll();
    _unlocked = {};
    _justUnlocked = [];
    notifyListeners();
  }
}
