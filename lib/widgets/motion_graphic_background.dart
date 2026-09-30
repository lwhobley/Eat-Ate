import 'dart:math' as math;
import 'package:flutter/material.dart';

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
        // Modern light canvas (soft cool off-white)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF8FAFC),
                Color(0xFFF1F5F9),
                Color(0xFFF8FAFC),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Subtle Ambient Atmospheric Glow
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

    // Soft emerald tint (subtle, airy)
    final o1X = size.width * (0.65 + 0.25 * math.cos(t));
    final o1Y = size.height * (0.2 + 0.15 * math.sin(t));
    final o1Radius = size.width * 0.75;
    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF10B981).withValues(alpha: 0.05),
          const Color(0xFF10B981).withValues(alpha: 0.015),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o1X, o1Y), radius: o1Radius));
    canvas.drawCircle(Offset(o1X, o1Y), o1Radius, p1);

    // Soft sky blue tint (subtle, airy)
    final o2X = size.width * (0.25 + 0.2 * math.sin(t * 1.3));
    final o2Y = size.height * (0.65 + 0.2 * math.cos(t * 0.9));
    final o2Radius = size.width * 0.85;
    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0EA5E9).withValues(alpha: 0.05),
          const Color(0xFF0EA5E9).withValues(alpha: 0.015),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o2X, o2Y), radius: o2Radius));
    canvas.drawCircle(Offset(o2X, o2Y), o2Radius, p2);

    // Subtle modern grid (very faint)
    if (showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.04)
        ..strokeWidth = 1.0;
      const step = 48.0;
      for (double x = 0; x < size.width; x += step) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += step) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraMeshPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
