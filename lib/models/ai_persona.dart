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
        return 'Hype Bestie • Zero Guilt';
      case AiPersona.matterOfFact:
        return 'Pure Math • High Signal';
      case AiPersona.careful:
        return 'Longevity Guard • Anti-Burnout';
      case AiPersona.explicitlyHonest:
        return 'Savage Reality Check • No Cap';
    }
  }

  String get description {
    switch (this) {
      case AiPersona.kind:
        return 'Empathetic hype bestie. Zero guilt, validates cravings, and reminds you that we move regardless. "You got this, let\'s keep cooking."';
      case AiPersona.matterOfFact:
        return 'Straight science, pure numbers, zero fluff. Gives you the raw caloric math and metabolic reality without the drama.';
      case AiPersona.careful:
        return 'Protects your nervous system and longevity. Paces the grind so you don\'t crash out or wreck your joints.';
      case AiPersona.explicitlyHonest:
        return 'Unfiltered tough love. Calls out excuses, delulu choices, and diet slip-ups with razor-sharp bluntness. "Be so for real right now."';
    }
  }

  Color get color {
    switch (this) {
      case AiPersona.kind:
        return const Color(0xFFFF69B4); // Warm Neon Pink
      case AiPersona.matterOfFact:
        return VibrantColors.neonCyan;
      case AiPersona.careful:
        return VibrantColors.neonLime;
      case AiPersona.explicitlyHonest:
        return const Color(0xFFFF3344); // Hyper Red / Flame
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
        return 'TONE: Kind, supportive, and encouraging like a warm gym bestie. Use modern positive vernacular (e.g., "we move", "protect your peace", "you are doing great", "pure W"). Focus on positive momentum, eliminate all guilt or shame, and frame adjustments as gentle self-care steps.';
      case AiPersona.matterOfFact:
        return 'TONE: Strictly matter-of-fact, objective, and clinical. Present numbers, metabolic pathways, and caloric realities with zero fluff, emotion, or drama. High signal, pure data.';
      case AiPersona.careful:
        return 'TONE: Careful, prudent, and longevity-focused. Prioritize central nervous system (CNS) recovery, injury prevention, gradual progress, and avoiding burnout or crashing out ("pace the grind", "sustainable gains").';
      case AiPersona.explicitlyHonest:
        return 'TONE: Explicitly honest, brutally direct, and totally unfiltered. Allow for abrasive, unapologetic bluntness and tough love. Call out excuses, delulu reasoning, and nutritional slip-ups directly like a savage drill sergeant or brutally honest gym bro who refuses to let you lie to yourself. Use sharp current vernacular where fitting ("be so for real right now", "delulu", "down bad", "you\'re cooked if you keep this up", "no cap", "lock in").';
    }
  }
}
