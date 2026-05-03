import 'package:flutter/material.dart';

/// Widget for a single game cell with tap-scale animation and wrong-tap feedback.
class SchulteGameCell extends StatefulWidget {
  final int number;
  final bool isFound;
  final bool isWrongTap;
  final VoidCallback onTap;
  final double fontSize;

  const SchulteGameCell({
    required this.number,
    required this.isFound,
    required this.onTap,
    this.isWrongTap = false,
    this.fontSize = 24,
    super.key,
  });

  @override
  State<SchulteGameCell> createState() => _SchulteGameCellState();
}

class _SchulteGameCellState extends State<SchulteGameCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SchulteGameCell old) {
    super.didUpdateWidget(old);
    // Trigger a shake-like bounce on wrong tap.
    if (widget.isWrongTap && !old.isWrongTap) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playTapAnimation() {
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine cell colours.
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (widget.isFound) {
      bgColor = isDark ? Colors.grey.shade800 : Colors.black87;
      textColor = isDark ? Colors.white70 : Colors.white70;
      borderColor = isDark ? Colors.white30 : Colors.black26;
    } else if (widget.isWrongTap) {
      bgColor = Colors.red.shade700.withValues(alpha: 0.25);
      textColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
      borderColor = Colors.red;
    } else {
      bgColor = isDark ? Colors.black12 : Colors.white;
      textColor = isDark ? Colors.white : Colors.black;
      borderColor = isDark ? Colors.white : Colors.black;
    }

    return GestureDetector(
      onTap: widget.isFound
          ? null
          : () {
              _playTapAnimation();
              widget.onTap();
            },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.08),
                blurRadius: 6,
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
                color: textColor,
                decoration:
                    widget.isFound ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
