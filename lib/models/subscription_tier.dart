import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';

enum SubscriptionTier {
  free,
  proMonthly,
  proAnnual,
  coachLoop,
  b2bPartner,
}

enum PartnerType {
  gymChain,
  employerWellness,
  glp1Telehealth,
}

class PartnerOrg {
  final String id;
  final String name;
  final String code;
  final PartnerType type;
  final String tag;
  final Color themeColor;

  const PartnerOrg({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.tag,
    required this.themeColor,
  });

  static const List<PartnerOrg> presets = [
    PartnerOrg(
      id: 'equinox',
      name: 'Equinox Club Performance',
      code: 'EQUINOX',
      type: PartnerType.gymChain,
      tag: 'US GYM CHAIN PARTNER',
      themeColor: VibrantColors.neonGold,
    ),
    PartnerOrg(
      id: 'vitality_corp',
      name: 'Enterprise Corporate Wellness',
      code: 'WELLNESS',
      type: PartnerType.employerWellness,
      tag: 'EMPLOYER HEALTH BENEFIT',
      themeColor: VibrantColors.neonCyan,
    ),
    PartnerOrg(
      id: 'glp1_rx',
      name: 'Metabolic GLP-1 Telehealth Clinic',
      code: 'GLP1',
      type: PartnerType.glp1Telehealth,
      tag: 'GLP-1 LIFESTYLE & RETENTION LAYER',
      themeColor: VibrantColors.neonLime,
    ),
  ];

  static PartnerOrg? fromCode(String code) {
    final cleaned = code.trim().toUpperCase();
    for (final p in presets) {
      if (p.code == cleaned) return p;
    }
    return null;
  }
}

class CoachProfile {
  final String name;
  final String credentials;
  final String avatarInitials;
  final String nextCheckInDate;
  final String latestFeedback;

  const CoachProfile({
    required this.name,
    required this.credentials,
    required this.avatarInitials,
    required this.nextCheckInDate,
    required this.latestFeedback,
  });

  static const defaultCoach = CoachProfile(
    name: 'Sarah Jenkins, CSCS',
    credentials: 'Certified Strength Coach & Sports Nutritionist (CISSN)',
    avatarInitials: 'SJ',
    nextCheckInDate: 'Sunday, 10:00 AM EST',
    latestFeedback:
        '“Incredible work keeping adherence above 85% this week. The showdown rebalance helped smooth out Friday\'s dinner without stalling fat loss. Let\'s dial in hydration before heavy squats tomorrow.”',
  );
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free Tier';
      case SubscriptionTier.proMonthly:
        return 'Pro (Monthly)';
      case SubscriptionTier.proAnnual:
        return 'Pro (Annual)';
      case SubscriptionTier.coachLoop:
        return 'Human-in-the-Loop Coach';
      case SubscriptionTier.b2bPartner:
        return 'Partner Access';
    }
  }

  String get shortBadge {
    switch (this) {
      case SubscriptionTier.free:
        return 'FREE';
      case SubscriptionTier.proMonthly:
        return 'PRO';
      case SubscriptionTier.proAnnual:
        return 'PRO ANNUAL';
      case SubscriptionTier.coachLoop:
        return 'COACH';
      case SubscriptionTier.b2bPartner:
        return 'PARTNER';
    }
  }

  String get priceDisplay {
    switch (this) {
      case SubscriptionTier.free:
        return '\$0';
      case SubscriptionTier.proMonthly:
        return '\$14.99/mo';
      case SubscriptionTier.proAnnual:
        return '\$79.99/year (\$6.67/mo)';
      case SubscriptionTier.coachLoop:
        return '\$49/mo';
      case SubscriptionTier.b2bPartner:
        return 'Covered by Partner';
    }
  }

  String get tagline {
    switch (this) {
      case SubscriptionTier.free:
        return 'The Avatar Experience (Acquisition Engine)';
      case SubscriptionTier.proMonthly:
        return 'Unlimited Logs, Wearables & Adaptive Blueprint';
      case SubscriptionTier.proAnnual:
        return 'Recommended • 33% 1-Yr Retention vs 17% Monthly';
      case SubscriptionTier.coachLoop:
        return 'Real Human Accountability + AI Automation';
      case SubscriptionTier.b2bPartner:
        return 'White-label Gym, Employer & GLP-1 Telehealth Layer';
    }
  }

  Color get color {
    switch (this) {
      case SubscriptionTier.free:
        return Colors.white70;
      case SubscriptionTier.proMonthly:
        return VibrantColors.neonCyan;
      case SubscriptionTier.proAnnual:
        return VibrantColors.neonLime;
      case SubscriptionTier.coachLoop:
        return VibrantColors.neonMagenta;
      case SubscriptionTier.b2bPartner:
        return VibrantColors.neonGold;
    }
  }

  bool get isProOrAbove => this != SubscriptionTier.free;

  bool get isCoachOrAbove =>
      this == SubscriptionTier.coachLoop || this == SubscriptionTier.b2bPartner;

  bool get hasUnlimitedLogging => isProOrAbove;

  bool get hasWearableSync => isProOrAbove;

  bool get hasAdaptivePlan => isProOrAbove;

  bool get hasLiveAvatarDrift => isProOrAbove;

  bool get hasCoachReview => isCoachOrAbove;

  int get dailyLogLimit => this == SubscriptionTier.free ? 3 : 999999;
}
