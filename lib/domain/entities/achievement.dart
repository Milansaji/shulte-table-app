/// A single unlocked (or locked) achievement instance.
class Achievement {
  final String id;
  final DateTime? unlockedAt;

  const Achievement({required this.id, this.unlockedAt});

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}
