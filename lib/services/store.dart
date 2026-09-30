import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_persona.dart';
import '../models/health_data.dart';
import '../models/meal_impact.dart';
import '../models/subscription_tier.dart';
import 'avatar_service.dart';
import 'gemini_service.dart';
import 'plan_engine.dart';
import 'wearable_service.dart';

class Store extends ChangeNotifier {
  static const _kStore = 'eat_ate_store_v1';
  bool _ready = false;
  bool get isReady => _ready;

  // ── persist (fire‑and‑frame) ──────────────────────────────────────
  Future<void> persistAsync() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photos = baseAvatarPhotos
          .take(3)
          .map(base64Encode)
          .toList();
      await prefs.setString(
        _kStore,
        jsonEncode({
          'foods': foods.map((f) => f.toJson()).toList(),
          'workouts': workouts.map((w) => w.toJson()).toList(),
          'recovery': recovery.toJson(),
          'recoverySource': recoverySource,
          'plannedWorkouts': plannedWorkouts,
          'doneWorkouts': doneWorkouts,
          'adherence': adherence,
          'avatarLean': avatarLean,
          'aiPersona': aiPersona.name,
          'subscriptionTier': subscriptionTier.name,
          'activePartnerOrgId': activePartnerOrg?.id,
          'photos': photos,
        }),
      );
    } catch (_) {}
  }

  void persist() {
    SchedulerBinding.instance.addPostFrameCallback((_) => persistAsync());
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStore);
      if (raw != null) {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        foods
          ..clear()
          ..addAll(((j['foods'] as List?) ?? const [])
              .map((e) => FoodLog.fromJson(e as Map<String, dynamic>)));
        workouts
          ..clear()
          ..addAll(((j['workouts'] as List?) ?? const [])
              .map((e) => WorkoutLog.fromJson(e as Map<String, dynamic>)));
        if (j['recovery'] is Map<String, dynamic>) {
          recovery =
              Recovery.fromJson(j['recovery'] as Map<String, dynamic>);
        }
        recoverySource = '${j['recoverySource'] ?? 'manual'}';
        plannedWorkouts = (j['plannedWorkouts'] as num? ?? 4).toInt();
        doneWorkouts = (j['doneWorkouts'] as num? ?? 0).toInt();
        adherence = (j['adherence'] as num? ?? 0.8).toDouble();
        avatarLean = (j['avatarLean'] as num? ?? 0).toDouble();
        if (j['aiPersona'] is String) {
          aiPersona = AiPersona.values.firstWhere(
            (p) => p.name == j['aiPersona'],
            orElse: () => AiPersona.matterOfFact,
          );
        }
        if (j['subscriptionTier'] is String) {
          subscriptionTier = SubscriptionTier.values.firstWhere(
            (t) => t.name == j['subscriptionTier'],
            orElse: () => SubscriptionTier.free,
          );
        }
        if (j['activePartnerOrgId'] is String) {
          activePartnerOrg = PartnerOrg.presets.firstWhere(
            (p) => p.id == j['activePartnerOrgId'],
            orElse: () => PartnerOrg.presets.first,
          );
        }
        baseAvatarPhotos
          ..clear()
          ..addAll(((j['photos'] as List?) ?? const [])
              .map((e) {
                try {
                  return Uint8List.fromList(base64Decode(e as String));
                } catch (_) {
                  return null;
                }
              })
              .whereType<Uint8List>());
      }
    } catch (_) {}
    _ready = true;
    notifyListeners();
  }

  // ── members ───────────────────────────────────────────────────────
  final GeminiService gemini;
  final AvatarService avatar;
  final WearableService wearables = WearableService();
  Store({String? geminiKey, String? terraKey, String? terraRelayUrl})
      : gemini = GeminiService(apiKey: geminiKey),
        avatar = AvatarService(geminiKey: geminiKey) {
    wearables.terraKey = terraKey;
    wearables.relayUrl = terraRelayUrl;
  }

  final List<FoodLog> foods = [];
  final List<WorkoutLog> workouts = [];
  Recovery recovery = Recovery();
  String recoverySource = 'manual';
  final List<Uint8List> baseAvatarPhotos = [];
  Uint8List? get baseAvatarPhoto =>
      baseAvatarPhotos.isEmpty ? null : baseAvatarPhotos.first;

  Uint8List? avatarImageBytes;
  int plannedWorkouts = 4;
  int doneWorkouts = 0;
  double adherence = 0.8;
  double avatarLean = 0.0;
  bool avatarAutoDrift = true;
  AiPersona aiPersona = AiPersona.matterOfFact;
  SubscriptionTier subscriptionTier = SubscriptionTier.free;
  PartnerOrg? activePartnerOrg;
  CoachProfile coachProfile = CoachProfile.defaultCoach;

  void setSubscriptionTier(SubscriptionTier tier, {PartnerOrg? partner}) {
    subscriptionTier = tier;
    if (partner != null) {
      activePartnerOrg = partner;
    } else if (tier != SubscriptionTier.b2bPartner) {
      activePartnerOrg = null;
    }
    persist();
    notifyListeners();
  }

  bool redeemPartnerCode(String code) {
    final org = PartnerOrg.fromCode(code);
    if (org != null) {
      activePartnerOrg = org;
      subscriptionTier = SubscriptionTier.b2bPartner;
      persist();
      notifyListeners();
      return true;
    }
    return false;
  }

  int get todayLogsCount {
    final now = DateTime.now();
    return foods.where((f) => f.ts.year == now.year && f.ts.month == now.month && f.ts.day == now.day).length;
  }

  bool get canLogMore {
    if (subscriptionTier.hasUnlimitedLogging) return true;
    return todayLogsCount < subscriptionTier.dailyLogLimit;
  }

  void setAiPersona(AiPersona persona) {
    aiPersona = persona;
    persist();
    notifyListeners();
  }

  double get eatenKcal => foods.fold(0, (s, f) => s + f.kcal);
  double get eatenProtein => foods.fold(0, (s, f) => s + f.protein);

  TomorrowPlan get plan => generatePlan(
      foods: foods, workouts: workouts, recovery: recovery);
  List<DayPlan> get week => generateWeek(
      foods: foods, workouts: workouts, recovery: recovery);

  MealComparisonImpact? lastMealImpact;

  Future<void> addFood(String text, {Uint8List? imageBytes}) async {
    foods.add(await gemini.parseFood(text, imageBytes: imageBytes));
    notifyListeners();
  }

  Future<MealComparisonImpact> analyzePlannedVsActualMeal({
    required String planned,
    required String actual,
    Uint8List? imageBytes,
    AiPersona? persona,
  }) async {
    final effectivePersona = persona ?? aiPersona;
    final impact = await gemini.analyzeMealImpact(
      planned: planned,
      actual: actual,
      imageBytes: imageBytes,
      persona: effectivePersona,
    );
    lastMealImpact = impact;
    notifyListeners();
    return impact;
  }

  Future<void> logComparedMeal(MealComparisonImpact impact, {Uint8List? imageBytes}) async {
    final foodLog = FoodLog(
      ts: DateTime.now(),
      rawText: impact.actualMealName,
      items: [impact.actualNutrients],
    );
    foods.add(foodLog);

    if (impact.calorieDelta > 300) {
      adherence = (adherence - 0.05).clamp(0.0, 1.0);
    } else if (impact.isNetPositive) {
      adherence = (adherence + 0.05).clamp(0.0, 1.0);
    }

    notifyListeners();
    if (avatarAutoDrift) unawaitedRender();
  }

  Future<void> addWorkout(String text) async {
    workouts.add(await gemini.parseWorkout(text));
    doneWorkouts++;
    adherence = adherence7d(
        plannedWorkouts: plannedWorkouts, doneWorkouts: doneWorkouts);
    notifyListeners();
    if (avatarAutoDrift) unawaitedRender();
  }

  void updateFoodItem(int logIdx, int itemIdx, FoodItem updated) {
    if (logIdx < 0 || logIdx >= foods.length) return;
    final log = foods[logIdx];
    if (itemIdx < 0 || itemIdx >= log.items.length) return;
    log.items[itemIdx] = updated;
    notifyListeners();
  }

  void updateStrain(int workoutIdx, double strain) {
    if (workoutIdx < 0 || workoutIdx >= workouts.length) return;
    workouts[workoutIdx].strain = strain.clamp(0, 10);
    notifyListeners();
  }

  void completePlannedWorkout() {
    doneWorkouts++;
    adherence = adherence7d(
        plannedWorkouts: plannedWorkouts, doneWorkouts: doneWorkouts);
    notifyListeners();
  }

  void addFoodDirect(FoodLog log) {
    foods.add(log);
    notifyListeners();
  }

  void setRecovery(double sleepH, int readiness,
      {String source = 'manual',
      double hrvMs = 0,
      int restingHr = 60,
      int steps = 0,
      int activeKcal = 0}) {
    recovery = Recovery(
      sleepHours: sleepH,
      readiness: readiness,
      hrvMs: hrvMs,
      restingHr: restingHr,
      steps: steps,
      activeKcal: activeKcal,
    );
    recoverySource = source;
    notifyListeners();
  }

  Future<String> pullWearable() async {
    final res = await wearables.fetchLastNight();
    if (res == null) {
      return 'No wearable data — check permissions${wearables.terraKey != null ? ' or Terra link' : ''}. Keeping manual.';
    }
    setRecovery(
      res.recovery.sleepHours,
      res.recovery.readiness,
      source: res.source,
      hrvMs: res.recovery.hrvMs,
      restingHr: res.recovery.restingHr,
      steps: res.recovery.steps,
      activeKcal: res.recovery.activeKcal,
    );
    return 'Pulled from ${res.source}: ${res.recovery.sleepHours.toStringAsFixed(1)}h, readiness ${res.recovery.readiness}, ${res.recovery.steps} steps';
  }

  Future<void> unawaitedRender() async {
    try {
      final bytes = await avatar.renderFutureYou(
        lean: projectedLean,
        basePhotoBytes: baseAvatarPhoto,
      );
      if (bytes != null) {
        avatarImageBytes = bytes;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<String> renderAvatar() async {
    if (!avatar.hasKey) return 'Needs GEMINI_API_KEY — showing local stub.';
    final bytes = await avatar.renderFutureYou(
      lean: projectedLean,
      basePhotoBytes: baseAvatarPhoto,
    );
    if (bytes == null) {
      return baseAvatarPhoto == null
          ? 'Render failed. Add your base photo first, then retry.'
          : 'Render failed — check key/quota, keeping stub.';
    }
    avatarImageBytes = bytes;
    notifyListeners();
    return 'Rendered future you with Gemini';
  }

  void addBaseAvatarPhotos(List<Uint8List> bytes) {
    final all = [...bytes, ...baseAvatarPhotos];
    all.sort((a, b) => b.lengthInBytes.compareTo(a.lengthInBytes));
    baseAvatarPhotos
      ..clear()
      ..addAll(all.take(10));
    notifyListeners();
  }

  void setBaseAvatarPhoto(Uint8List bytes) => addBaseAvatarPhotos([bytes]);

  void skipWeek() {
    adherence = (adherence - 0.25).clamp(0.0, 1.0);
    avatarLean = (avatarLean - 0.2).clamp(-1.0, 1.0);
    notifyListeners();
    if (avatarAutoDrift) unawaitedRender();
  }

  void setAvatarLean(double v) {
    avatarLean = v.clamp(-1.0, 1.0);
    notifyListeners();
  }

  void setAvatarAutoDrift(bool v) {
    avatarAutoDrift = v;
    notifyListeners();
  }

  // Projected leanness = slider + adherence drift
  double get projectedLean =>
      (avatarLean * 0.7 + (adherence - 0.7)).clamp(-1.0, 1.0);
}