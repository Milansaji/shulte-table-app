/// Tracks the user's consecutive-day play streak.
class UserStreak {
  final int currentStreak;
  final int longestStreak;
  final String? lastPlayedDate; // 'yyyy-MM-dd'

  const UserStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPlayedDate,
  });

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastPlayedDate': lastPlayedDate,
      };

  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] as String?,
    );
  }

  UserStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastPlayedDate,
  }) {
    return UserStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }
}
