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
          color: store.aiPersona.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: store.aiPersona.color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(store.aiPersona.icon, color: store.aiPersona.color, size: 14),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                store.aiPersona.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: store.aiPersona.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, color: store.aiPersona.color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context) {
    return VibrantLedCard(
      title: 'Coaching Feedback Style',
      ledColor: store.aiPersona.color,
      accentColor: store.aiPersona.color,
      trailing: LedPillBadge(
        label: store.aiPersona.displayName,
        color: store.aiPersona.color,
        icon: store.aiPersona.icon,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select how your AI coach delivers daily feedback and adjustments:',
            style: TextStyle(color: VibrantColors.textSecondary, fontSize: 13),
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
                        ? persona.color.withValues(alpha: 0.06)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? persona.color.withValues(alpha: 0.5)
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: persona.color.withValues(alpha: 0.12),
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
                                    color: isSelected
                                        ? VibrantColors.textPrimary
                                        : VibrantColors.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '• ${persona.tagline}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: persona.color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              persona.description,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: persona.color,
                          ),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AiPersonaSelector(store: store),
            const SizedBox(height: 14),
            LedCyberButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Save Coaching Style',
              gradientColors: const [
                VibrantColors.neonLime,
                Color(0xFF047857),
              ],
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
