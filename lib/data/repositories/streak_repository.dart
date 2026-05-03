import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_streak.dart';

/// Persists [UserStreak] to SharedPreferences.
class StreakRepository {
  static const String _key = 'user_streak';

  Future<UserStreak> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const UserStreak();
    return UserStreak.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveStreak(UserStreak streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(streak.toJson()));
  }

  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
