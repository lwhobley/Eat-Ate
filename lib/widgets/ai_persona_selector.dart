import 'package:flutter/material.dart';
import '../models/ai_persona.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import 'vibrant_led_components.dart';

class AiPersonaSelector extends StatelessWidget {
  final Store store;
  final bool compact;

  const AiPersonaSelector({
    super.key,
    required this.store,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildExpanded(context);
  }

  Widget _buildCompact(BuildContext context) {
    return GestureDetector(
      onTap: () => showPersonaDialog(context, store),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: store.aiPersona.color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: store.aiPersona.color.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: store.aiPersona.color.withValues(alpha: 0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(store.aiPersona.icon, color: store.aiPersona.color, size: 14),
            const SizedBox(width: 6),
            Text(
              store.aiPersona.displayName.toUpperCase(),
              style: TextStyle(
                color: store.aiPersona.color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: store.aiPersona.color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return VibrantLedCard(
      title: 'AI COACHING VIBE & HONESTY LEVEL',
      ledColor: store.aiPersona.color,
      accentColor: store.aiPersona.color,
      trailing: LedPillBadge(
        label: store.aiPersona.displayName.toUpperCase(),
        color: store.aiPersona.color,
        icon: store.aiPersona.icon,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose how your AI communicates consequences, rewards, and feedback:',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
          const SizedBox(height: 12),
          Column(
            children: AiPersona.values.map((persona) {
              final isSelected = store.aiPersona == persona;
              return GestureDetector(
                onTap: () => store.setAiPersona(persona),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? persona.color.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? persona.color
                          : Colors.white.withValues(alpha: 0.08),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: persona.color.withValues(alpha: 0.25),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: persona.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          persona.icon,
                          color: persona.color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  persona.displayName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${persona.tagline}',
                                  style: TextStyle(
                                    color: persona.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              persona.description,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        LedStatusDiode(
                          color: persona.color,
                          size: 8,
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static void showPersonaDialog(BuildContext context, Store store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07080E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AiPersonaSelector(store: store),
            const SizedBox(height: 14),
            LedCyberButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'LOCK IN TONE LEVEL',
              gradientColors: const [
                VibrantColors.neonLime,
                VibrantColors.neonCyan,
              ],
              ledColor: VibrantColors.neonLime,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
