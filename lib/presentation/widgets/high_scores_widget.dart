import 'package:flutter/material.dart';
import '../../domain/entities/high_score.dart';

/// Widget to display high scores in a scrollable list.
class HighScoresWidget extends StatelessWidget {
  final List<HighScore> highScores;

  const HighScoresWidget({
    required this.highScores,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (highScores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.white : Colors.black)
                  .withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 40,
              color: isDark ? Colors.white : Colors.black,
            ),
            const SizedBox(height: 12),
            Text(
              'High Scores',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No scores yet. Play and set your first record!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white : Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white : Colors.black,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events,
                    color: isDark ? Colors.black : Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  'High Scores (Top 10)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Score list
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  highScores.length,
                  (index) => _buildScoreItem(
                    context,
                    index + 1,
                    highScores[index],
                    index == 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
    BuildContext context,
    int rank,
    HighScore score,
    bool isBest,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBest
            ? (isDark ? Colors.black : Colors.black87)
            : (isDark ? Colors.black : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white : Colors.black,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.white : Colors.black)
                .withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBest
                  ? Colors.black
                  : (isDark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300),
              border: Border.all(
                color: isDark ? Colors.white : Colors.black,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isBest
                      ? Colors.white
                      : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Score details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      score.formattedTime,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isBest
                            ? Colors.white
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.black),
                      ),
                    ),
                    if (isBest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: const Text(
                          '🏆 Best',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  score.formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: isBest
                        ? Colors.grey.shade400
                        : (isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}