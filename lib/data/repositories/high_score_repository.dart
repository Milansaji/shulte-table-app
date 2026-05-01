import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/high_score.dart';

/// Repository for managing high scores with local persistence
class HighScoreRepository {
  static const String _key = 'high_scores';

  /// Save a high score
  Future<void> saveHighScore(HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await getHighScores();
    
    scores.add(score);
    // Sort by time (ascending - lower is better)
    scores.sort((a, b) => a.time.compareTo(b.time));
    
    // Keep only top 10 scores
    if (scores.length > 10) {
      scores.removeRange(10, scores.length);
    }

    final jsonList = scores.map((score) => jsonEncode(score.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Get all high scores sorted by time (best first)
  Future<List<HighScore>> getHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    
    return jsonList
        .map((json) => HighScore.fromJson(jsonDecode(json)))
        .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
  }

  /// Get the best (fastest) high score
  Future<HighScore?> getBestScore() async {
    final scores = await getHighScores();
    return scores.isNotEmpty ? scores.first : null;
  }

  /// Clear all high scores
  Future<void> clearHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
