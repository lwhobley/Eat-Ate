import 'package:flutter/material.dart';
import '../theme/vibrant_theme.dart';

enum AiPersona {
  kind,
  matterOfFact,
  careful,
  explicitlyHonest,
}

extension AiPersonaExtension on AiPersona {
  String get displayName {
    switch (this) {
      case AiPersona.kind:
        return 'Kind';
      case AiPersona.matterOfFact:
        return 'Matter-of-Fact';
      case AiPersona.careful:
        return 'Careful';
      case AiPersona.explicitlyHonest:
        return 'Explicitly Honest';
    }
  }

  String get tagline {
    switch (this) {
      case AiPersona.kind:
        return 'Supportive & Encouraging • Positive Momentum';
      case AiPersona.matterOfFact:
        return 'Data-Driven & Objective • High Signal';
      case AiPersona.careful:
        return 'Longevity & Recovery • Injury Prevention';
      case AiPersona.explicitlyHonest:
        return 'Direct & Unfiltered • High Accountability';
    }
  }

  String get description {
    switch (this) {
      case AiPersona.kind:
        return 'Empathetic and supportive coaching. Validates cravings, eliminates guilt, and frames adjustments as sustainable self-care steps.';
      case AiPersona.matterOfFact:
        return 'Objective, numbers-first coaching. Delivers clear caloric math, metabolic pacing, and straightforward facts.';
      case AiPersona.careful:
        return 'Protects your recovery, central nervous system, and joint health. Emphasizes sustainable progression to prevent burnout.';
      case AiPersona.explicitlyHonest:
        return 'Unfiltered, direct accountability. Cuts through rationalizations and excuses with candid, constructive feedback.';
    }
  }

  Color get color {
    switch (this) {
      case AiPersona.kind:
        return const Color(0xFFE11D48); // Rose 600
      case AiPersona.matterOfFact:
        return VibrantColors.neonCyan;   // Ocean blue 600
      case AiPersona.careful:
        return VibrantColors.neonLime;   // Emerald 600
      case AiPersona.explicitlyHonest:
        return const Color(0xFFDC2626); // Crimson 600
    }
  }

  IconData get icon {
    switch (this) {
      case AiPersona.kind:
        return Icons.favorite_rounded;
      case AiPersona.matterOfFact:
        return Icons.analytics_rounded;
      case AiPersona.careful:
        return Icons.shield_rounded;
      case AiPersona.explicitlyHonest:
        return Icons.local_fire_department_rounded;
    }
  }

  String get promptGuidance {
    switch (this) {
      case AiPersona.kind:
        return 'TONE: Kind, supportive, and encouraging. Focus on positive momentum, eliminate guilt or shame, and frame adjustments as gentle self-care steps.';
      case AiPersona.matterOfFact:
        return 'TONE: Strictly matter-of-fact, objective, and clinical. Present numbers, metabolic pathways, and caloric realities with clarity, high signal, and pure data.';
      case AiPersona.careful:
        return 'TONE: Careful, prudent, and longevity-focused. Prioritize central nervous system (CNS) recovery, injury prevention, gradual progress, and avoiding burnout.';
      case AiPersona.explicitlyHonest:
        return 'TONE: Explicitly honest, direct, and candid. Call out excuses, dietary drift, and rationalizations with sharp, constructive clarity and high accountability.';
    }
  }
}
