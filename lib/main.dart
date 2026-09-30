import 'package:flutter/material.dart';
import 'services/store.dart';
import 'screens/plan_screen.dart';
import 'screens/log_screen.dart';
import 'screens/avatar_screen.dart';
import 'screens/recovery_screen.dart';
import 'theme/vibrant_theme.dart';
import 'widgets/motion_graphic_background.dart';
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
      title: 'Eat Or Ate • AI Health Operating System',
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
      extendBody: false,
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
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x080F172A),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    'assets/images/fist_bump_badge.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.fitness_center_rounded,
                      color: VibrantColors.neonLime,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Eat & Ate',
                    style: TextStyle(
                      color: VibrantColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Fitness & Nutrition',
                    style: TextStyle(
                      color: VibrantColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),

          // Actions: Subscription Pill, Persona & Reel Buttons
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
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
                        color: badgeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: badgeColor.withValues(alpha: 0.3),
                          width: 1.0,
                        ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill_rounded,
                        size: 15,
                        color: VibrantColors.neonLime,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Reel',
                        style: TextStyle(
                          color: VibrantColors.neonLime,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
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