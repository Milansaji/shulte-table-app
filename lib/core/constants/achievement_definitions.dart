/// Static catalogue of all achievements.
///
/// Each definition is a pure data object — unlocked state is tracked
/// separately in [AchievementRepository].
class AchievementDef {
  final String id;
  final String title;
  final String emoji;
  final String description;

  const AchievementDef({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
  });
}

class AchievementCatalog {
  AchievementCatalog._();

  static const firstSteps = AchievementDef(
    id: 'first_steps',
    title: 'First Steps',
    emoji: '🏁',
    description: 'Complete your first game',
  );

  static const speedDemon = AchievementDef(
    id: 'speed_demon',
    title: 'Speed Demon',
    emoji: '⚡',
    description: 'Complete 5×5 in under 15 seconds',
  );

  static const onFire = AchievementDef(
    id: 'on_fire',
    title: 'On Fire',
    emoji: '🔥',
    description: 'Maintain a 3-day streak',
  );

  static const weeklyWarrior = AchievementDef(
    id: 'weekly_warrior',
    title: 'Weekly Warrior',
    emoji: '🗓️',
    description: 'Maintain a 7-day streak',
  );

  static const champion = AchievementDef(
    id: 'champion',
    title: 'Champion',
    emoji: '🏆',
    description: 'Maintain a 30-day streak',
  );

  static const gridMaster = AchievementDef(
    id: 'grid_master',
    title: 'Grid Master',
    emoji: '🧩',
    description: 'Play every grid size at least once',
  );

  static const dailyPlayer = AchievementDef(
    id: 'daily_player',
    title: 'Daily Player',
    emoji: '🎯',
    description: 'Complete 10 daily challenges',
  );

  static const centurion = AchievementDef(
    id: 'centurion',
    title: 'Centurion',
    emoji: '💯',
    description: 'Complete 100 games in total',
  );

  /// All achievements in display order.
  static const List<AchievementDef> all = [
    firstSteps,
    speedDemon,
    onFire,
    weeklyWarrior,
    champion,
    gridMaster,
    dailyPlayer,
    centurion,
  ];

  /// Lookup by ID.
  static AchievementDef? byId(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
