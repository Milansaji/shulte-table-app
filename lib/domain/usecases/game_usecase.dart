import '../../core/constants/game_constants.dart';
import '../../domain/entities/schulte_game.dart';
import '../../data/repositories/game_repository.dart';

/// Business logic for managing the Schulte Table game.
class GameUseCase {
  final GameRepository repository;

  GameUseCase(this.repository);

  /// Initialize a new game for [gridSize].
  SchulteGame initializeGame({
    required int gridSize,
    bool isDailyChallenge = false,
    int? seed,
  }) {
    final total = GameConstants.totalNumbersForGrid(gridSize);
    final numbers = seed != null
        ? repository.generateSeededShuffledNumbers(total, seed)
        : repository.generateShuffledNumbers(total);

    return SchulteGame(
      numbers: numbers,
      found: repository.generateFoundList(total),
      currentNumber: 1,
      gridSize: gridSize,
      totalNumbers: total,
      elapsedMilliseconds: 0,
      state: GameConstants.stateRunning,
      isDailyChallenge: isDailyChallenge,
    );
  }

  /// Handle number tap — returns updated game.
  ///
  /// If the tap is correct, marks the cell as found and advances.
  /// If incorrect, sets [wrongTapIndex] so the UI can show feedback.
  SchulteGame handleNumberTap(SchulteGame game, int index) {
    // Already found — ignore.
    if (game.found[index]) return game;

    // Wrong number — mark wrong tap.
    if (game.numbers[index] != game.currentNumber) {
      return game.copyWith(wrongTapIndex: index);
    }

    // Correct tap.
    final newFound = List<bool>.from(game.found);
    newFound[index] = true;

    final newCurrentNumber = game.currentNumber + 1;
    final isCompleted = newCurrentNumber > game.totalNumbers;

    return game.copyWith(
      found: newFound,
      currentNumber: newCurrentNumber,
      state: isCompleted
          ? GameConstants.stateCompleted
          : GameConstants.stateRunning,
      clearWrongTap: true,
    );
  }

  /// Clear the wrong-tap indicator (called after the feedback duration).
  SchulteGame clearWrongTap(SchulteGame game) {
    return game.copyWith(clearWrongTap: true);
  }

  /// Update elapsed time.
  SchulteGame updateElapsedTime(SchulteGame game, int milliseconds) {
    return game.copyWith(elapsedMilliseconds: milliseconds);
  }
}
