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

  /// Get formatted time string (MM:SS format)
  String get formattedTime {
    final seconds = time ~/ 1000;
    final msec = time % 1000;
    return '${seconds.toString().padLeft(2, '0')}:${(msec ~/ 10).toString().padLeft(2, '0')}';
  }

  /// Get formatted date string
  String get formattedDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
