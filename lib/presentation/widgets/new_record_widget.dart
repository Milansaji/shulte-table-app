
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class NewRecordOverlay {
  static const Duration _autoDismissDelay = Duration(seconds: 4);

  static void show(
    BuildContext context, {
    required String time,
    required int level,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _NewRecordOverlayContent(
        time: time,
        level: level,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(_autoDismissDelay, () {
      if (entry.mounted) entry.remove();
    });
  }
}

// ─────────────────────────────────────────────────────────────

class _NewRecordOverlayContent extends StatefulWidget {
  final String time;
  final int level;
  final VoidCallback onDismiss;

  const _NewRecordOverlayContent({
    required this.time,
    required this.level,
    required this.onDismiss,
  });

  @override
  State<_NewRecordOverlayContent> createState() =>
      _NewRecordOverlayContentState();
}

class _NewRecordOverlayContentState extends State<_NewRecordOverlayContent>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();

    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut),
    );

    _cardCtrl.forward();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 🔥 Dim background (theme-based)
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, __) => Container(
                width: size.width,
                height: size.height,
                color: Colors.black.withOpacity(0.55 * _fadeAnim.value),
              ),
            ),

            // 🎉 Confetti
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _ConfettiPainter(
                  progress: _particleCtrl.value,
                  context: context,
                ),
              ),
            ),

            // 🎯 Card
            Center(
              child: AnimatedBuilder(
                animation: _cardCtrl,
                builder: (_, child) => FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(scale: _scaleAnim, child: child),
                ),
                child: _RecordCard(
                  time: widget.time,
                  level: widget.level,
                  onDismiss: widget.onDismiss,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final String time;
  final int level;
  final VoidCallback onDismiss;

  const _RecordCard({
    required this.time,
    required this.level,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = colorScheme.surface;
    final fg = colorScheme.primary;
    final subtle = theme.textTheme.bodySmall?.color?.withOpacity(0.7)
        ?? (theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54);

    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fg.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: fg.withOpacity(0.15),
            blurRadius: 32,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🏆 Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg.withOpacity(0.08),
              border: Border.all(color: fg.withOpacity(0.2)),
            ),
            child: Icon(Icons.emoji_events_rounded, size: 36, color: fg),
          ),

          const SizedBox(height: 20),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: fg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NEW RECORD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: bg,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'You set the best time\nfor Level $level',
            style: TextStyle(
              fontSize: 14,
              color: subtle,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Time box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: fg.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: fg.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Text(
                  'YOUR TIME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: subtle,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: fg,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Button
          GestureDetector(
            onTap: onDismiss,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: fg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Awesome!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: bg,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Tap anywhere to close',
            style: TextStyle(fontSize: 11, color: subtle),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final BuildContext context;

  static final List<_Particle> _particles = _generateParticles();

  _ConfettiPainter({required this.progress, required this.context});

  static List<_Particle> _generateParticles() {
    final rng = Random(42);
    return List.generate(60, (_) {
      return _Particle(
        x: rng.nextDouble(),
        startY: -0.05 - rng.nextDouble() * 0.2,
        speed: 0.3 + rng.nextDouble() * 0.5,
        size: 4 + rng.nextDouble() * 6,
        wobble: rng.nextDouble() * 2 * pi,
        wobbleSpeed: 2 + rng.nextDouble() * 3,
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextBool() ? 1 : -1) *
            (1 + rng.nextDouble() * 4),
        colorIndex: rng.nextInt(6),
        isCircle: rng.nextBool(),
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fg = Theme.of(context).colorScheme.primary;

    for (final p in _particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      if (t == 0) continue;

      final x = p.x * size.width +
          sin(p.wobble + progress * p.wobbleSpeed * 2 * pi) * 20;
      final y = (p.startY + t) * size.height;

      if (y > size.height + 20) continue;

      final paint = Paint()
        ..color = fg.withOpacity(1.0 - t * 0.4);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * p.rotationSpeed);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double wobble;
  final double wobbleSpeed;
  final double rotation;
  final double rotationSpeed;
  final int colorIndex;
  final bool isCircle;

  const _Particle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.wobble,
    required this.wobbleSpeed,
    required this.rotation,
    required this.rotationSpeed,
    required this.colorIndex,
    required this.isCircle,
  });
}
