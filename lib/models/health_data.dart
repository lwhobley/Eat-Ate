class FoodItem {
  final String name;
  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double grams;
  final double confidence; // 0..1 parser confidence
  const FoodItem({
    required this.name,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.grams = 0,
    this.confidence = 0.7,
  });

  FoodItem copyWith({
    String? name,
    double? kcal,
    double? proteinG,
    double? carbsG,
    double? fatG,
    double? grams,
    double? confidence,
  }) =>
      FoodItem(
        name: name ?? this.name,
        kcal: kcal ?? this.kcal,
        proteinG: proteinG ?? this.proteinG,
        carbsG: carbsG ?? this.carbsG,
        fatG: fatG ?? this.fatG,
        grams: grams ?? this.grams,
        confidence: confidence ?? this.confidence,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'kcal': kcal,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'grams': grams,
        'confidence': confidence,
      };

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        name: '${j['name'] ?? 'item'}',
        kcal: (j['kcal'] as num? ?? 0).toDouble(),
        proteinG: (j['proteinG'] as num? ?? 0).toDouble(),
        carbsG: (j['carbsG'] as num? ?? 0).toDouble(),
        fatG: (j['fatG'] as num? ?? 0).toDouble(),
        grams: (j['grams'] as num? ?? 0).toDouble(),
        confidence: (j['confidence'] as num? ?? 0.7).toDouble(),
      );
}

class FoodLog {
  final DateTime ts;
  final String rawText;
  final List<FoodItem> items;
  FoodLog({required this.ts, required this.rawText, required this.items});
  double get kcal => items.fold(0, (s, i) => s + i.kcal);
  double get protein => items.fold(0, (s, i) => s + i.proteinG);

  Map<String, dynamic> toJson() => {
        'ts': ts.toIso8601String(),
        'rawText': rawText,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory FoodLog.fromJson(Map<String, dynamic> j) => FoodLog(
        ts: DateTime.tryParse('${j['ts']}') ?? DateTime.now(),
        rawText: '${j['rawText'] ?? ''}',
        items: ((j['items'] as List?) ?? const [])
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutSet {
  final String name;
  final int sets;
  final int reps;
  final double weightLb;
  final double durationMin;
  const WorkoutSet({
    required this.name,
    this.sets = 0,
    this.reps = 0,
    this.weightLb = 0,
    this.durationMin = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'weightLb': weightLb,
        'durationMin': durationMin,
      };

  factory WorkoutSet.fromJson(Map<String, dynamic> j) => WorkoutSet(
        name: '${j['name'] ?? 'set'}',
        sets: (j['sets'] as num? ?? 0).toInt(),
        reps: (j['reps'] as num? ?? 0).toInt(),
        weightLb: (j['weightLb'] as num? ?? 0).toDouble(),
        durationMin: (j['durationMin'] as num? ?? 0).toDouble(),
      );
}

class WorkoutLog {
  final DateTime ts;
  final String rawText;
  double strain; // 0-10, editable
  final String summary;
  final List<WorkoutSet> sets;
  final double volume; // e.g. total lb lifted
  WorkoutLog({
    required this.ts,
    required this.rawText,
    required this.strain,
    required this.summary,
    this.sets = const [],
    this.volume = 0,
  });

  Map<String, dynamic> toJson() => {
        'ts': ts.toIso8601String(),
        'rawText': rawText,
        'strain': strain,
        'summary': summary,
        'sets': sets.map((s) => s.toJson()).toList(),
        'volume': volume,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> j) => WorkoutLog(
        ts: DateTime.tryParse('${j['ts']}') ?? DateTime.now(),
        rawText: '${j['rawText'] ?? ''}',
        strain: (j['strain'] as num? ?? 5).toDouble(),
        summary: '${j['summary'] ?? ''}',
        sets: ((j['sets'] as List?) ?? const [])
            .map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
            .toList(),
        volume: (j['volume'] as num? ?? 0).toDouble(),
      );
}

class Recovery {
  double sleepHours;
  int readiness; // 0-100
  double hrvMs;
  int restingHr;
  int steps;
  int activeKcal;
  Recovery({
    this.sleepHours = 7.5,
    this.readiness = 75,
    this.hrvMs = 0,
    this.restingHr = 60,
    this.steps = 0,
    this.activeKcal = 0,
  });

  Map<String, dynamic> toJson() => {
        'sleepHours': sleepHours,
        'readiness': readiness,
        'hrvMs': hrvMs,
        'restingHr': restingHr,
        'steps': steps,
        'activeKcal': activeKcal,
      };

  factory Recovery.fromJson(Map<String, dynamic> j) => Recovery(
        sleepHours: (j['sleepHours'] as num? ?? 7.5).toDouble(),
        readiness: (j['readiness'] as num? ?? 75).toInt(),
        hrvMs: (j['hrvMs'] as num? ?? 0).toDouble(),
        restingHr: (j['restingHr'] as num? ?? 60).toInt(),
        steps: (j['steps'] as num? ?? 0).toInt(),
        activeKcal: (j['activeKcal'] as num? ?? 0).toInt(),
      );
}

class TomorrowPlan {
  final String trainingTitle;
  final String trainingDetail;
  final int kcalTarget;
  final int proteinTarget;
  final String sleepTarget;
  final String why;
  final String programDay; // e.g. Push / Pull / Legs / Recovery
  final String breakfastHint;
  const TomorrowPlan({
    required this.trainingTitle,
    required this.trainingDetail,
    required this.kcalTarget,
    required this.proteinTarget,
    required this.sleepTarget,
    required this.why,
    this.programDay = 'General',
    this.breakfastHint = '',
  });
}

class DayPlan {
  final DateTime date;
  final TomorrowPlan plan;
  const DayPlan({required this.date, required this.plan});
}
