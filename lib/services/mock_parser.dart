import '../models/ai_persona.dart';
import '../models/health_data.dart';
import '../models/meal_impact.dart';

// Day-1 mock parser. Swap with GeminiService when GEMINI_API_KEY is set.
class MockParser {
  static FoodLog parseFood(String text) {
    final t = text.toLowerCase();
    List<FoodItem> items;
    if (t.contains('burrito')) {
      items = const [
        FoodItem(name: 'Burrito bowl', kcal: 720, proteinG: 42, carbsG: 75, fatG: 28, grams: 450, confidence: 0.85)
      ];
    } else if (t.contains('thanksgiving') || t.contains('turkey')) {
      items = const [
        FoodItem(name: 'Thanksgiving plate', kcal: 1450, proteinG: 70, carbsG: 130, fatG: 60, grams: 700, confidence: 0.8),
        FoodItem(name: 'Pie slice', kcal: 420, proteinG: 5, carbsG: 60, fatG: 20, grams: 150, confidence: 0.9),
      ];
    } else if (t.contains('protein') || t.contains('shake')) {
      items = const [
        FoodItem(name: 'Protein shake', kcal: 180, proteinG: 30, carbsG: 12, fatG: 3, grams: 350, confidence: 0.95)
      ];
    } else if (t.contains('burger') || t.contains('pizza') || t.contains('fries') || t.contains('beer')) {
      items = [
        FoodItem(name: text.trim(), kcal: 980, proteinG: 32, carbsG: 110, fatG: 45, grams: 550, confidence: 0.85)
      ];
    } else if (t.contains('chicken') || t.contains('salmon') || t.contains('rice') || t.contains('quinoa') || t.contains('broccoli')) {
      items = [
        FoodItem(name: text.trim(), kcal: 540, proteinG: 46, carbsG: 48, fatG: 14, grams: 420, confidence: 0.9)
      ];
    } else if (t.isEmpty) {
      items = const [];
    } else {
      items = [
        FoodItem(name: text.trim(), kcal: 500, proteinG: 25, carbsG: 50, fatG: 18, grams: 300, confidence: 0.5)
      ];
    }
    return FoodLog(ts: DateTime.now(), rawText: text, items: items);
  }

  static WorkoutLog parseWorkout(String text) {
    final t = text.toLowerCase();
    double strain = 5;
    String summary = text.trim();
    List<WorkoutSet> sets = const [];
    double volume = 0;

    final setRep = RegExp(r'(\d+)\s*x\s*(\d+)');
    final weightRep = RegExp(r'(\d+(?:\.\d+)?)\s*(?:lb|lbs|kg)');
    final m = setRep.firstMatch(t);
    if (m != null) {
      final s = int.tryParse(m.group(1) ?? '') ?? 0;
      final r = int.tryParse(m.group(2) ?? '') ?? 0;
      final wm = weightRep.firstMatch(t);
      final w = wm != null ? double.tryParse(wm.group(1) ?? '') ?? 0.0 : 0.0;
      final name = t.contains('squat')
          ? 'Squat'
          : t.contains('bench')
              ? 'Bench'
              : t.contains('deadlift')
                  ? 'Deadlift'
                  : 'Lift';
      sets = [WorkoutSet(name: name, sets: s, reps: r, weightLb: w)];
      volume = (s * r * w).toDouble();
      strain = w >= 200 || s * r >= 40 ? 8 : 6;
      summary = '$name ${s}x$r${w > 0 ? ' @ $w lb' : ''}';
      if (t.contains('peloton') || t.contains('20 min')) {
        summary += ' + 20 min Peloton';
        sets = [
          ...sets,
          const WorkoutSet(name: 'Peloton', durationMin: 20),
        ];
        strain = (strain + 5) / 2;
      }
    } else if (t.contains('peloton') || t.contains('run') || t.contains('walk')) {
      strain = t.contains('20') ? 5 : 4;
      sets = const [WorkoutSet(name: 'Cardio', durationMin: 20)];
    } else if (t.contains('heavy') || t.contains('deadlift')) {
      strain = 9;
    } else if (t.contains('yoga') || t.contains('mobility')) {
      strain = 2;
    }
    return WorkoutLog(
        ts: DateTime.now(), rawText: text, strain: strain, summary: summary, sets: sets, volume: volume);
  }

  static MealComparisonImpact compareMealImpact({
    required String planned,
    required String actual,
    AiPersona persona = AiPersona.matterOfFact,
  }) {
    final pLog = parseFood(planned.isEmpty ? 'Grilled Chicken, Brown Rice & Broccoli' : planned);
    final aLog = parseFood(actual.isEmpty ? 'Double Cheeseburger & Fries' : actual);

    final pKcal = pLog.kcal == 0 ? 580.0 : pLog.kcal;
    final aKcal = aLog.kcal == 0 ? 980.0 : aLog.kcal;
    final pProt = pLog.protein == 0 ? 44.0 : pLog.protein;
    final aProt = aLog.protein == 0 ? 28.0 : aLog.protein;

    final calDelta = (aKcal - pKcal).round();
    final protDelta = (aProt - pProt);
    final isSurplus = calDelta > 150;
    final isHigherProtein = protDelta >= 5;

    final List<String> rewards = [];
    final List<String> consequences = [];
    String background;
    String planAdaptation;

    switch (persona) {
      case AiPersona.kind:
        if (isSurplus) {
          background =
              'Hey, you enjoyed your food, which is a completely natural part of life! Food is meant to nourish and bring joy, not guilt. We move! Your body soaked in quick energy, and we\'re going to effortlessly smooth this out together without stressing.';
          rewards.add('Valid dopamine hit, zero guilt, and total mental reset.');
          rewards.add('Restocked glycogen reserves so you walk into the gym tomorrow with main character energy.');
          consequences.add('Slight surplus (+$calDelta kcal), but a light hot girl/guy walk and our weekly rebalance will easily handle it.');
          consequences.add('Temporary scale bloat from sodium — hydrate, protect your peace, and be proud of showing up!');
          planAdaptation =
              'Gentle adaptation: we\'ll slightly balance tomorrow\'s fuel and keep training uplifting and fun. Zero punishment, just steady self-care wins.';
        } else {
          background =
              'Pure W! You stayed locked in, respected your blueprint, and gave your muscles top-tier nourishment. Main character consistency!';
          rewards.add('Clean protein fueling muscle synthesis without the sluggish food coma.');
          rewards.add('Vibrant clean energy that will keep your focus dialed all day.');
          consequences.add('Zero drawbacks! You are genuinely in your bag right now making winning choices for future you.');
          planAdaptation =
              'Keep cooking! Tomorrow\'s blueprint stays dialed for pure gains.';
        }
        break;

      case AiPersona.careful:
        if (isSurplus) {
          background =
              'Prudent physiological assessment: High glycemic load and saturated lipids increase digestive strain and risk sleep disruption. Let\'s pace the grind so you don\'t crash out.';
          rewards.add('Sufficient caloric buffer eliminates any under-recovery or catabolic dip.');
          rewards.add('Carbohydrate buffer prevents hypoglycemic crashes during tomorrow\'s session.');
          consequences.add('GI transit strain can elevate resting heart rate and fragment deep sleep architecture.');
          consequences.add('Sodium-induced fluid retention; mandatory dynamic warm-up before loading joints tomorrow.');
          planAdaptation =
              'Cautious rebalance: moderate compound load by 10%, hydrate, and log 15 minutes of low-intensity mobility to protect longevity.';
        } else {
          background =
              'Controlled, sustainable nutrition profile. Low inflammatory markers and stable glycemic curve protect cardiovascular and joint recovery.';
          rewards.add('Optimal bioavailability with low systemic digestive strain.');
          rewards.add('Stable blood glucose prevents insulin resistance and maintains cellular integrity.');
          consequences.add('Ensure adequate fluid and electrolyte intake to support muscle glycogen hydration.');
          planAdaptation =
              'Safely continue standard training progression. No risk factors observed.';
        }
        break;

      case AiPersona.explicitlyHonest:
        if (isSurplus) {
          background =
              'Let’s not sugarcoat this: you completely crashed out and blew your macros for cheap instant gratification. This meal was an absolute calorie bomb (+$calDelta kcal) with trash protein efficiency, and pretending otherwise is pure delulu.';
          rewards.add('Your taste buds got a 5-minute dopamine rush. Hope it was worth being down bad on your deficit.');
          rewards.add('Glycogen tanks are overflowing — so you have zero excuses to slack off on leg day tomorrow.');
          consequences.add('Massive insulin spike heading straight for adipose tissue storage because your couch-sitting self didn\'t earn this extra fuel.');
          consequences.add('The scale is going to jump 1.5–2 lbs of bloated water weight tomorrow — deal with it, no cap.');
          consequences.add('Severe post-meal crash and brain fog inbound in 45 minutes.');
          planAdaptation =
              'Reality check: Tomorrow you owe the gym serious sweat. Daily calorie budget is getting slashed by ${(calDelta / 3).round()} kcal, and you need to lock in to erase this blunder.';
        } else {
          background =
              'Look at you actually doing what you were supposed to do. You locked in instead of folding for junk food. That\'s what real discipline looks like, not just yapping on social media.';
          rewards.add('Real muscle fuel delivered without the useless fat accumulation.');
          rewards.add('Continuous fat oxidation maintained. Your abs might actually show up for summer.');
          consequences.add('Zero excuses. Keep this exact standard or stop asking why you aren\'t seeing results.');
          planAdaptation =
              'Plan stays dialed. Don\'t celebrate early or get complacent — run it back tomorrow.';
        }
        break;

      case AiPersona.matterOfFact:
        if (isSurplus) {
          background =
              'Caloric reality: Ingested meal contains a higher glycemic density and elevated lipid profile compared to the prescribed plan (+$calDelta kcal net). Circulating glucose exceeds instantaneous muscle uptake thresholds.';
          rewards.add('Immediate glycogen top-off for anaerobic strength recovery.');
          rewards.add('Elevation of anabolic signaling and temporary leptin saturation.');
          consequences.add('Elevated postprandial insulin spike followed by potential 90-minute lethargy.');
          consequences.add('Net calorie surplus of +$calDelta kcal will be partitioned toward adipose tissue if unburned.');
          consequences.add('Elevated sodium causes temporary water retention (est. +0.8 to +1.5 lbs scale weight for 24h).');
          planAdaptation =
              'Adaptive engine spreads +$calDelta kcal surplus across the next 3 days (-${(calDelta / 3).round()} kcal/day). Tomorrow morning shifts to a high-volume hypertrophy burn session.';
        } else {
          background =
              'Ingested meal maintains optimal caloric efficiency with lean protein bioavailability and stable complex carbohydrate digestion. Blood glucose and insulin remain balanced.';
          rewards.add('High Muscle Protein Synthesis (MPS) efficiency without metabolic sluggishness.');
          rewards.add('Maintained continuous fat oxidation and sustained cognitive alertness.');
          consequences.add(isHigherProtein
              ? 'Zero adverse physiological outcomes.'
              : 'Slightly lower protein intake than target (-${protDelta.abs().round()}g); consider a fast-absorbing shake later.');
          planAdaptation =
              'Plan remains on target. Tomorrow maintains full progressive overload and scheduled caloric target without adjustment.';
        }
        break;
    }

    final String avatarImpact = isSurplus
        ? 'Future avatar leanness projection softened by -0.04 (holding temporary surplus bloat).'
        : 'Future avatar leanness projection sharpened by +0.06 with visibly shredded abdominal lines.';

    final int cardioMin = (calDelta.abs() / 11).round();
    final int extraSteps = (calDelta.abs() * 22).round();
    final String offset = isSurplus
        ? 'Offset required: ~${cardioMin.clamp(20, 75)} min Zone-2 cardio grind or +${extraSteps.clamp(2500, 14000)} steps. Time to lock in.'
        : 'Banked ${calDelta.abs()} kcal toward fat loss goal. No panic cardio needed, we move.';

    return MealComparisonImpact(
      plannedMealName: planned.isEmpty ? 'Prescribed Clean Macro Plan' : planned,
      plannedNutrients: FoodItem(
        name: planned,
        kcal: pKcal,
        proteinG: pProt,
        carbsG: 60,
        fatG: 16,
      ),
      actualMealName: actual.isEmpty ? 'Ingested Meal' : actual,
      actualNutrients: FoodItem(
        name: actual,
        kcal: aKcal,
        proteinG: aProt,
        carbsG: 95,
        fatG: 34,
      ),
      nutritionalBackground: background,
      rewards: rewards,
      consequences: consequences,
      calorieDelta: calDelta,
      proteinDelta: protDelta,
      planAdaptation: planAdaptation,
      avatarProjectionImpact: avatarImpact,
      exerciseOffset: offset,
      isNetPositive: !isSurplus && isHigherProtein,
    );
  }
}


