/// Domain Entity representing a high score record
class HighScore {
  final int time; // Time in milliseconds
  final DateTime date;
  final int level; // Game level (1-10)

  HighScore({
    required this.time,
    required this.date,
    this.level = 1,
  });

  /// Get formatted time string - human readable (e.g. "4.2s" or "1m 3.5s")
  String get formattedTime {
    final totalSeconds = time / 1000;
    if (totalSeconds < 60) {
      return '${totalSeconds.toStringAsFixed(1)}s';
    }
    final mins = totalSeconds ~/ 60;
    final secs = (totalSeconds % 60).toStringAsFixed(1);
    return '${mins}m ${secs}s';
  }

  /// Get formatted date string - friendly format (e.g. "Jan 3, 2025 · 14:05")
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[date.month - 1];
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$m ${date.day}, ${date.year} · $h:$min';
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'date': date.toIso8601String(),
      'level': level,
    };
  }

  /// Create from JSON
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      time: json['time'] as int,
      date: DateTime.parse(json['date'] as String),
      level: json['level'] as int? ?? 1,
    );
  }
}