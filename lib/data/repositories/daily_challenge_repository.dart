import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/daily_challenge.dart';

/// Persists daily challenge completion results.
class DailyChallengeRepository {
  static const String _keyPrefix = 'daily_challenge_';

  static String _keyForDate(String dateKey) => '$_keyPrefix$dateKey';

  /// Get the daily challenge result for a given date, or null.
  Future<DailyChallenge?> getResult(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyForDate(dateKey));
    if (raw == null) return null;
    return DailyChallenge.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Save / update a daily challenge result.
  Future<void> saveResult(DailyChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyForDate(challenge.dateKey),
      jsonEncode(challenge.toJson()),
    );
  }

  /// Count total completed daily challenges (scans all keys).
  Future<int> countCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    int count = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_keyPrefix)) {
        final raw = prefs.getString(key);
        if (raw != null) {
          final data = jsonDecode(raw) as Map<String, dynamic>;
          if (data['isCompleted'] == true) count++;
        }
      }
    }
    return count;
  }

  /// Clear all daily challenge data.
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
