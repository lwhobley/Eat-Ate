import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';

class MotionGraphicBackground extends StatefulWidget {
  final Widget child;
  final bool showGrid;
  final double speed;

  const MotionGraphicBackground({
    super.key,
    required this.child,
    this.showGrid = true,
    this.speed = 1.0,
  });

  @override
  State<MotionGraphicBackground> createState() => _MotionGraphicBackgroundState();
}

class _MotionGraphicBackgroundState extends State<MotionGraphicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Luminous modern slate canvas
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E293B),
                Color(0xFF0F172A),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Animated Aurora Mesh & Floating Orbs
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _AuroraMeshPainter(
                  progress: _controller.value,
                  showGrid: widget.showGrid,
                ),
              );
            },
          ),
        ),

        // Foreground Content
        widget.child,
      ],
    );
  }
}

class _AuroraMeshPainter extends CustomPainter {
  final double progress;
  final bool showGrid;

  _AuroraMeshPainter({required this.progress, required this.showGrid});

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * math.pi;

    // Orb 1: Neon Lime floating top-right to bottom-center
    final o1X = size.width * (0.65 + 0.25 * math.cos(t));
    final o1Y = size.height * (0.2 + 0.15 * math.sin(t));
    final o1Radius = size.width * 0.8;
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          VibrantColors.neonLime.withValues(alpha: 0.32),
          VibrantColors.neonLime.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o1X, o1Y), radius: o1Radius));
    canvas.drawCircle(Offset(o1X, o1Y), o1Radius, p1);

    // Orb 2: Electric Cyan floating bottom-left to center-left
    final o2X = size.width * (0.25 + 0.2 * math.sin(t * 1.3));
    final o2Y = size.height * (0.65 + 0.2 * math.cos(t * 0.9));
    final o2Radius = size.width * 0.9;
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          VibrantColors.neonCyan.withValues(alpha: 0.28),
          VibrantColors.neonCyan.withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o2X, o2Y), radius: o2Radius));
    canvas.drawCircle(Offset(o2X, o2Y), o2Radius, p2);

    // Orb 3: Vivid Magenta / Hot Coral pulsing in center-bottom
    final o3X = size.width * (0.5 + 0.3 * math.cos(t * 0.7));
    final o3Y = size.height * (0.85 + 0.1 * math.sin(t * 1.2));
    final o3Radius = size.width * 0.75;
    final p3 = Paint()
      ..shader = RadialGradient(
        colors: [
          VibrantColors.neonMagenta.withValues(alpha: 0.24),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o3X, o3Y), radius: o3Radius));
    canvas.drawCircle(Offset(o3X, o3Y), o3Radius, p3);

    // Orb 4: Solar Gold flash accent
    final o4X = size.width * (0.15 + 0.15 * math.cos(t * 1.5));
    final o4Y = size.height * (0.15 + 0.1 * math.sin(t * 0.8));
    final o4Radius = size.width * 0.55;
    final p4 = Paint()
      ..shader = RadialGradient(
        colors: [
          VibrantColors.neonGold.withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o4X, o4Y), radius: o4Radius));
    canvas.drawCircle(Offset(o4X, o4Y), o4Radius, p4);

    // Optional fine cyber-mesh grid
    if (showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFF60EFFF).withValues(alpha: 0.07)
        ..strokeWidth = 1.0;
      const step = 42.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Drifting energetic light particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    for (int i = 0; i < 28; i++) {
      final initialX = random.nextDouble() * size.width;
      final initialY = random.nextDouble() * size.height;
      final speed = 0.5 + random.nextDouble();
      final currentY = (initialY - progress * size.height * speed) % size.height;
      final currentX = initialX + math.sin(t + i) * 12;
      final alpha = (0.2 + 0.5 * math.sin(t * 2 + i)).clamp(0.0, 1.0);
      final radius = 1.0 + random.nextDouble() * 2.2;
      final color = i % 3 == 0
          ? VibrantColors.neonLime
          : (i % 3 == 1 ? VibrantColors.neonCyan : VibrantColors.neonMagenta);

      particlePaint.color = color.withValues(alpha: alpha * 0.6);
      canvas.drawCircle(Offset(currentX, currentY), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraMeshPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
