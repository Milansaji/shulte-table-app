import 'dart:math';

/// Repository for game data operations
class GameRepository {
  /// Generate a shuffled list of numbers
  List<int> generateShuffledNumbers(int count) {
    final numbers = List<int>.generate(count, (i) => i + 1);
    numbers.shuffle(Random());
    return numbers;
  }

  /// Create a list of found flags (all initially false)
  List<bool> generateFoundList(int count) {
    return List<bool>.filled(count, false);
  }
}
