import 'dart:math';

/// Repository for game data operations.
class GameRepository {
  /// Generate a shuffled list of numbers [1..count] using a random seed.
  List<int> generateShuffledNumbers(int count) {
    final numbers = List<int>.generate(count, (i) => i + 1);
    numbers.shuffle(Random());
    return numbers;
  }

  /// Generate a deterministically shuffled list using [seed].
  /// Used for daily challenges so every user gets the same grid.
  List<int> generateSeededShuffledNumbers(int count, int seed) {
    final numbers = List<int>.generate(count, (i) => i + 1);
    numbers.shuffle(Random(seed));
    return numbers;
  }

  /// Create a list of found flags (all initially false).
  List<bool> generateFoundList(int count) {
    return List<bool>.filled(count, false);
  }
}
