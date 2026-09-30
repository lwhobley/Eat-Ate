import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';

class FloatingNeonDock extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const FloatingNeonDock({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _DockItem(
        icon: Icons.flash_on_rounded,
        label: 'Plan',
        activeColor: VibrantColors.neonLime,
      ),
      _DockItem(
        icon: Icons.camera_enhance_rounded,
        label: 'Fuel',
        activeColor: VibrantColors.neonCyan,
      ),
      _DockItem(
        icon: Icons.accessibility_new_rounded,
        label: 'Physique',
        activeColor: VibrantColors.neonMagenta,
      ),
      _DockItem(
        icon: Icons.battery_charging_full_rounded,
        label: 'Recovery',
        activeColor: VibrantColors.neonGold,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 24,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (idx) {
                final item = items[idx];
                final isSelected = selectedIndex == idx;

                return GestureDetector(
                  onTap: () => onDestinationSelected(idx),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? item.activeColor.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? item.activeColor.withValues(alpha: 0.25)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isSelected
                              ? item.activeColor
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? item.activeColor
                                : const Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem {
  final IconData icon;
  final String label;
  final Color activeColor;

  _DockItem({
    required this.icon,
    required this.label,
    required this.activeColor,
  });
}
