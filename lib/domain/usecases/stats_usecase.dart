import '../../core/constants/achievement_definitions.dart';
import '../../core/constants/game_constants.dart';
import '../../domain/entities/game_stats.dart';
import '../../domain/entities/user_streak.dart';

/// Pure business logic for checking achievement unlock conditions.
class StatsUseCase {
  StatsUseCase();

  /// Returns a list of achievement IDs that should be newly unlocked
  /// based on the current stats and streak.
  List<String> checkAchievements({
    required GameStats stats,
    required UserStreak streak,
    required Set<String> alreadyUnlocked,
  }) {
    final newlyUnlocked = <String>[];

    void check(AchievementDef def, bool condition) {
      if (!alreadyUnlocked.contains(def.id) && condition) {
        newlyUnlocked.add(def.id);
      }
    }

    // 🏁 First Steps — at least 1 game
    check(AchievementCatalog.firstSteps, stats.totalGamesPlayed >= 1);

    // ⚡ Speed Demon — 5×5 under 15s
    final best5 = stats.bestTimePerGridSize[5];
    check(AchievementCatalog.speedDemon, best5 != null && best5 < 15000);

    // 🔥 On Fire — 3-day streak
    check(AchievementCatalog.onFire, streak.currentStreak >= 3);

    // 🗓️ Weekly Warrior — 7-day streak
    check(AchievementCatalog.weeklyWarrior, streak.currentStreak >= 7);

    // 🏆 Champion — 30-day streak
    check(AchievementCatalog.champion, streak.currentStreak >= 30);

    // 🧩 Grid Master — played every grid size
    check(
      AchievementCatalog.gridMaster,
      stats.gridSizesPlayed.length >=
          GameConstants.availableGridSizes.length,
    );

    // 🎯 Daily Player — 10 daily challenges
    check(
      AchievementCatalog.dailyPlayer,
      stats.dailyChallengesCompleted >= 10,
    );

    // 💯 Centurion — 100 total games
    check(AchievementCatalog.centurion, stats.totalGamesPlayed >= 100);

    return newlyUnlocked;
  }
}
