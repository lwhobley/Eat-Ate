import 'package:flutter/material.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import '../widgets/vibrant_led_components.dart';
import '../widgets/meal_decision_impact_view.dart';
import '../models/subscription_tier.dart';
import '../widgets/coach_review_card.dart';
import '../widgets/subscription_paywall_view.dart';

class PlanScreen extends StatelessWidget {
  final Store store;
  const PlanScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final p = store.plan;
        final week = store.week;
        final adherencePercent = (store.adherence * 100).round();
        final tier = store.subscriptionTier;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            // Human-in-the-Loop Coach Accountability Card
            if (tier.hasCoachReview) ...[
              CoachReviewCard(
                coach: store.coachProfile,
              ),
              const SizedBox(height: 12),
            ],

            // Free Tier Upgrade Banner (Retention conversion)
            if (tier == SubscriptionTier.free) ...[
              GestureDetector(
                onTap: () => SubscriptionPaywallView.show(context, store),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        VibrantColors.neonLime.withValues(alpha: 0.15),
                        VibrantColors.deepSpace,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: VibrantColors.neonLime.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock,
                          color: VibrantColors.neonLime, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FREE TIER • PREVIEWING ADAPTIVE BLUEPRINT',
                              style: TextStyle(
                                color: VibrantColors.neonLime,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Upgrade to Pro Annual for unlimited logging & auto-drifting avatar.',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: VibrantColors.neonLime,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'UPGRADE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // 1. Tomorrow's Workout Card with Cyber LED Action Button
            VibrantLedCard(
              title: 'TOMORROW\'S MISSION • ${p.programDay.toUpperCase()}',
              ledColor: VibrantColors.neonLime,
              accentColor: VibrantColors.neonLime,
              trailing: LedPillBadge(
                label: '$adherencePercent% LOCKED IN',
                color: VibrantColors.neonLime,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.trainingTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                      shadows: [
                        Shadow(color: VibrantColors.neonLime, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.trainingDetail,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          'Sessions: ${store.doneWorkouts} / ${store.plannedWorkouts} Crushed',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LedCyberButton(
                    onPressed: store.completePlannedWorkout,
                    label: 'Crush Workout',
                    subtitle: 'Powers dynamic avatar & weekly rebalance',
                    icon: const Icon(Icons.check_circle_outline),
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
            const SizedBox(height: 14),

            // 2. Nutrition Target with Glowing Calorie Dial / Stats
            VibrantLedCard(
              title: 'DAILY MACRO BLUEPRINT',
              ledColor: VibrantColors.neonCyan,
              accentColor: VibrantColors.neonCyan,
              trailing: const LedPillBadge(
                label: 'CALORIE BUDGET',
                color: VibrantColors.neonCyan,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroMetric(
                        label: 'CALORIES',
                        target: '${p.kcalTarget} kcal',
                        eaten: '${store.eatenKcal.round()} fueled',
                        color: VibrantColors.neonCyan,
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildMacroMetric(
                        label: 'PROTEIN',
                        target: '${p.proteinTarget}g',
                        eaten: '${store.eatenProtein.round()}g locked in',
                        color: VibrantColors.neonMagenta,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: VibrantColors.neonCyan.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: VibrantColors.neonGold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.breakfastHint,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LedCyberButton(
                    onPressed: () => _openMealImpactSheet(context),
                    label: 'Compare What You Ate vs Plan (Showdown)',
                    subtitle: 'AI breaks down rewards, consequences & auto-rebalance',
                    icon: const Icon(Icons.compare_arrows_rounded),
                    gradientColors: const [
                      VibrantColors.neonMagenta,
                      VibrantColors.neonPurple,
                    ],
                    ledColor: VibrantColors.neonMagenta,
                    chamfer: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    fullWidth: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Sleep & Recovery Target
            VibrantLedCard(
              title: 'SLEEP PROTOCOL • ANTI-BURNOUT',
              ledColor: VibrantColors.neonPurple,
              accentColor: VibrantColors.neonPurple,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.nights_stay_rounded,
                        color: VibrantColors.neonPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        p.sleepTarget,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Why: ${p.why}',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Week Rebalance Schedule
            VibrantLedCard(
              title: 'WEEK REBALANCE • NO GUILT, WE MOVE',
              ledColor: VibrantColors.neonGold,
              accentColor: VibrantColors.neonGold,
              child: Column(
                children: week.map((d) {
                  final isToday = d.date.day == DateTime.now().day;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isToday
                          ? VibrantColors.neonGold.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday
                            ? VibrantColors.neonGold.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${d.date.month}/${d.date.day}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isToday
                                  ? VibrantColors.neonGold
                                  : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${d.plan.programDay} — ${d.plan.kcalTarget} kcal',
                                style: TextStyle(
                                  color: isToday ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                d.plan.trainingTitle,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroMetric({
    required String label,
    required String target,
    required String eaten,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          target,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
            ],
          ),
        ),
        Text(
          eaten,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _openMealImpactSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF07080E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              MealDecisionImpactView(
                store: store,
                onMealLogged: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}