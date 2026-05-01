import 'package:flutter/material.dart';

/// Circular progress timer widget for modern UI
class CircularTimerWidget extends StatelessWidget {
  final String time;
  final int currentNumber;
  final int totalNumbers;

  const CircularTimerWidget({
    required this.time,
    required this.currentNumber,
    required this.totalNumbers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentNumber / totalNumbers;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? const Color(0xFF1A1F2E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? const Color(0xFF00D9FF) : Colors.black).withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
            // Progress ring
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                ),
              ),
            ),
            // Center content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? const Color(0xFF00D9FF) : Colors.black,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currentNumber / $totalNumbers',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
