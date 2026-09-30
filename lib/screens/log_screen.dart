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
  final int initialMode; // 0: Quick Log, 1: Meal vs Target

  const LogScreen({
    super.key,
    required this.store,
    this.initialMode = 0,
  });

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  late int _mode; // 0: Quick Log, 1: Meal vs Target
  final foodCtrl = TextEditingController(text: 'Burrito bowl');
  final workoutCtrl =
      TextEditingController(text: '5x5 squats at 225 lbs, then 20 min cycling');
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
          backgroundColor: Color(0xFF0F172A),
          content: Text(
            'Free daily limit reached (3 logs). Upgrade to Pro for unlimited logging.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                ? 'Photo parsed with Gemini AI Vision'
                : 'Photo logged (Estimate — tap item to edit)',
            style: const TextStyle(color: Colors.white),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: VibrantColors.border),
        ),
        title: Text(item.name, style: const TextStyle(color: VibrantColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: kcalCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: VibrantColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Calories (kcal)',
              labelStyle: TextStyle(color: VibrantColors.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: pCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: VibrantColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Protein (g)',
              labelStyle: TextStyle(color: VibrantColors.textSecondary),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: VibrantColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Mode Selector Toggle
            _buildModeSelector(),
            const SizedBox(height: 10),

            // Tier Limits Banner
            _buildLoggingTierBanner(s),
            const SizedBox(height: 6),

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
                title: 'Today\'s Intake & Training',
                ledColor: VibrantColors.neonCyan,
                accentColor: VibrantColors.neonCyan,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDailyStat('${s.eatenKcal.round()}', 'Calories', VibrantColors.neonCyan),
                    Container(width: 1, height: 34, color: VibrantColors.border),
                    _buildDailyStat('${s.eatenProtein.round()}g', 'Protein', VibrantColors.neonMagenta),
                    Container(width: 1, height: 34, color: VibrantColors.border),
                    _buildDailyStat('${s.workouts.length}', 'Workouts', VibrantColors.neonLime),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: VibrantColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x060F172A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.compare_arrows_rounded, color: Color(0xFF0284C7), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Compare Meal vs Target',
                              style: TextStyle(
                                color: VibrantColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Analyze nutrient impact and schedule adjustments',
                              style: TextStyle(color: VibrantColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Food Logging Section
              VibrantLedCard(
                title: 'Log Food',
                ledColor: VibrantColors.neonLime,
                accentColor: VibrantColors.neonLime,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VibrantColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: foodCtrl,
                              style: const TextStyle(color: VibrantColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'What did you eat?',
                                hintStyle: TextStyle(color: VibrantColors.textMuted),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0284C7)),
                            onPressed: _pickPhoto,
                          ),
                          IconButton(
                            icon: Icon(
                              _listeningFood ? Icons.mic_off_rounded : Icons.mic_rounded,
                              color: _listeningFood ? VibrantColors.neonMagenta : VibrantColors.neonLime,
                            ),
                            onPressed: () => _listeningFood
                                ? _stopListen(true)
                                : _listen(foodCtrl, true),
                          ),
                          LedCyberButton(
                            onPressed: _handleLogFood,
                            label: 'Log',
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gradientColors: const [Color(0xFF059669), Color(0xFF047857)],
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
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: VibrantColors.border),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: const Icon(Icons.restaurant_rounded, color: VibrantColors.neonLime, size: 20),
                              title: Text(i.name, style: const TextStyle(color: VibrantColors.textPrimary, fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '${i.kcal.round()} kcal • ${i.proteinG.round()}g protein${i.grams > 0 ? " • ${i.grams.round()}g" : ""}',
                                style: const TextStyle(color: VibrantColors.textSecondary, fontSize: 11),
                              ),
                              trailing: const Icon(Icons.edit_outlined, color: VibrantColors.textMuted, size: 18),
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
                title: 'Log Workout',
                ledColor: VibrantColors.neonMagenta,
                accentColor: VibrantColors.neonMagenta,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VibrantColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: workoutCtrl,
                              style: const TextStyle(color: VibrantColors.textPrimary, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: 'What did you train?',
                                hintStyle: TextStyle(color: VibrantColors.textMuted),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _listeningWorkout ? Icons.mic_off_rounded : Icons.mic_rounded,
                              color: _listeningWorkout ? VibrantColors.neonLime : VibrantColors.neonMagenta,
                            ),
                            onPressed: () => _listeningWorkout
                                ? _stopListen(false)
                                : _listen(workoutCtrl, false),
                          ),
                          LedCyberButton(
                            onPressed: () => s.addWorkout(workoutCtrl.text),
                            label: 'Log',
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            gradientColors: const [Color(0xFFE11D48), Color(0xFFBE123C)],
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
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: VibrantColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fitness_center_rounded, color: VibrantColors.neonMagenta, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    w.summary,
                                    style: const TextStyle(color: VibrantColors.textPrimary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                LedPillBadge(
                                  label: 'Intensity ${w.strain.toStringAsFixed(0)}/10',
                                  color: VibrantColors.neonMagenta,
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: VibrantColors.neonMagenta,
                                inactiveTrackColor: VibrantColors.border,
                                thumbColor: VibrantColors.neonMagenta,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VibrantColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              title: 'Quick Log',
              icon: Icons.edit_note_rounded,
              index: 0,
              activeColor: VibrantColors.neonLime,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildModeTab(
              title: 'Compare vs Target',
              icon: Icons.compare_arrows_rounded,
              index: 1,
              activeColor: const Color(0xFF0284C7),
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
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : VibrantColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? activeColor : VibrantColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: VibrantColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isFree
            ? Colors.white
            : tier.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFree
              ? (count >= limit
                  ? VibrantColors.neonAmber
                  : VibrantColors.border)
              : tier.color.withValues(alpha: 0.3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x040F172A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  isFree
                      ? (count >= limit ? Icons.warning_amber_rounded : Icons.info_outline_rounded)
                      : Icons.all_inclusive_rounded,
                  size: 15,
                  color: isFree
                      ? (count >= limit ? VibrantColors.neonAmber : VibrantColors.textSecondary)
                      : tier.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isFree
                        ? 'Daily Logs: $count of $limit used today'
                        : 'Unlimited Logging Active (${tier.displayName})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isFree
                          ? (count >= limit ? VibrantColors.neonAmber : VibrantColors.textPrimary)
                          : tier.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: VibrantColors.neonLime,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Upgrade',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
