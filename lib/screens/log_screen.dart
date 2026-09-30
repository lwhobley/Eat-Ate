import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/health_data.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import '../widgets/vibrant_led_components.dart';
import '../widgets/meal_decision_impact_view.dart';
import '../models/subscription_tier.dart';
import '../widgets/subscription_paywall_view.dart';

class LogScreen extends StatefulWidget {
  final Store store;
  final int initialMode; // 0: Quick Log, 1: Planned vs Actual Showdown

  const LogScreen({
    super.key,
    required this.store,
    this.initialMode = 0,
  });

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  late int _mode; // 0: Quick Log, 1: Planned vs Actual
  final foodCtrl = TextEditingController(text: 'Burrito bowl');
  final workoutCtrl =
      TextEditingController(text: '5x5 squats at 225 lbs, then 20 min Peloton');
  final _stt = SpeechToText();
  bool _listeningFood = false;
  bool _listeningWorkout = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  Future<void> _listen(TextEditingController ctrl, bool isFood) async {
    final avail = await _stt.initialize();
    if (!avail || !mounted) return;
    setState(() {
      if (isFood) {
        _listeningFood = true;
      } else {
        _listeningWorkout = true;
      }
    });
    await _stt.listen(onResult: (r) => ctrl.text = r.recognizedWords);
  }

  Future<void> _handleLogFood([Uint8List? imageBytes]) async {
    if (!widget.store.canLogMore) {
      SubscriptionPaywallView.show(context, widget.store);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1E1B4B),
          content: Text(
            'Free tier daily limit reached (3 logs). Upgrade to Pro for unlimited logging!',
            style: TextStyle(color: VibrantColors.neonLime, fontWeight: FontWeight.w700),
          ),
        ),
      );
      return;
    }
    if (foodCtrl.text.trim().isNotEmpty || imageBytes != null) {
      await widget.store.addFood(foodCtrl.text, imageBytes: imageBytes);
    }
  }

  Future<void> _stopListen(bool isFood, {bool autoLog = true}) async {
    await _stt.stop();
    setState(() {
      if (isFood) {
        _listeningFood = false;
      } else {
        _listeningWorkout = false;
      }
    });
    if (autoLog && mounted) {
      if (isFood && foodCtrl.text.trim().isNotEmpty) {
        await _handleLogFood();
      } else if (!isFood && workoutCtrl.text.trim().isNotEmpty) {
        await widget.store.addWorkout(workoutCtrl.text);
      }
    }
  }

  Future<void> _pickPhoto() async {
    final pic = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pic == null || !mounted) return;
    final bytes = await pic.readAsBytes();
    await _handleLogFood(bytes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0F172A),
          content: Text(
            widget.store.gemini.hasKey
                ? '⚡ Photo parsed with Gemini AI Vision'
                : 'Photo logged (Mock estimate — tap item to edit)',
            style: const TextStyle(color: VibrantColors.neonLime),
          ),
        ),
      );
    }
  }

  Future<void> _editFood(int logIdx, int itemIdx, FoodItem item) async {
    final kcalCtrl = TextEditingController(text: item.kcal.round().toString());
    final pCtrl = TextEditingController(text: item.proteinG.round().toString());
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: VibrantColors.neonCyan),
        ),
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: kcalCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Calories (kcal)',
              labelStyle: TextStyle(color: VibrantColors.neonCyan),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: pCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Protein (g)',
              labelStyle: TextStyle(color: VibrantColors.neonMagenta),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VibrantColors.neonCyan,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok == true) {
      widget.store.updateFoodItem(
        logIdx,
        itemIdx,
        item.copyWith(
          kcal: double.tryParse(kcalCtrl.text) ?? item.kcal,
          proteinG: double.tryParse(pCtrl.text) ?? item.proteinG,
          confidence: 1.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final s = widget.store;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            // Mode Selector Toggle (Quick Log vs Planned vs Actual Showdown)
            _buildModeSelector(),
            const SizedBox(height: 10),

            // Tier Limits HUD Banner
            _buildLoggingTierBanner(s),
            const SizedBox(height: 4),

            if (_mode == 1) ...[
              // PLANNED VS ACTUAL SHOWDOWN VIEW
              MealDecisionImpactView(
                store: widget.store,
                onMealLogged: () => setState(() => _mode = 0),
              ),
            ] else ...[
              // STANDARD QUICK LOG VIEW
              // Daily Macro Progress Bar Card
              VibrantLedCard(
                title: 'TODAY\'S INTAKE & TRAINING METRICS',
                ledColor: VibrantColors.neonCyan,
                accentColor: VibrantColors.neonCyan,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDailyStat('${s.eatenKcal.round()}', 'KCAL FUELED', VibrantColors.neonCyan),
                    Container(width: 1, height: 34, color: Colors.white12),
                    _buildDailyStat('${s.eatenProtein.round()}g', 'PROTEIN GAINS', VibrantColors.neonMagenta),
                    Container(width: 1, height: 34, color: Colors.white12),
                    _buildDailyStat('${s.workouts.length}', 'SESSIONS CRUSHED', VibrantColors.neonLime),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Banner shortcut to Planned vs Actual
              GestureDetector(
                onTap: () => setState(() => _mode = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VibrantColors.neonMagenta.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: VibrantColors.neonMagenta.withValues(alpha: 0.18),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: VibrantColors.neonMagenta.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology, color: VibrantColors.neonMagenta, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ate off-plan? Run the Showdown',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'AI breaks down consequences, rewards & auto-rebalance',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: VibrantColors.neonMagenta, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Food Logging Section
              VibrantLedCard(
                title: 'LOG FUEL • SNAP, SPEAK OR TYPE',
                ledColor: VibrantColors.neonLime,
                accentColor: VibrantColors.neonLime,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VibrantColors.neonLime.withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: foodCtrl,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'What did you fuel with?',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt, color: VibrantColors.neonCyan),
                            onPressed: _pickPhoto,
                          ),
                          IconButton(
                            icon: Icon(
                              _listeningFood ? Icons.mic_off : Icons.mic,
                              color: _listeningFood ? VibrantColors.neonMagenta : VibrantColors.neonLime,
                            ),
                            onPressed: () => _listeningFood
                                ? _stopListen(true)
                                : _listen(foodCtrl, true),
                          ),
                          LedCyberButton(
                            onPressed: _handleLogFood,
                            label: 'LOG',
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            chamfer: 8,
                            gradientColors: const [VibrantColors.neonLime, VibrantColors.neonCyan],
                            ledColor: VibrantColors.neonLime,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Logged Food Items
                    ...s.foods.asMap().entries.map((logEntry) {
                      final li = logEntry.key;
                      final f = logEntry.value;
                      return Column(
                        children: f.items.asMap().entries.map((itemEntry) {
                          final ii = itemEntry.key;
                          final i = itemEntry.value;
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.restaurant, color: VibrantColors.neonLime, size: 20),
                              title: Text(i.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${i.kcal.round()} kcal • ${i.proteinG.round()}g protein${i.grams > 0 ? " • ${i.grams.round()}g" : ""} • ${(i.confidence * 100).round()}% AI confidence',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                              trailing: const Icon(Icons.edit, color: VibrantColors.neonCyan, size: 18),
                              onTap: () => _editFood(li, ii, i),
                            ),
                          );
                        }).toList(),
                      );
                    }).take(5),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Workout Logging Section
              VibrantLedCard(
                title: 'LOG TRAINING & STRAIN',
                ledColor: VibrantColors.neonMagenta,
                accentColor: VibrantColors.neonMagenta,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: VibrantColors.neonMagenta.withValues(alpha: 0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: workoutCtrl,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'What did you train?',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _listeningWorkout ? Icons.mic_off : Icons.mic,
                              color: _listeningWorkout ? VibrantColors.neonLime : VibrantColors.neonMagenta,
                            ),
                            onPressed: () => _listeningWorkout
                                ? _stopListen(false)
                                : _listen(workoutCtrl, false),
                          ),
                          LedCyberButton(
                            onPressed: () => s.addWorkout(workoutCtrl.text),
                            label: 'LOG',
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            chamfer: 8,
                            gradientColors: const [VibrantColors.neonMagenta, VibrantColors.neonPurple],
                            ledColor: VibrantColors.neonMagenta,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...s.workouts.asMap().entries.map((e) {
                      final wi = e.key;
                      final w = e.value;
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fitness_center, color: VibrantColors.neonMagenta, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    w.summary,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                LedPillBadge(
                                  label: 'STRAIN ${w.strain.toStringAsFixed(0)}/10',
                                  color: VibrantColors.neonMagenta,
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: VibrantColors.neonMagenta,
                                inactiveTrackColor: Colors.white12,
                                thumbColor: VibrantColors.neonCyan,
                              ),
                              child: Slider(
                                value: w.strain.clamp(0, 10),
                                min: 0,
                                max: 10,
                                divisions: 10,
                                label: w.strain.toStringAsFixed(0),
                                onChanged: (v) => s.updateStrain(wi, v),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).take(5),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              title: 'QUICK LOG',
              icon: Icons.edit_note_rounded,
              index: 0,
              activeColor: VibrantColors.neonLime,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildModeTab(
              title: 'SHOWDOWN (VS PLAN)',
              icon: Icons.compare_arrows_rounded,
              index: 1,
              activeColor: VibrantColors.neonMagenta,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String title,
    required IconData icon,
    required int index,
    required Color activeColor,
  }) {
    final isSelected = _mode == index;
    return GestureDetector(
      onTap: () => setState(() => _mode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : Colors.white60,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildLoggingTierBanner(Store s) {
    final tier = s.subscriptionTier;
    final isFree = tier == SubscriptionTier.free;
    final count = s.todayLogsCount;
    final limit = tier.dailyLogLimit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isFree
            ? VibrantColors.deepSpace
            : tier.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFree
              ? (count >= limit
                  ? VibrantColors.neonAmber
                  : Colors.white.withValues(alpha: 0.15))
              : tier.color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  isFree
                      ? (count >= limit ? Icons.warning_amber_rounded : Icons.lock_clock)
                      : Icons.all_inclusive,
                  size: 15,
                  color: isFree
                      ? (count >= limit ? VibrantColors.neonAmber : Colors.white70)
                      : tier.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isFree
                        ? 'DAILY LOGGING: $count / $limit USED TODAY'
                        : 'UNLIMITED LOGGING ACTIVE (${tier.displayName.toUpperCase()})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isFree
                          ? (count >= limit ? VibrantColors.neonAmber : Colors.white)
                          : tier.color,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isFree) const SizedBox(width: 8),
          if (isFree)
            GestureDetector(
              onTap: () => SubscriptionPaywallView.show(context, widget.store),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: VibrantColors.neonLime,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'UPGRADE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
