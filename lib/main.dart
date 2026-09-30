import 'package:flutter/material.dart';
import 'services/store.dart';
import 'screens/plan_screen.dart';
import 'screens/log_screen.dart';
import 'screens/avatar_screen.dart';
import 'screens/recovery_screen.dart';
import 'theme/vibrant_theme.dart';
import 'widgets/motion_graphic_background.dart';
import 'widgets/vibrant_led_components.dart';
import 'widgets/floating_neon_dock.dart';
import 'widgets/cinematic_transformation_reel.dart';
import 'widgets/ai_persona_selector.dart';
import 'models/subscription_tier.dart';
import 'widgets/subscription_paywall_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const geminiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  const terraKey = String.fromEnvironment('TERRA_API_KEY', defaultValue: '');
  const relayUrl = String.fromEnvironment('RELAY_URL', defaultValue: '');
  final store = Store(
    geminiKey: geminiKey.isEmpty ? null : geminiKey,
    terraKey: terraKey.isEmpty ? null : terraKey,
    terraRelayUrl: relayUrl.isEmpty ? null : relayUrl,
  );
  runApp(EatAteApp(
    store: store,
    geminiKey: geminiKey.isEmpty ? null : geminiKey,
    terraKey: terraKey.isEmpty ? null : terraKey,
  ));
}

class EatAteApp extends StatefulWidget {
  final Store store;
  final String? geminiKey;
  final String? terraKey;
  final bool initialShowReel;

  const EatAteApp({
    super.key,
    required this.store,
    this.geminiKey,
    this.terraKey,
    this.initialShowReel = true,
  });

  @override
  State<EatAteApp> createState() => _EatAteAppState();
}

class _EatAteAppState extends State<EatAteApp> {
  int _tabIndex = 0;
  late bool _showTransformationReel;

  @override
  void initState() {
    super.initState();
    _showTransformationReel = widget.initialShowReel;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eat & Ate • Vibrant Fitness',
      debugShowCheckedModeBanner: false,
      theme: VibrantTheme.darkTheme,
      home: _showTransformationReel
          ? CinematicTransformationReel(
              onDismiss: () => setState(() => _showTransformationReel = false),
            )
          : _buildMainShell(context),
    );
  }

  Widget _buildMainShell(BuildContext context) {
    final screens = [
      PlanScreen(store: widget.store),
      LogScreen(store: widget.store),
      AvatarScreen(
        store: widget.store,
        onOpenReel: () => setState(() => _showTransformationReel = true),
      ),
      RecoveryScreen(store: widget.store),
    ];

    return Scaffold(
      extendBody: true,
      body: MotionGraphicBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildVibrantAppBar(),
              Expanded(
                child: screens[_tabIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingNeonDock(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
      ),
    );
  }

  Widget _buildVibrantAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Kinetic LED Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: VibrantColors.neonLime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VibrantColors.neonLime.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: VibrantColors.neonLime.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  color: VibrantColors.neonLime,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EAT & ATE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(color: VibrantColors.neonLime, blurRadius: 12),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const LedStatusDiode(
                        color: VibrantColors.neonCyan,
                        size: 5,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.geminiKey == null ? 'MOCK AI ENGINE' : 'GEMINI ACTIVE',
                        style: const TextStyle(
                          color: VibrantColors.neonCyan,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Actions: Subscription Pill, Persona & Reel Buttons
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
              AnimatedBuilder(
                animation: widget.store,
                builder: (context, _) {
                  final tier = widget.store.subscriptionTier;
                  final badgeText = tier == SubscriptionTier.b2bPartner
                      ? 'PRO'
                      : tier.shortBadge;
                  final badgeColor = tier == SubscriptionTier.b2bPartner
                      ? VibrantColors.neonCyan
                      : tier.color;

                  return GestureDetector(
                    onTap: () => SubscriptionPaywallView.show(
                        context, widget.store),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tier.isProOrAbove
                                ? Icons.verified
                                : Icons.bolt_outlined,
                            size: 13,
                            color: badgeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              AnimatedBuilder(
                animation: widget.store,
                builder: (context, _) =>
                    AiPersonaSelector(store: widget.store, compact: true),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _showTransformationReel = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF0F172A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: VibrantColors.neonLime.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: VibrantColors.neonLime.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        size: 14,
                        color: VibrantColors.neonLime,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'GLOW-UP',
                        style: TextStyle(
                          color: VibrantColors.neonLime,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }
}