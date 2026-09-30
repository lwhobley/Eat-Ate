import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/meal_impact.dart';
import '../services/store.dart';
import '../theme/vibrant_theme.dart';
import 'vibrant_led_components.dart';
import 'ai_persona_selector.dart';

class MealDecisionImpactView extends StatefulWidget {
  final Store store;
  final VoidCallback? onMealLogged;

  const MealDecisionImpactView({
    super.key,
    required this.store,
    this.onMealLogged,
  });

  @override
  State<MealDecisionImpactView> createState() => _MealDecisionImpactViewState();
}

class _MealDecisionImpactViewState extends State<MealDecisionImpactView> {
  final _plannedCtrl =
      TextEditingController(text: 'Grilled Chicken Breast, Quinoa & Steamed Broccoli');
  final _actualCtrl =
      TextEditingController(text: 'Pepperoni Pizza (3 slices) & Craft Beer');
  final _stt = SpeechToText();
  bool _isListening = false;
  Uint8List? _actualPhotoBytes;
  bool _isAnalyzing = false;
  MealComparisonImpact? _impact;

  @override
  void initState() {
    super.initState();
    _impact = widget.store.lastMealImpact;
  }

  Future<void> _pickPhoto() async {
    final pic = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pic == null || !mounted) return;
    final bytes = await pic.readAsBytes();
    setState(() {
      _actualPhotoBytes = bytes;
      if (_actualCtrl.text.isEmpty) {
        _actualCtrl.text = 'Photo Meal (Captured from Camera)';
      }
    });
  }

  Future<void> _toggleListen() async {
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }
    final avail = await _stt.initialize();
    if (!avail || !mounted) return;
    setState(() => _isListening = true);
    await _stt.listen(onResult: (r) {
      setState(() => _actualCtrl.text = r.recognizedWords);
    });
  }

  Future<void> _analyzeImpact() async {
    if (_actualCtrl.text.trim().isEmpty) return;
    setState(() => _isAnalyzing = true);
    try {
      final res = await widget.store.analyzePlannedVsActualMeal(
        planned: _plannedCtrl.text.trim(),
        actual: _actualCtrl.text.trim(),
        imageBytes: _actualPhotoBytes,
      );
      if (mounted) {
        setState(() {
          _impact = res;
          _isAnalyzing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _applyAndLog() async {
    if (_impact == null) return;
    await widget.store.logComparedMeal(_impact!, imageBytes: _actualPhotoBytes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F172A),
          content: Text(
            'Meal saved. Daily targets and recommendations updated.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
      widget.onMealLogged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input Form Section
        VibrantLedCard(
          title: 'Meal Comparison • Target vs Actual',
          ledColor: VibrantColors.neonCyan,
          accentColor: VibrantColors.neonCyan,
          trailing: const LedPillBadge(
            label: 'Impact Analysis',
            color: VibrantColors.neonCyan,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Planned Meal Input
              const Text(
                '1. Planned Target Meal',
                style: TextStyle(
                  color: VibrantColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VibrantColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: TextField(
                  controller: _plannedCtrl,
                  style: const TextStyle(color: VibrantColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Grilled chicken breast, quinoa & steamed broccoli',
                    hintStyle: TextStyle(color: VibrantColors.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Actual Ingested Meal Input
              const Text(
                '2. Actual Meal Eaten',
                style: TextStyle(
                  color: VibrantColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: VibrantColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _actualCtrl,
                        style: const TextStyle(color: VibrantColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'e.g. 3 slices of pepperoni pizza, or burger and fries',
                          hintStyle: TextStyle(color: VibrantColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0284C7), size: 20),
                      onPressed: _pickPhoto,
                    ),
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isListening ? VibrantColors.neonMagenta : VibrantColors.neonLime,
                        size: 20,
                      ),
                      onPressed: _toggleListen,
                    ),
                  ],
                ),
              ),
              if (_actualPhotoBytes != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _actualPhotoBytes!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Photo attached for analysis',
                      style: TextStyle(color: Color(0xFF0284C7), fontSize: 11),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // AI Response Persona Level Config
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Coaching Style:',
                    style: TextStyle(
                      color: VibrantColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AnimatedBuilder(
                    animation: widget.store,
                    builder: (context, _) =>
                        AiPersonaSelector(store: widget.store, compact: true),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Analyze Button
              LedCyberButton(
                onPressed: _isAnalyzing ? null : _analyzeImpact,
                label: _isAnalyzing
                    ? 'Analyzing Nutrition Impact…'
                    : 'Compare Nutrition Impact',
                subtitle: 'Evaluates calorie difference and suggests plan adjustments',
                icon: const Icon(Icons.analytics_rounded),
                gradientColors: const [
                  Color(0xFF0284C7),
                  Color(0xFF0369A1),
                ],
                fullWidth: true,
              ),
            ],
          ),
        ),

        // Display Consequences, Rewards & Impact if available
        if (_impact != null) ...[
          const SizedBox(height: 16),
          _buildImpactBreakdown(_impact!),
        ],
      ],
    );
  }

  Widget _buildImpactBreakdown(MealComparisonImpact impact) {
    final isSurplus = impact.calorieDelta > 0;
    final isProtPositive = impact.proteinDelta >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Head-to-Head Nutritional Comparison Card
        VibrantLedCard(
          title: 'Nutritional Comparison',
          ledColor: isSurplus ? VibrantColors.neonMagenta : VibrantColors.neonLime,
          accentColor: VibrantColors.neonCyan,
          child: Column(
            children: [
              Row(
                children: [
                  // Planned Column
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: VibrantColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Meal',
                            style: TextStyle(
                              color: Color(0xFF0284C7),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            impact.plannedMealName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VibrantColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${impact.plannedNutrients.kcal.round()} kcal',
                            style: const TextStyle(
                              color: VibrantColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${impact.plannedNutrients.proteinG.round()}g Prot • ${impact.plannedNutrients.carbsG.round()}g Carb',
                            style: const TextStyle(color: VibrantColors.textSecondary, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Ingested Actual Column
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isSurplus ? VibrantColors.neonMagenta : VibrantColors.neonLime)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Actual Meal',
                            style: TextStyle(
                              color: isSurplus ? VibrantColors.neonMagenta : VibrantColors.neonLime,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            impact.actualMealName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: VibrantColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${impact.actualNutrients.kcal.round()} kcal',
                            style: TextStyle(
                              color: isSurplus ? VibrantColors.neonMagenta : VibrantColors.neonLime,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${impact.actualNutrients.proteinG.round()}g Prot • ${impact.actualNutrients.carbsG.round()}g Carb',
                            style: const TextStyle(color: VibrantColors.textSecondary, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Delta Badges Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDeltaBadge(
                    label: 'Calorie Delta',
                    value: '${impact.calorieDelta > 0 ? "+" : ""}${impact.calorieDelta} kcal',
                    color: isSurplus ? VibrantColors.neonMagenta : VibrantColors.neonLime,
                  ),
                  _buildDeltaBadge(
                    label: 'Protein Delta',
                    value: '${impact.proteinDelta > 0 ? "+" : ""}${impact.proteinDelta.round()}g',
                    color: isProtPositive ? VibrantColors.neonLime : VibrantColors.neonGold,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. AI Nutritional Background Intelligence Card
        VibrantLedCard(
          title: 'Nutritional Summary & Coaching',
          ledColor: VibrantColors.neonCyan,
          accentColor: VibrantColors.neonCyan,
          child: Text(
            impact.nutritionalBackground,
            style: const TextStyle(
              color: VibrantColors.textPrimary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // 3. Rewards & Gains
        VibrantLedCard(
          title: 'Nutritional Upsides & Benefits',
          ledColor: VibrantColors.neonLime,
          accentColor: VibrantColors.neonLime,
          child: Column(
            children: impact.rewards
                .map(
                  (reward) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: VibrantColors.neonLime,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            reward,
                            style: const TextStyle(
                              color: VibrantColors.textPrimary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),

        // 4. Consequences & Costs
        VibrantLedCard(
          title: 'Trade-offs & Nutritional Deficits',
          ledColor: VibrantColors.neonMagenta,
          accentColor: VibrantColors.neonMagenta,
          child: Column(
            children: impact.consequences
                .map(
                  (consequence) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: VibrantColors.neonMagenta,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            consequence,
                            style: const TextStyle(
                              color: VibrantColors.textPrimary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 14),

        // 5. Plan Adaptation & Recommendations
        VibrantLedCard(
          title: 'Adaptive Recommendations',
          ledColor: VibrantColors.neonGold,
          accentColor: VibrantColors.neonGold,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImpactRow(
                icon: Icons.calendar_today_rounded,
                title: 'Tomorrow\'s Plan Adjustment',
                body: impact.planAdaptation,
                color: VibrantColors.neonGold,
              ),
              const SizedBox(height: 10),
              _buildImpactRow(
                icon: Icons.person_rounded,
                title: 'Body Composition Impact',
                body: impact.avatarProjectionImpact,
                color: VibrantColors.neonMagenta,
              ),
              const SizedBox(height: 10),
              _buildImpactRow(
                icon: Icons.directions_run_rounded,
                title: 'Activity & Calorie Offset',
                body: impact.exerciseOffset,
                color: const Color(0xFF0284C7),
              ),
              const SizedBox(height: 16),

              // Button to commit this meal and apply rebalance
              LedCyberButton(
                onPressed: _applyAndLog,
                label: 'Save Meal & Apply Adjustments',
                subtitle: 'Updates daily targets and weekly progression',
                icon: const Icon(Icons.check_rounded),
                gradientColors: const [
                  VibrantColors.neonLime,
                  Color(0xFF047857),
                ],
                fullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeltaBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: VibrantColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow({
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  color: VibrantColors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
