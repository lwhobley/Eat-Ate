import 'package:flutter/material.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import '../widgets/vibrant_led_components.dart';
import '../models/subscription_tier.dart';
import '../widgets/subscription_paywall_view.dart';

class RecoveryScreen extends StatefulWidget {
  final Store store;
  const RecoveryScreen({super.key, required this.store});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  double sleep = 7.5;
  double readiness = 75;
  String? status;

  @override
  void initState() {
    super.initState();
    sleep = widget.store.recovery.sleepHours;
    readiness = widget.store.recovery.readiness.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final r = widget.store.recovery;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            // Wearable Biometrics HUD
            VibrantLedCard(
              title: 'BIOMETRIC TELEMETRY HUD (${widget.store.recoverySource.toUpperCase()})',
              ledColor: VibrantColors.neonGold,
              accentColor: VibrantColors.neonGold,
              trailing: const LedPillBadge(
                label: 'ONLINE',
                color: VibrantColors.neonLime,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildBiometricStat('HRV', '${r.hrvMs.round()} ms', VibrantColors.neonCyan)),
                      Container(width: 1, height: 32, color: VibrantColors.border),
                      Expanded(child: _buildBiometricStat('RHR', '${r.restingHr} bpm', VibrantColors.neonMagenta)),
                      Container(width: 1, height: 32, color: VibrantColors.border),
                      Expanded(child: _buildBiometricStat('STEPS', '${r.steps}', VibrantColors.neonLime)),
                      Container(width: 1, height: 32, color: VibrantColors.border),
                      Expanded(child: _buildBiometricStat('BURN', '${r.activeKcal} kcal', VibrantColors.neonGold)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LedCyberButton(
                    onPressed: () async {
                      if (!widget.store.subscriptionTier.hasWearableSync) {
                        SubscriptionPaywallView.show(context, widget.store);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color(0xFF0F172A),
                            content: Text(
                              'Bi-directional wearable sync (Apple Health, Oura, Whoop) requires Pro.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                        return;
                      }
                      final msg = await widget.store.pullWearable();
                      setState(() {
                        status = msg;
                        sleep = widget.store.recovery.sleepHours;
                        readiness = widget.store.recovery.readiness.toDouble();
                      });
                    },
                    label: widget.store.subscriptionTier.hasWearableSync
                        ? 'Sync Wearables & Bio-Rings'
                        : 'Unlock Wearable Telemetry (Pro)',
                    subtitle: 'Apple Health • Oura Ring • Whoop • Health Connect',
                    icon: const Icon(Icons.sync),
                    gradientColors: const [VibrantColors.neonGold, Color(0xFFB45309)],
                    ledColor: VibrantColors.neonGold,
                    fullWidth: true,
                  ),
                  if (status != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: VibrantColors.border),
                      ),
                      child: Text(
                        status!,
                        style: const TextStyle(color: VibrantColors.neonLime, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Sleep & Readiness Adjustment
            VibrantLedCard(
              title: 'RECOVERY BATTERY & READINESS',
              ledColor: VibrantColors.neonCyan,
              accentColor: VibrantColors.neonCyan,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Sleep Battery',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: VibrantColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${sleep.toStringAsFixed(1)} hours',
                        style: const TextStyle(
                          color: VibrantColors.neonCyan,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: VibrantColors.neonCyan,
                      inactiveTrackColor: VibrantColors.border,
                      thumbColor: VibrantColors.neonLime,
                    ),
                    child: Slider(
                      value: sleep,
                      min: 3,
                      max: 10,
                      divisions: 14,
                      onChanged: (v) => setState(() => sleep = v),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'CNS Readiness',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: VibrantColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${readiness.round()} / 100',
                        style: const TextStyle(
                          color: VibrantColors.neonLime,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: VibrantColors.neonLime,
                      inactiveTrackColor: VibrantColors.border,
                      thumbColor: VibrantColors.neonCyan,
                    ),
                    child: Slider(
                      value: readiness,
                      min: 10,
                      max: 100,
                      divisions: 18,
                      onChanged: (v) => setState(() => readiness = v),
                    ),
                  ),
                  const SizedBox(height: 14),

                  LedCyberButton(
                    onPressed: () => widget.store.setRecovery(sleep, readiness.round()),
                    label: 'Save Telemetry & Recalculate Blueprint',
                    icon: const Icon(Icons.bolt),
                    gradientColors: const [VibrantColors.neonLime, VibrantColors.neonCyan],
                    ledColor: VibrantColors.neonLime,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Quick Simulation Presets
            VibrantLedCard(
              title: 'REAL-TIME SIMULATIONS',
              ledColor: VibrantColors.neonMagenta,
              accentColor: VibrantColors.neonMagenta,
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildQuickAction(
                    label: '⚡ All-Nighter (4.5h Sleep)',
                    color: VibrantColors.neonMagenta,
                    onTap: () => widget.store.setRecovery(4.5, 42),
                  ),
                  _buildQuickAction(
                    label: '🍕 Dirty Bulk Feast (+1200 kcal)',
                    color: VibrantColors.neonGold,
                    onTap: () => widget.store.addFood('Cheeseburger, large fries & shake'),
                  ),
                  _buildQuickAction(
                    label: '✨ Peak Zen Mode (8.5h Sleep)',
                    color: VibrantColors.neonLime,
                    onTap: () => widget.store.setRecovery(8.5, 92),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBiometricStat(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: VibrantColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
