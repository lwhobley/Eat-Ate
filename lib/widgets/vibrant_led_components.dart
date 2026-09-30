import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';

/// Clean status indicator dot for metric and sync states
class LedStatusDiode extends StatelessWidget {
  final Color color;
  final double size;
  final bool isPulsing;
  final String? label;

  const LedStatusDiode({
    super.key,
    this.color = VibrantColors.neonLime,
    this.size = 8.0,
    this.isPulsing = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Widget diode = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          diode,
          const SizedBox(width: 8),
          Text(
            label!,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    return diode;
  }
}

/// Clean, tactile athletic button with smooth rounded corners,
/// high contrast typography, and premium tap feel.
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
    this.gradientColors = const [VibrantColors.neonLime, Color(0xFF047857)],
    this.ledColor = VibrantColors.neonLime,
    this.chamfer = 14.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDisabled
                  ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                  : widget.gradientColors,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: widget.gradientColors.first.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: widget.padding,
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                IconTheme(
                  data: const IconThemeData(
                    color: Colors.white,
                    size: 18,
                  ),
                  child: widget.icon!,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean, modern athletic card with crisp slate borders and soft elevation
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
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
                        child: Text(
                          title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: VibrantColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
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
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }
    return cardContent;
  }
}

/// Clean Pill Badge with subtle tint and crisp typography
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
