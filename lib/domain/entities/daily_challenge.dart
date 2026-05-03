/// Daily challenge completion record for a single day.
class DailyChallenge {
  final String dateKey; // 'yyyy-MM-dd'
  final int gridSize;
  final int? bestTimeMs;
  final bool isCompleted;

  const DailyChallenge({
    required this.dateKey,
    required this.gridSize,
    this.bestTimeMs,
    this.isCompleted = false,
  });

  DailyChallenge copyWith({
    int? bestTimeMs,
    bool? isCompleted,
  }) {
    return DailyChallenge(
      dateKey: dateKey,
      gridSize: gridSize,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Formatted best time, or '--' if not completed.
  String get formattedBestTime {
    if (bestTimeMs == null) return '--';
    final s = bestTimeMs! / 1000;
    if (s < 60) return '${s.toStringAsFixed(1)}s';
    final mins = s ~/ 60;
    final secs = (s % 60).toStringAsFixed(1);
    return '${mins}m ${secs}s';
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'gridSize': gridSize,
        'bestTimeMs': bestTimeMs,
        'isCompleted': isCompleted,
      };

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      dateKey: json['dateKey'] as String,
      gridSize: json['gridSize'] as int,
      bestTimeMs: json['bestTimeMs'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  /// Generate the date key for today.
  static String todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Deterministic seed for a given date (used for consistent shuffle).
  static int seedForDate(String dateKey) {
    return dateKey.hashCode;
  }
}
