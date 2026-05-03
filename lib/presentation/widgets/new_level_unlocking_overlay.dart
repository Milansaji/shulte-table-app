import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class LevelUnlockOverlay {
  static const Duration _autoDismissDelay = Duration(seconds: 4);

  static void show(
    BuildContext context, {
    required int unlockedLevel,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _LevelUnlockOverlayContent(
        unlockedLevel: unlockedLevel,
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

class _LevelUnlockOverlayContent extends StatefulWidget {
  final int unlockedLevel;
  final VoidCallback onDismiss;

  const _LevelUnlockOverlayContent({
    required this.unlockedLevel,
    required this.onDismiss,
  });

  @override
  State<_LevelUnlockOverlayContent> createState() =>
      _LevelUnlockOverlayContentState();
}

class _LevelUnlockOverlayContentState
    extends State<_LevelUnlockOverlayContent>
    with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final AnimationController _particleCtrl;

  // Lock-shackle pop: rotates the lock icon briefly on entry
  late final AnimationController _lockCtrl;
  late final Animation<double> _lockRotation;
  late final Animation<double> _lockScale;

  @override
  void initState() {
    super.initState();

    // Card entrance — identical timing to NewRecordOverlay
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut),
    );
    _cardCtrl.forward();

    // Stars / sparkles particle field
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..forward();

    // Lock icon pop — plays after card settles (~600 ms)
    _lockCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _lockRotation = Tween<double>(begin: -0.25, end: 0.0).animate(
      CurvedAnimation(parent: _lockCtrl, curve: Curves.elasticOut),
    );
    _lockScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _lockCtrl, curve: Curves.elasticOut),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _lockCtrl.forward();
    });
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _particleCtrl.dispose();
    _lockCtrl.dispose();
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
            // Dim background
            AnimatedBuilder(
              animation: _fadeAnim,
              builder: (_, __) => Container(
                width: size.width,
                height: size.height,
                color: Colors.black.withOpacity(0.55 * _fadeAnim.value),
              ),
            ),

            // ✨ Star / sparkle particles
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _StarBurstPainter(
                  progress: _particleCtrl.value,
                  context: context,
                ),
              ),
            ),

            // Card
            Center(
              child: AnimatedBuilder(
                animation: _cardCtrl,
                builder: (_, child) => FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(scale: _scaleAnim, child: child),
                ),
                child: _UnlockCard(
                  unlockedLevel: widget.unlockedLevel,
                  lockRotation: _lockRotation,
                  lockScale: _lockScale,
                  lockCtrl: _lockCtrl,
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

class _UnlockCard extends StatelessWidget {
  final int unlockedLevel;
  final Animation<double> lockRotation;
  final Animation<double> lockScale;
  final AnimationController lockCtrl;
  final VoidCallback onDismiss;

  const _UnlockCard({
    required this.unlockedLevel,
    required this.lockRotation,
    required this.lockScale,
    required this.lockCtrl,
    required this.onDismiss,
  });

  static const List<String> _levelNames = ['Easy', 'Medium', 'Hard'];
  static const List<IconData> _levelIcons = [
    Icons.emoji_events,
    Icons.local_fire_department,
    Icons.thunderstorm_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = colorScheme.surface;
    final fg = colorScheme.primary;
    final subtle = theme.textTheme.bodySmall?.color?.withOpacity(0.7) ??
        (theme.brightness == Brightness.dark
            ? Colors.white70
            : Colors.black54);

    final levelName = unlockedLevel <= _levelNames.length
        ? _levelNames[unlockedLevel - 1]
        : 'Level $unlockedLevel';
    final levelIcon = unlockedLevel <= _levelIcons.length
        ? _levelIcons[unlockedLevel - 1]
        : Icons.star_rounded;

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
          // 🔓 Animated lock icon
          AnimatedBuilder(
            animation: lockCtrl,
            builder: (_, __) => Transform.rotate(
              angle: lockRotation.value,
              child: Transform.scale(
                scale: lockScale.value,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fg.withOpacity(0.08),
                    border: Border.all(color: fg.withOpacity(0.2)),
                  ),
                  child: Icon(
                    Icons.lock_open_rounded,
                    size: 36,
                    color: fg,
                  ),
                ),
              ),
            ),
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
              'LEVEL UNLOCKED',
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
            'Well Done!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'You unlocked a new challenge.\nReady for the next level?',
            style: TextStyle(fontSize: 14, color: subtle),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Level info box
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
                  'NEW LEVEL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: subtle,
                  ),
                ),
                const SizedBox(height: 10),
                Icon(levelIcon, size: 32, color: fg),
                const SizedBox(height: 6),
                Text(
                  'Level $unlockedLevel — $levelName',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                "Let's Go!",
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
// Star-burst particle painter (replaces confetti)
// Stars radiate outward from the centre and fade as they travel.

class _StarBurstPainter extends CustomPainter {
  final double progress;
  final BuildContext context;

  static final List<_StarParticle> _particles = _generate();

  _StarBurstPainter({required this.progress, required this.context});

  static List<_StarParticle> _generate() {
    final rng = Random(7);
    return List.generate(55, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      return _StarParticle(
        angle: angle,
        speed: 0.25 + rng.nextDouble() * 0.55,
        startRadius: 0.04 + rng.nextDouble() * 0.06, // fraction of screen min
        size: 3 + rng.nextDouble() * 7,
        wobble: rng.nextDouble() * 2 * pi,
        wobbleAmp: 8 + rng.nextDouble() * 16,
        wobbleSpeed: 2 + rng.nextDouble() * 4,
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextBool() ? 1 : -1) * (1 + rng.nextDouble() * 5),
        pointCount: rng.nextBool() ? 4 : 6, // 4-point diamond or 6-point star
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fg = Theme.of(context).colorScheme.primary;
    final cx = size.width / 2;
    final cy = size.height * 0.42; // slightly above centre to align with card

    for (final p in _particles) {
      final t = (progress * p.speed).clamp(0.0, 1.0);
      if (t == 0) continue;

      final maxR = size.shortestSide * 0.55;
      final r = p.startRadius * size.shortestSide + t * maxR;
      final wobbleOffset =
          sin(p.wobble + progress * p.wobbleSpeed * 2 * pi) * p.wobbleAmp;

      final x = cx + cos(p.angle) * r + wobbleOffset;
      final y = cy + sin(p.angle) * r;

      if (x < -20 || x > size.width + 20) continue;
      if (y < -20 || y > size.height + 20) continue;

      final opacity = (1.0 - t * 0.85).clamp(0.0, 1.0);
      final paint = Paint()..color = fg.withOpacity(opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + progress * p.rotationSpeed);
      _drawStar(canvas, paint, p.size, p.pointCount);
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size, int points) {
    final path = Path();
    final outer = size / 2;
    final inner = outer * 0.45;
    final step = pi / points;

    for (int i = 0; i < points * 2; i++) {
      final angle = i * step - pi / 2;
      final r = i.isEven ? outer : inner;
      final x = cos(angle) * r;
      final y = sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) => old.progress != progress;
}

class _StarParticle {
  final double angle;
  final double speed;
  final double startRadius;
  final double size;
  final double wobble;
  final double wobbleAmp;
  final double wobbleSpeed;
  final double rotation;
  final double rotationSpeed;
  final int pointCount;

  const _StarParticle({
    required this.angle,
    required this.speed,
    required this.startRadius,
    required this.size,
    required this.wobble,
    required this.wobbleAmp,
    required this.wobbleSpeed,
    required this.rotation,
    required this.rotationSpeed,
    required this.pointCount,
  });
}