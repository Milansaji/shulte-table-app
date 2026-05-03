import '../../domain/entities/daily_challenge.dart';
import '../../domain/entities/user_streak.dart';

/// Pure business logic for computing streak updates.
class StreakUseCase {
  StreakUseCase();

  /// Returns an updated [UserStreak] after a game is completed today.
  UserStreak updateStreak(UserStreak current) {
    final todayKey = DailyChallenge.todayKey();

    // Already played today — no change.
    if (current.lastPlayedDate == todayKey) return current;

    final yesterday = _yesterday();

    // Played yesterday → extend streak, otherwise reset to 1.
    final newStreak = (current.lastPlayedDate == yesterday)
        ? current.currentStreak + 1
        : 1;

    final newLongest =
        newStreak > current.longestStreak ? newStreak : current.longestStreak;

    return current.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastPlayedDate: todayKey,
    );
  }

  String _yesterday() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return '${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}';
  }
}
