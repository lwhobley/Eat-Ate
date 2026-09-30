import 'package:flutter/material.dart';

/// Clean, serene light canvas background that provides high contrast
/// and zero battery drain (no animated grids or faux sci-fi orbs).
class MotionGraphicBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final double speed;

  const MotionGraphicBackground({
    super.key,
    required this.child,
    this.showGrid = false,
    this.speed = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: child,
    );
  }
}
