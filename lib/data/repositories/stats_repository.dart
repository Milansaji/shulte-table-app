import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_stats.dart';

/// Persists aggregate [GameStats] to SharedPreferences.
class StatsRepository {
  static const String _key = 'game_stats';

  Future<GameStats> getStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const GameStats();
    return GameStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStats(GameStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(stats.toJson()));
  }

  Future<void> resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
