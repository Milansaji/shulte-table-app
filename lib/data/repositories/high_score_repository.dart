import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/high_score.dart';
import '../../core/constants/game_constants.dart';

/// Repository for managing high scores with local persistence.
///
/// Scores are stored per grid size using keys like `high_scores_grid_5`.
class HighScoreRepository {
  static const String _keyPrefix = 'high_scores_grid_';

  static String _keyForGrid(int gridSize) => '$_keyPrefix$gridSize';

  /// Save a high score for the given grid size.
  Future<void> saveHighScore(HighScore score) async {
    final prefs = await SharedPreferences.getInstance();
    final scores = await getHighScoresForGrid(score.gridSize);
    scores.add(score);

    // Sort ascending (best = lowest time first).
    scores.sort((a, b) => a.time.compareTo(b.time));

    // Keep top 10.
    if (scores.length > 10) scores.removeRange(10, scores.length);

    final jsonList = scores.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_keyForGrid(score.gridSize), jsonList);
  }

  /// Get all high scores across every grid size, sorted best-first.
  Future<List<HighScore>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final all = <HighScore>[];

    for (final size in GameConstants.availableGridSizes) {
      final jsonList = prefs.getStringList(_keyForGrid(size)) ?? [];
      all.addAll(
        jsonList.map((j) => HighScore.fromJson(jsonDecode(j))),
      );
    }

    all.sort((a, b) => a.time.compareTo(b.time));
    return all;
  }

  /// Get high scores for a specific grid size, sorted best-first.
  Future<List<HighScore>> getHighScoresForGrid(int gridSize) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyForGrid(gridSize)) ?? [];
    return jsonList
        .map((j) => HighScore.fromJson(jsonDecode(j)))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  /// Best (fastest) score for a grid size, or null.
  Future<HighScore?> getBestScoreForGrid(int gridSize) async {
    final scores = await getHighScoresForGrid(gridSize);
    return scores.isNotEmpty ? scores.first : null;
  }

  /// Clear all high scores.
  Future<void> clearAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    for (final size in GameConstants.availableGridSizes) {
      await prefs.remove(_keyForGrid(size));
    }
  }
}