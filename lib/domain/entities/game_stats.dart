/// Aggregate statistics tracked across all gameplay sessions.
class GameStats {
  final int totalGamesPlayed;
  final int totalTimePlayedMs;
  final Map<int, int> bestTimePerGridSize;    // gridSize → ms
  final Map<int, int> totalTimePerGridSize;   // gridSize → ms (sum)
  final Map<int, int> gamesPerGridSize;       // gridSize → count
  final int dailyChallengesCompleted;
  final Set<int> gridSizesPlayed;             // distinct grid sizes ever played

  const GameStats({
    this.totalGamesPlayed = 0,
    this.totalTimePlayedMs = 0,
    this.bestTimePerGridSize = const {},
    this.totalTimePerGridSize = const {},
    this.gamesPerGridSize = const {},
    this.dailyChallengesCompleted = 0,
    this.gridSizesPlayed = const {},
  });

  /// Average time (ms) for a given grid size, or null if never played.
  double? averageTimeForGrid(int gridSize) {
    final count = gamesPerGridSize[gridSize] ?? 0;
    if (count == 0) return null;
    return (totalTimePerGridSize[gridSize] ?? 0) / count;
  }

  /// Record a completed game and return updated stats.
  GameStats recordGame({
    required int gridSize,
    required int timeMs,
    bool isDailyChallenge = false,
  }) {
    final newBest = Map<int, int>.from(bestTimePerGridSize);
    final prev = newBest[gridSize];
    if (prev == null || timeMs < prev) {
      newBest[gridSize] = timeMs;
    }

    final newTotal = Map<int, int>.from(totalTimePerGridSize);
    newTotal[gridSize] = (newTotal[gridSize] ?? 0) + timeMs;

    final newCounts = Map<int, int>.from(gamesPerGridSize);
    newCounts[gridSize] = (newCounts[gridSize] ?? 0) + 1;

    final newPlayed = Set<int>.from(gridSizesPlayed)..add(gridSize);

    return GameStats(
      totalGamesPlayed: totalGamesPlayed + 1,
      totalTimePlayedMs: totalTimePlayedMs + timeMs,
      bestTimePerGridSize: newBest,
      totalTimePerGridSize: newTotal,
      gamesPerGridSize: newCounts,
      dailyChallengesCompleted:
          dailyChallengesCompleted + (isDailyChallenge ? 1 : 0),
      gridSizesPlayed: newPlayed,
    );
  }

  /// Serialise to JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'totalTimePlayedMs': totalTimePlayedMs,
        'bestTimePerGridSize':
            bestTimePerGridSize.map((k, v) => MapEntry(k.toString(), v)),
        'totalTimePerGridSize':
            totalTimePerGridSize.map((k, v) => MapEntry(k.toString(), v)),
        'gamesPerGridSize':
            gamesPerGridSize.map((k, v) => MapEntry(k.toString(), v)),
        'dailyChallengesCompleted': dailyChallengesCompleted,
        'gridSizesPlayed': gridSizesPlayed.toList(),
      };

  factory GameStats.fromJson(Map<String, dynamic> json) {
    Map<int, int> intMap(String key) {
      final raw = json[key] as Map<String, dynamic>? ?? {};
      return raw.map((k, v) => MapEntry(int.parse(k), v as int));
    }

    return GameStats(
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      totalTimePlayedMs: json['totalTimePlayedMs'] as int? ?? 0,
      bestTimePerGridSize: intMap('bestTimePerGridSize'),
      totalTimePerGridSize: intMap('totalTimePerGridSize'),
      gamesPerGridSize: intMap('gamesPerGridSize'),
      dailyChallengesCompleted: json['dailyChallengesCompleted'] as int? ?? 0,
      gridSizesPlayed:
          ((json['gridSizesPlayed'] as List?)?.cast<int>() ?? []).toSet(),
    );
  }
}
