import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/subscription_tier.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import 'vibrant_led_components.dart';

class SubscriptionPaywallView extends StatefulWidget {
  final Store store;
  final VoidCallback? onDismissed;

  const SubscriptionPaywallView({
    super.key,
    required this.store,
    this.onDismissed,
  });

  static Future<void> show(BuildContext context, Store store) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubscriptionPaywallView(store: store),
    );
  }

  @override
  State<SubscriptionPaywallView> createState() =>
      _SubscriptionPaywallViewState();
}

class _SubscriptionPaywallViewState extends State<SubscriptionPaywallView> {
  // Annual is preselected by default because annual plans retain at 33% vs 17% for monthly
  SubscriptionTier _selectedTier = SubscriptionTier.proAnnual;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final currentTier = widget.store.subscriptionTier;

        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: VibrantColors.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: VibrantColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const LedStatusDiode(
                              color: VibrantColors.neonLime,
                              size: 8,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'GROWTH & MONETIZATION ENGINE',
                              style: TextStyle(
                                color: VibrantColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Choose Your Tier',
                          style: TextStyle(
                            color: VibrantColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: VibrantColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              const Divider(color: VibrantColors.border, height: 1),

              // Core Value Banner
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: VibrantColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up,
                      color: VibrantColors.neonGold,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: VibrantColors.textSecondary,
                            fontSize: 11,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: 'The Avatar ',
                              style: TextStyle(
                                color: VibrantColors.neonCyan,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: 'pays acquisition • '),
                            TextSpan(
                              text: 'Daily Blueprint ',
                              style: TextStyle(
                                color: VibrantColors.neonLime,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: 'pays retention • '),
                            TextSpan(
                              text: 'Human Coach ',
                              style: TextStyle(
                                color: VibrantColors.neonMagenta,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: 'lifts ARPU.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable plans list
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // 1. Pro Annual (Preselected Default - High Retention)
                    _buildPlanCard(
                      tier: SubscriptionTier.proAnnual,
                      badgeText: '⭐ DEFAULT • 33% 1-YR RETENTION',
                      badgeColor: VibrantColors.neonLime,
                      title: 'Pro Subscription (Annual)',
                      price: '\$79.99 / year',
                      priceSub: '~\$6.67/mo • Save 55% over monthly',
                      tagline:
                          'Annual retention benchmarks at 33% vs 17% monthly. Pays for itself in consistency.',
                      features: [
                        'Unlimited photo, voice & barcode food logging',
                        'Bi-directional wearable sync (Apple Health, Oura, Whoop)',
                        'Adaptive daily plan & Sunday auto-rebalance blueprint',
                        'Live-updating avatar drifting with adherence',
                      ],
                      isCurrent: currentTier == SubscriptionTier.proAnnual,
                    ),

                    const SizedBox(height: 12),

                    // 2. Pro Monthly
                    _buildPlanCard(
                      tier: SubscriptionTier.proMonthly,
                      badgeText: 'MONTHLY FLEXIBILITY',
                      badgeColor: VibrantColors.neonCyan,
                      title: 'Pro Subscription (Monthly)',
                      price: '\$14.99 / month',
                      priceSub: 'Cancel anytime • 17% retention benchmark',
                      tagline: 'Full retention layer with monthly commitment.',
                      features: [
                        'Unlimited photo, voice & quick food logging',
                        'Apple Health & Oura / Whoop wearable telemetry',
                        'Daily adaptive rebalance engine',
                        'Live dynamic physique avatar',
                      ],
                      isCurrent: currentTier == SubscriptionTier.proMonthly,
                    ),

                    const SizedBox(height: 12),

                    // 3. Human-in-the-Loop Tier
                    _buildPlanCard(
                      tier: SubscriptionTier.coachLoop,
                      badgeText: '🔥 ARPU LIFT • REAL CERTIFIED COACH',
                      badgeColor: VibrantColors.neonMagenta,
                      title: 'Human-in-the-Loop Coaching',
                      price: '\$49.00 / month',
                      priceSub: 'High-Touch Accountability',
                      tagline:
                          'The AI does the admin, the human does the accountability. Real certified CSCS coach reviews your telemetry weekly.',
                      features: [
                        'Everything in Pro Annual included',
                        'Weekly telemetry & diet review by Coach Sarah Jenkins, CSCS',
                        'Human accountability check-ins every Sunday morning',
                        'Priority coach messaging for meal & workout swaps',
                      ],
                      isCurrent: currentTier == SubscriptionTier.coachLoop,
                    ),

                    const SizedBox(height: 12),

                    // 4. Free Tier
                    _buildPlanCard(
                      tier: SubscriptionTier.free,
                      badgeText: 'ACQUISITION ENGINE',
                      badgeColor: Colors.white54,
                      title: 'Free Experience',
                      price: '\$0 / Free Forever',
                      priceSub: 'Zero friction trial',
                      tagline:
                          'The avatar and slider + limited logging. Enough to get the "whoa, that\'s me" moment and a shareable clip.',
                      features: [
                        'Full interactive Physique Recomp Dial & Avatar',
                        'Instant viral transformation reel & clip export',
                        'Up to 3 food logs per day',
                        'Standard AI nutritionist feedback',
                      ],
                      isCurrent: currentTier == SubscriptionTier.free,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: VibrantColors.border,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedTier.displayName.toUpperCase(),
                              style: TextStyle(
                                color: _selectedTier.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              _selectedTier.priceDisplay,
                              style: const TextStyle(
                                color: VibrantColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LedCyberButton(
                        label: currentTier == _selectedTier
                            ? 'CURRENT'
                            : 'ACTIVATE',
                        icon: const Icon(Icons.flash_on),
                        gradientColors: [
                          _selectedTier.color,
                          VibrantColors.neonCyan,
                        ],
                        ledColor: _selectedTier.color,
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          widget.store.setSubscriptionTier(_selectedTier);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF0F172A),
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: _selectedTier.color, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Activated ${_selectedTier.displayName}! Retention protocol engaged.',
                                      style: TextStyle(
                                        color: _selectedTier.color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlanCard({
    required SubscriptionTier tier,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String price,
    required String priceSub,
    required String tagline,
    required List<String> features,
    required bool isCurrent,
  }) {
    final isSelected = _selectedTier == tier;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedTier = tier);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? tier.color.withValues(alpha: 0.08)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? tier.color : VibrantColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.02),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor, width: 1),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: VibrantColors.border),
                    ),
                    child: const Text(
                      'ACTIVE NOW',
                      style: TextStyle(
                        color: VibrantColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: VibrantColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    color: tier.color,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Text(
              priceSub,
              style: const TextStyle(
                color: VibrantColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tagline,
              style: const TextStyle(
                color: VibrantColors.textSecondary,
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            ...features.map((feat) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check,
                        size: 13,
                        color: tier.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feat,
                          style: const TextStyle(
                            color: VibrantColors.textPrimary,
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
