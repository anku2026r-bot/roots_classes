import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// A sleek global touch effect that adds an institutional, modern expanding
/// ripple wave and micro-glow animation wherever the user taps or clicks across
/// the entire application without interfering with gestures or performance.
class GlobalTapEffect extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Color? rippleColor;

  const GlobalTapEffect({
    super.key,
    required this.child,
    this.enabled = true,
    this.rippleColor,
  });

  @override
  State<GlobalTapEffect> createState() => _GlobalTapEffectState();
}

class _GlobalTapEffectState extends State<GlobalTapEffect>
    with SingleTickerProviderStateMixin {
  final List<_TapWave> _waves = [];
  late final Ticker _ticker;
  final math.Random _random = math.Random();

  static const int _waveDurationMs = 450;
  static const int _maxConcurrentWaves = 6;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _waves.clear();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_waves.isEmpty) {
      if (_ticker.isTicking) _ticker.stop();
      return;
    }

    final now = DateTime.now();
    _waves.removeWhere((wave) {
      final elapsedMs = now.difference(wave.startTime).inMilliseconds;
      return elapsedMs >= _waveDurationMs;
    });

    if (mounted) {
      setState(() {});
    }

    if (_waves.isEmpty && _ticker.isTicking) {
      _ticker.stop();
    }
  }

  void _handlePointerDown(PointerDownEvent details) {
    if (!widget.enabled) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = widget.rippleColor ??
        (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

    // Limit active waves for buttery smooth 120fps performance
    if (_waves.length >= _maxConcurrentWaves) {
      _waves.removeAt(0);
    }

    // Generate 4 subtle micro-sparkle particles
    final particles = List.generate(4, (index) {
      final baseAngle = (index * (math.pi / 2)) + (_random.nextDouble() * 0.4 - 0.2);
      return _Particle(
        angle: baseAngle,
        distance: 28.0 + _random.nextDouble() * 16.0,
        size: 2.2 + _random.nextDouble() * 1.4,
      );
    });

    _waves.add(
      _TapWave(
        position: details.position,
        startTime: DateTime.now(),
        color: defaultColor,
        particles: particles,
      ),
    );

    if (!_ticker.isTicking) {
      _ticker.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          if (_waves.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GlobalTapPainter(
                    waves: List.unmodifiable(_waves),
                    now: DateTime.now(),
                    durationMs: _waveDurationMs,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TapWave {
  final Offset position;
  final DateTime startTime;
  final Color color;
  final List<_Particle> particles;

  _TapWave({
    required this.position,
    required this.startTime,
    required this.color,
    required this.particles,
  });
}

class _Particle {
  final double angle;
  final double distance;
  final double size;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
  });
}

class _GlobalTapPainter extends CustomPainter {
  final List<_TapWave> waves;
  final DateTime now;
  final int durationMs;

  _GlobalTapPainter({
    required this.waves,
    required this.now,
    required this.durationMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final wave in waves) {
      final elapsedMs = now.difference(wave.startTime).inMilliseconds;
      final rawProgress = (elapsedMs / durationMs).clamp(0.0, 1.0);
      if (rawProgress >= 1.0) continue;

      final progress = Curves.easeOutCubic.transform(rawProgress);
      final opacity = (1.0 - rawProgress).clamp(0.0, 1.0);

      final center = wave.position;

      // 1. Soft inner glowing aura
      final innerRadius = 24.0 * progress;
      final innerPaint = Paint()
        ..color = wave.color.withValues(alpha: 0.16 * opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, innerRadius, innerPaint);

      // 2. Crisp expanding ripple wave ring
      final outerRadius = 8.0 + (36.0 * progress);
      final ringPaint = Paint()
        ..color = wave.color.withValues(alpha: 0.42 * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, 2.4 * (1.0 - progress));
      canvas.drawCircle(center, outerRadius, ringPaint);

      // 3. Subtle micro particles radiating outward
      for (final p in wave.particles) {
        final currentDist = p.distance * progress;
        final pOffset = Offset(
          center.dx + math.cos(p.angle) * currentDist,
          center.dy + math.sin(p.angle) * currentDist,
        );
        final pRadius = math.max(0.5, p.size * (1.0 - progress));
        final pPaint = Paint()
          ..color = wave.color.withValues(alpha: 0.55 * opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pOffset, pRadius, pPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlobalTapPainter oldDelegate) => true;
}
