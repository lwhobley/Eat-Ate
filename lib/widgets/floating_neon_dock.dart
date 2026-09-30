import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';
import 'vibrant_led_components.dart';

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
          color: const Color(0xFF0C1020).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
          boxShadow: [
            // Ambient deep lowlight shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.65),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            // LED edge ambient rim
            BoxShadow(
              color: items[selectedIndex].activeColor.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Stack(
              children: [
                // Specular top highlight line
                Positioned(
                  top: 0,
                  left: 30,
                  right: 30,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          items[selectedIndex].activeColor.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.5),
                          items[selectedIndex].activeColor.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Row(
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
                              ? item.activeColor.withValues(alpha: 0.16)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? item.activeColor.withValues(alpha: 0.5)
                                : Colors.transparent,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: item.activeColor.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isSelected
                                      ? item.activeColor
                                      : Colors.white54,
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: -2,
                                    right: -3,
                                    child: LedStatusDiode(
                                      color: item.activeColor,
                                      size: 4,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label.toUpperCase(),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w900
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
              ],
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
