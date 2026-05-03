import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/achievement.dart';

/// Persists unlocked achievements to SharedPreferences.
class AchievementRepository {
  static const String _key = 'unlocked_achievements';

  /// Load all unlocked achievements.
  Future<Map<String, Achievement>> getUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final map = <String, Achievement>{};
    for (final json in raw) {
      final a = Achievement.fromJson(jsonDecode(json) as Map<String, dynamic>);
      map[a.id] = a;
    }
    return map;
  }

  /// Unlock an achievement by ID (no-op if already unlocked).
  Future<void> unlock(String id) async {
    final current = await getUnlocked();
    if (current.containsKey(id)) return;

    current[id] = Achievement(id: id, unlockedAt: DateTime.now());
    await _save(current);
  }

  /// Unlock multiple achievements at once.
  Future<void> unlockAll(List<String> ids) async {
    if (ids.isEmpty) return;
    final current = await getUnlocked();
    final now = DateTime.now();
    for (final id in ids) {
      if (!current.containsKey(id)) {
        current[id] = Achievement(id: id, unlockedAt: now);
      }
    }
    await _save(current);
  }

  /// Reset all achievements.
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(Map<String, Achievement> map) async {
    final prefs = await SharedPreferences.getInstance();
    final list = map.values.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_key, list);
  }
}
