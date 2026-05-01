import '../../core/constants/game_constants.dart';
import '../../domain/entities/schulte_game.dart';
import '../../data/repositories/game_repository.dart';

/// Business logic for managing the Schulte Table game
class GameUseCase {
  final GameRepository repository;

  GameUseCase(this.repository);

  /// Initialize a new game
  SchulteGame initializeGame({
    int gridSize = GameConstants.defaultGridSize,
    int totalNumbers = GameConstants.defaultTotalNumbers,
  }) {
    return SchulteGame(
      numbers: repository.generateShuffledNumbers(totalNumbers),
      found: repository.generateFoundList(totalNumbers),
      currentNumber: 1,
      gridSize: gridSize,
      totalNumbers: totalNumbers,
      elapsedMilliseconds: 0,
      state: GameConstants.stateRunning,
    );
  }

  /// Handle number tap
  SchulteGame handleNumberTap(
    SchulteGame game,
    int index,
  ) {
    // Only tap unfound numbers
    if (game.found[index]) {
      return game;
    }

    // Check if the tapped number is the current expected number
    if (game.numbers[index] != game.currentNumber) {
      return game;
    }

    // Update found and current number
    final newFound = List<bool>.from(game.found);
    newFound[index] = true;

    final newCurrentNumber = game.currentNumber + 1;
    final isCompleted = newCurrentNumber > game.totalNumbers;

    return game.copyWith(
      found: newFound,
      currentNumber: newCurrentNumber,
      state: isCompleted ? GameConstants.stateCompleted : GameConstants.stateRunning,
    );
  }

  /// Update elapsed time
  SchulteGame updateElapsedTime(
    SchulteGame game,
    int milliseconds,
  ) {
    return game.copyWith(elapsedMilliseconds: milliseconds);
  }
}
