import 'package:flutter/material.dart';
import '../../domain/entities/user_streak.dart';
import '../../domain/usecases/streak_usecase.dart';
import '../../data/repositories/streak_repository.dart';

/// Provider for daily play streak.
class StreakProvider extends ChangeNotifier {
  final StreakRepository _repo = StreakRepository();
  final StreakUseCase _useCase = StreakUseCase();
  UserStreak _streak = const UserStreak();
  bool _isInitialized = false;

  UserStreak get streak => _streak;
  int get currentStreak => _streak.currentStreak;
  int get longestStreak => _streak.longestStreak;
  bool get isInitialized => _isInitialized;

  /// Load streak from disk.
  Future<void> initialize() async {
    _streak = await _repo.getStreak();
    _isInitialized = true;
    notifyListeners();
  }

  /// Call when a game is completed — updates the streak for today.
  Future<void> recordPlay() async {
    _streak = _useCase.updateStreak(_streak);
    await _repo.saveStreak(_streak);
    notifyListeners();
  }

  /// Reset streak data.
  Future<void> resetStreak() async {
    await _repo.resetStreak();
    _streak = const UserStreak();
    notifyListeners();
  }
}
