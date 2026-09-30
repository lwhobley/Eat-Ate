import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';

/// Pulsing glowing LED status diode with highlights and glow aura
class LedStatusDiode extends StatefulWidget {
  final Color color;
  final double size;
  final bool isPulsing;
  final String? label;

  const LedStatusDiode({
    super.key,
    this.color = VibrantColors.neonLime,
    this.size = 8.0,
    this.isPulsing = true,
    this.label,
  });

  @override
  State<LedStatusDiode> createState() => _LedStatusDiodeState();
}

class _LedStatusDiodeState extends State<LedStatusDiode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isPulsing) {
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant LedStatusDiode oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isPulsing && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget diode = AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, _) {
        final glowScale = 0.5 + 0.5 * _pulseCtrl.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(widget.color, Colors.white, 0.45)!,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.9 * glowScale),
                blurRadius: widget.size * 1.5,
                spreadRadius: widget.size * 0.4 * glowScale,
              ),
              BoxShadow(
                color: widget.color.withValues(alpha: 0.4 * glowScale),
                blurRadius: widget.size * 3.5,
                spreadRadius: widget.size * 1.0 * glowScale,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );

    if (widget.label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          diode,
          const SizedBox(width: 8),
          Text(
            widget.label!,
            style: TextStyle(
              color: widget.color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      );
    }
    return diode;
  }
}

/// Uniquely shaped cyber button with chamfered corners, specular highlights,
/// deep lowlight shadows, and an embedded glowing LED diode.
class LedCyberButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String label;
  final String? subtitle;
  final List<Color> gradientColors;
  final Color ledColor;
  final double chamfer;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;

  const LedCyberButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.subtitle,
    this.icon,
    this.gradientColors = const [VibrantColors.neonLime, VibrantColors.neonCyan],
    this.ledColor = VibrantColors.neonLime,
    this.chamfer = 14.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.fullWidth = false,
  });

  @override
  State<LedCyberButton> createState() => _LedCyberButtonState();
}

class _LedCyberButtonState extends State<LedCyberButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: widget.fullWidth ? double.infinity : null,
          child: CustomPaint(
            painter: _CyberButtonFramePainter(
              chamfer: widget.chamfer,
              isPressed: _isPressed,
              gradientColors: isDisabled
                  ? [Colors.grey.shade800, Colors.grey.shade900]
                  : widget.gradientColors,
              ledColor: isDisabled ? Colors.grey : widget.ledColor,
            ),
            child: ClipPath(
              clipper: _CyberChamferClipper(widget.chamfer),
              child: Container(
                padding: widget.padding,
                child: Row(
                  mainAxisSize:
                      widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Embedded pulsing LED indicator
                    LedStatusDiode(
                      color: isDisabled ? Colors.grey : widget.ledColor,
                      size: 7,
                      isPulsing: !isDisabled,
                    ),
                    const SizedBox(width: 12),
                    if (widget.icon != null) ...[
                      IconTheme(
                        data: const IconThemeData(
                          color: VibrantColors.obsidianVoid,
                          size: 19,
                        ),
                        child: widget.icon!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.label.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VibrantColors.obsidianVoid,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: VibrantColors.obsidianVoid.withValues(alpha: 0.8),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom path clipper that cuts top-right and bottom-left chamfers
class _CyberChamferClipper extends CustomClipper<Path> {
  final double chamfer;
  _CyberChamferClipper(this.chamfer);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, chamfer);
    path.lineTo(chamfer, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - chamfer);
    path.lineTo(size.width - chamfer, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CyberChamferClipper oldClipper) =>
      oldClipper.chamfer != chamfer;
}

/// Custom painter for cyber button frame, specular highlights, and deep lowlights
class _CyberButtonFramePainter extends CustomPainter {
  final double chamfer;
  final bool isPressed;
  final List<Color> gradientColors;
  final Color ledColor;

  _CyberButtonFramePainter({
    required this.chamfer,
    required this.isPressed,
    required this.gradientColors,
    required this.ledColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..moveTo(0, chamfer)
      ..lineTo(chamfer, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - chamfer)
      ..lineTo(size.width - chamfer, size.height)
      ..lineTo(0, size.height)
      ..close();

    // 1. Ambient LED Glow Drop Shadow
    if (!isPressed) {
      final glowPaint = Paint()
        ..color = ledColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawPath(path, glowPaint);
    }

    // 2. Button Body Gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(rect);
    canvas.drawPath(path, fillPaint);

    // 3. Specular Highlight (Top & Top-Left bevel)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isPressed ? 0.2 : 0.65)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    final highlightPath = Path()
      ..moveTo(0, chamfer)
      ..lineTo(chamfer, 0)
      ..lineTo(size.width, 0);
    canvas.drawPath(highlightPath, highlightPaint);

    // 4. Lowlight Shadow (Bottom & Bottom-Right bevel for 3D depth)
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isPressed ? 0.7 : 0.45)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    final shadowPath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height - chamfer)
      ..lineTo(size.width - chamfer, size.height)
      ..lineTo(0, size.height);
    canvas.drawPath(shadowPath, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberButtonFramePainter oldDelegate) =>
      oldDelegate.isPressed != isPressed || oldDelegate.ledColor != ledColor;
}

/// Translucent picturesque glass card with specular highlights and an active LED indicator
class VibrantLedCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;
  final Color ledColor;
  final Color accentColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const VibrantLedCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.ledColor = VibrantColors.neonLime,
    this.accentColor = VibrantColors.neonCyan,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF162032),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          // Ambient soft shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          // Vivid LED rim glow
          BoxShadow(
            color: ledColor.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Stack(
            children: [
              // Specular Top Highlight line
              Positioned(
                top: 0,
                left: 20,
                right: 20,
                height: 1.2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.4),
                        accentColor.withValues(alpha: 0.8),
                        Colors.white.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null || trailing != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (title != null)
                            Expanded(
                              child: Row(
                                children: [
                                  LedStatusDiode(
                                    color: ledColor,
                                    size: 7,
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      title!.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (trailing != null) ...[
                            const SizedBox(width: 8),
                            trailing!,
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: cardContent,
      );
    }
    return cardContent;
  }
}

/// Glowing Pill Badge with LED
class LedPillBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const LedPillBadge({
    super.key,
    required this.label,
    this.color = VibrantColors.neonLime,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LedStatusDiode(color: color, size: 5),
          const SizedBox(width: 6),
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
