import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/high_score.dart';

/// Repository for managing high scores with local persistence
class HighScoreRepository {
  static const String _keyPrefix = 'high_scores_level_';

  /// Get storage key for a specific level
  static String _getKeyForLevel(int level) {
    return '$_keyPrefix$level';
  }

  /// Save a high score
  Future<void> saveHighScore(HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    // FIX: use getHighScoresForLevel instead of getHighScores to avoid
    // cross-level score bleeding which caused duplicates on every save
    final scores = await getHighScoresForLevel(score.level);
    scores.add(score);

    // Sort by time (ascending - lower is better)
    scores.sort((a, b) => a.time.compareTo(b.time));

    // Keep only top 10 scores
    if (scores.length > 10) {
      scores.removeRange(10, scores.length);
    }

    final jsonList = scores.map((s) => jsonEncode(s.toJson())).toList();

    // Save to level-specific key
    await prefs.setStringList(_getKeyForLevel(score.level), jsonList);
  }

  /// Get all high scores across all levels, sorted by time (best first)
  Future<List<HighScore>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final allScores = <HighScore>[];

    // Get scores from all levels
    for (int level = 1; level <= 3; level++) {
      final jsonList = prefs.getStringList(_getKeyForLevel(level)) ?? [];
      final levelScores = jsonList
          .map((json) => HighScore.fromJson(jsonDecode(json)))
          .toList();
      allScores.addAll(levelScores);
    }

    allScores.sort((a, b) => a.time.compareTo(b.time));
    return allScores;
  }

  /// Get high scores for a specific level, sorted by time (best first)
  Future<List<HighScore>> getHighScoresForLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_getKeyForLevel(level)) ?? [];
    return jsonList
        .map((json) => HighScore.fromJson(jsonDecode(json)))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  /// Get the best (fastest) high score across all levels
  Future<HighScore?> getBestScore() async {
    final scores = await getHighScores();
    return scores.isNotEmpty ? scores.first : null;
  }

  /// Clear all high scores
  Future<void> clearHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    for (int level = 1; level <= 3; level++) {
      await prefs.remove(_getKeyForLevel(level));
    }
  }
}