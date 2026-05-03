/// Domain Entity representing the game state and data.
class SchulteGame {
  final List<int> numbers;
  final List<bool> found;
  final int currentNumber;
  final int gridSize;
  final int totalNumbers;
  final int elapsedMilliseconds;
  final String state; // 'initial', 'running', 'completed'
  final bool isDailyChallenge;

  /// Index of the cell that was just tapped incorrectly (or null).
  /// Used to drive the wrong-tap red-flash animation.
  final int? wrongTapIndex;

  SchulteGame({
    required this.numbers,
    required this.found,
    required this.currentNumber,
    required this.gridSize,
    required this.totalNumbers,
    required this.elapsedMilliseconds,
    required this.state,
    this.isDailyChallenge = false,
    this.wrongTapIndex,
  });

  /// Check if the game is completed.
  bool get isCompleted => currentNumber > totalNumbers;

  /// Get the number of found items.
  int get foundCount => found.where((f) => f).length;

  /// Create a copy with some fields replaced.
  SchulteGame copyWith({
    List<int>? numbers,
    List<bool>? found,
    int? currentNumber,
    int? gridSize,
    int? totalNumbers,
    int? elapsedMilliseconds,
    String? state,
    bool? isDailyChallenge,
    int? wrongTapIndex,
    bool clearWrongTap = false,
  }) {
    return SchulteGame(
      numbers: numbers ?? this.numbers,
      found: found ?? this.found,
      currentNumber: currentNumber ?? this.currentNumber,
      gridSize: gridSize ?? this.gridSize,
      totalNumbers: totalNumbers ?? this.totalNumbers,
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
      state: state ?? this.state,
      isDailyChallenge: isDailyChallenge ?? this.isDailyChallenge,
      wrongTapIndex: clearWrongTap ? null : (wrongTapIndex ?? this.wrongTapIndex),
    );
  }
}
