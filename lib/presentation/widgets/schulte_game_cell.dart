import 'package:flutter/material.dart';

/// Widget for a single game cell with modern design
class SchulteGameCell extends StatefulWidget {
  final int number;
  final bool isFound;
  final VoidCallback onTap;
  final double fontSize; // Dynamic font size

  const SchulteGameCell({
    required this.number,
    required this.isFound,
    required this.onTap,
    this.fontSize = 24,
    super.key,
  });

  @override
  State<SchulteGameCell> createState() => _SchulteGameCellState();
}

class _SchulteGameCellState extends State<SchulteGameCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _playTapAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: widget.isFound
          ? null
          : () {
              _playTapAnimation();
              widget.onTap();
            },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isFound 
                ? (isDarkMode ? Colors.grey.shade800 : Colors.black87)
                : (isDarkMode ? Colors.black12 : Colors.white),
            border: Border.all(
              color: isDarkMode ? Colors.white : Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.number.toString(),
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                color: widget.isFound 
                    ? (isDarkMode ? Colors.white70 : Colors.white70)
                    : (isDarkMode ? Colors.white : Colors.black),
                decoration: widget.isFound ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
