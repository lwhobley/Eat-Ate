import '../models/health_data.dart';

const _program = ['Push', 'Pull', 'Legs', 'Recovery / mobility'];

// Pure rules engine — deterministic targets. Gemini only rewords `why`.
TomorrowPlan generatePlan({
  required List<FoodLog> foods,
  required List<WorkoutLog> workouts,
  required Recovery recovery,
  int baseKcal = 2400,
  int baseProtein = 160,
  int dayIndex = 0, // 0..6 rotation for Push/Pull/Legs
}) {
  final eaten = foods.fold<double>(0, (s, f) => s + f.kcal);
  final ateBig = eaten > baseKcal + 800; // e.g. Thanksgiving
  final sleptBad = recovery.sleepHours < 5.5 || recovery.readiness < 50;
  final sleptOk = recovery.sleepHours < 6.5 || recovery.readiness < 65;

  String trainingTitle, trainingDetail;
  int kcal = baseKcal;
  int protein = baseProtein;
  String sleepTarget = '23:00–07:00 (7.5–8h)';
  String programDay = _program[dayIndex % _program.length];

  if (sleptBad) {
    trainingTitle = 'Light recovery';
    trainingDetail = '20–30 min walk + mobility. No heavy lifting.';
    protein += 15;
    sleepTarget = '22:30–07:30 (prioritize 8h+)';
    programDay = 'Recovery / mobility';
  } else if (sleptOk) {
    trainingTitle = 'Moderate $programDay';
    trainingDetail = '$programDay technique work at 60–70%. Cap RPE 7.';
    protein += 10;
  } else {
    trainingTitle = 'Heavy $programDay';
    trainingDetail = '$programDay progressive overload. Push main lift +5 lb vs last week.';
  }

  if (ateBig) {
    kcal = (baseKcal * 0.9).round(); // rebalance, no guilt
  }

  final reasons = <String>[];
  if (sleptBad) {
    reasons.add(
        'sleep ${recovery.sleepHours.toStringAsFixed(1)}h / readiness ${recovery.readiness} → swapped heavy for light, protein up');
  } else if (sleptOk) {
    reasons.add('recovery dipped → dialed intensity to moderate');
  } else {
    reasons.add('recovery solid → keep overload');
  }
  if (ateBig) {
    reasons.add('big day (${eaten.round()} kcal) → trimmed tomorrow ~10%');
  }
  if (workouts.isNotEmpty && workouts.last.strain >= 8) {
    reasons.add('yesterday strain high → favor recovery');
    if (!sleptBad) {
      trainingTitle = 'Moderate $programDay';
      trainingDetail = 'High strain yesterday — $programDay technique work only.';
    }
  }

  return TomorrowPlan(
    trainingTitle: trainingTitle,
    trainingDetail: trainingDetail,
    kcalTarget: kcal,
    proteinTarget: protein,
    sleepTarget: sleepTarget,
    why: '${reasons.join('. ')}.',
    programDay: programDay,
    breakfastHint: 'Front-load ${((protein * 0.35).round())}g protein by lunch',
  );
}

// Weekly rebalance: spread a big surplus across the next 3 days instead of
// crash-dieting tomorrow. Returns 7 day plans starting today.
List<DayPlan> generateWeek({
  required List<FoodLog> foods,
  required List<WorkoutLog> workouts,
  required Recovery recovery,
  int baseKcal = 2400,
  int baseProtein = 160,
}) {
  final eaten = foods.fold<double>(0, (s, f) => s + f.kcal);
  final surplus = (eaten - baseKcal).clamp(0, 3000).toDouble();
  // spread 60% of surplus over next 3 days
  final dailyTrim = surplus > 500 ? (surplus * 0.6 / 3).round() : 0;

  final now = DateTime.now();
  return List.generate(7, (i) {
    final isNear = i >= 1 && i <= 3 && dailyTrim > 0;
    final dayKcal = isNear ? baseKcal - dailyTrim : baseKcal;
    final p = generatePlan(
      foods: i == 0 ? foods : const [],
      workouts: i == 0 ? workouts : const [],
      recovery: recovery,
      baseKcal: dayKcal,
      baseProtein: baseProtein,
      dayIndex: i,
    );
    return DayPlan(
      date: DateTime(now.year, now.month, now.day).add(Duration(days: i)),
      plan: p,
    );
  });
}

double adherence7d({required int plannedWorkouts, required int doneWorkouts}) {
  if (plannedWorkouts <= 0) return 1.0;
  return (doneWorkouts / plannedWorkouts).clamp(0.0, 1.0);
}
