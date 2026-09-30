import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/ai_persona.dart';
import '../models/health_data.dart';
import '../models/meal_impact.dart';
import 'mock_parser.dart';

// Uses Gemini when apiKey is provided, else falls back to MockParser.
// Pass key via --dart-define=GEMINI_API_KEY=xxx
class GeminiService {
  final String? apiKey;
  GeminiService({this.apiKey});

  bool get hasKey => apiKey != null && apiKey!.isNotEmpty;

  /// Last-call diagnostics for live-verify: 'gemini' | 'mock', plus error.
  String lastSource = 'mock';
  String? lastError;

  GenerativeModel _model({bool vision = false}) => GenerativeModel(
        model: vision ? 'gemini-2.0-flash' : 'gemini-2.0-flash',
        apiKey: apiKey!,
      );

  Future<FoodLog> parseFood(String text, {Uint8List? imageBytes}) async {
    if (!hasKey) {
      lastSource = 'mock';
      lastError = null;
      return MockParser.parseFood(
          text.isEmpty && imageBytes != null ? 'Photo meal' : text);
    }
    try {
      final prompt =
          'Parse this meal into JSON array of {name,kcal,proteinG,carbsG,fatG}. Meal: "$text". Return ONLY JSON array, no markdown.';
      final parts = <Part>[TextPart(prompt)];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }
      final res = await _model(vision: imageBytes != null)
          .generateContent([Content.multi(parts)]);
      final parsed = _parseFoodJson(res.text ?? '',
          fallbackName: text.isEmpty ? 'Photo meal' : text);
      if (parsed != null) {
        lastSource = 'gemini';
        lastError = null;
        return FoodLog(ts: DateTime.now(), rawText: text, items: parsed);
      }
      lastSource = 'mock';
      lastError = 'Gemini returned non-JSON; fell back to estimate';
      return MockParser.parseFood(text);
    } catch (e) {
      lastSource = 'mock';
      lastError = 'Gemini food error: ${_short(e)}';
      return MockParser.parseFood(text);
    }
  }

  List<FoodItem>? _parseFoodJson(String raw, {required String fallbackName}) {
    try {
      final start = raw.indexOf('[');
      final end = raw.lastIndexOf(']');
      if (start < 0 || end <= start) return null;
      final list = jsonDecode(raw.substring(start, end + 1)) as List;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return FoodItem(
          name: '${m['name'] ?? fallbackName}',
          kcal: (m['kcal'] as num? ?? 500).toDouble(),
          proteinG: (m['proteinG'] as num? ?? 25).toDouble(),
          carbsG: (m['carbsG'] as num? ?? 50).toDouble(),
          fatG: (m['fatG'] as num? ?? 18).toDouble(),
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  Future<WorkoutLog> parseWorkout(String text) async {
    if (!hasKey) {
      lastSource = 'mock';
      return MockParser.parseWorkout(text);
    }
    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey!);
      final prompt = 'Parse workout "$text" into strain 0-10 and short summary. '
          'Return "strain|summary" only.';
      final res = await model.generateContent([Content.text(prompt)]);
      final raw = res.text ?? '';
      final parts = raw.split('|');
      if (parts.length == 2) {
        final s = double.tryParse(parts[0].trim()) ?? 5;
        lastSource = 'gemini';
        lastError = null;
        return WorkoutLog(ts: DateTime.now(), rawText: text, strain: s.clamp(0, 10), summary: parts[1].trim());
      }
      lastSource = 'mock';
      lastError = 'Gemini workout format unexpected; used estimate';
      return MockParser.parseWorkout(text);
    } catch (e) {
      lastSource = 'mock';
      lastError = 'Gemini workout error: ${_short(e)}';
      return MockParser.parseWorkout(text);
    }
  }

  Future<String> explainPlan(TomorrowPlan plan, {AiPersona persona = AiPersona.matterOfFact}) async {
    if (!hasKey) return plan.why;
    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey!);
      final res = await model.generateContent([
        Content.text('Rewrite in one sentence matching this tone (${persona.promptGuidance}): ${plan.why}')
      ]);
      return res.text?.trim() ?? plan.why;
    } catch (e) {
      lastError = 'Gemini explain error: ${_short(e)}';
      return plan.why;
    }
  }

  Future<MealComparisonImpact> analyzeMealImpact({
    required String planned,
    required String actual,
    Uint8List? imageBytes,
    AiPersona persona = AiPersona.matterOfFact,
  }) async {
    if (!hasKey) {
      lastSource = 'mock';
      return MockParser.compareMealImpact(planned: planned, actual: actual, persona: persona);
    }
    try {
      final prompt = '''
You are an elite sports nutritionist and metabolic coach.
Analyze the user's PLANNED meal vs ACTUALLY INGESTED meal.
${persona.promptGuidance}

PLANNED MEAL: "$planned"
ACTUAL INGESTED MEAL: "$actual"

Return a JSON object ONLY (no markdown formatting, no code blocks):
{
  "plannedKcal": 600,
  "plannedProtein": 42.0,
  "plannedCarbs": 60.0,
  "plannedFat": 16.0,
  "actualKcal": 850,
  "actualProtein": 30.0,
  "actualCarbs": 95.0,
  "actualFat": 32.0,
  "nutritionalBackground": "2-3 sentences analyzing macro quality, glycemic response, sodium, and cellular recovery.",
  "rewards": ["gain 1", "gain 2"],
  "consequences": ["cost 1", "cost 2"],
  "planAdaptation": "Adaptive guidance for tomorrow's training and calories",
  "avatarProjectionImpact": "Projection on future physique leanness",
  "exerciseOffset": "Cardio minutes or extra steps required to offset surplus",
  "isNetPositive": true
}
''';
      final parts = <Part>[TextPart(prompt)];
      if (imageBytes != null) {
        parts.add(DataPart('image/jpeg', imageBytes));
      }
      final res = await _model(vision: imageBytes != null)
          .generateContent([Content.multi(parts)]);
      final raw = res.text ?? '';
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start >= 0 && end > start) {
        final jsonStr = raw.substring(start, end + 1);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;

        final pKcal = (map['plannedKcal'] as num? ?? 600).toDouble();
        final pProt = (map['plannedProtein'] as num? ?? 40).toDouble();
        final pCarb = (map['plannedCarbs'] as num? ?? 60).toDouble();
        final pFat = (map['plannedFat'] as num? ?? 16).toDouble();

        final aKcal = (map['actualKcal'] as num? ?? 850).toDouble();
        final aProt = (map['actualProtein'] as num? ?? 30).toDouble();
        final aCarb = (map['actualCarbs'] as num? ?? 90).toDouble();
        final aFat = (map['actualFat'] as num? ?? 30).toDouble();

        final rewards = ((map['rewards'] as List?) ?? const []).map((e) => '$e').toList();
        final consequences = ((map['consequences'] as List?) ?? const []).map((e) => '$e').toList();

        lastSource = 'gemini';
        lastError = null;
        return MealComparisonImpact(
          plannedMealName: planned.isEmpty ? 'Prescribed Meal Plan' : planned,
          plannedNutrients: FoodItem(name: planned, kcal: pKcal, proteinG: pProt, carbsG: pCarb, fatG: pFat),
          actualMealName: actual.isEmpty ? 'Ingested Meal' : actual,
          actualNutrients: FoodItem(name: actual, kcal: aKcal, proteinG: aProt, carbsG: aCarb, fatG: aFat),
          nutritionalBackground: '${map['nutritionalBackground'] ?? ''}',
          rewards: rewards,
          consequences: consequences,
          calorieDelta: (aKcal - pKcal).round(),
          proteinDelta: aProt - pProt,
          planAdaptation: '${map['planAdaptation'] ?? ''}',
          avatarProjectionImpact: '${map['avatarProjectionImpact'] ?? ''}',
          exerciseOffset: '${map['exerciseOffset'] ?? ''}',
          isNetPositive: map['isNetPositive'] as bool? ?? false,
        );
      }
      lastSource = 'mock';
      return MockParser.compareMealImpact(planned: planned, actual: actual);
    } catch (e) {
      lastSource = 'mock';
      lastError = 'Gemini meal compare error: ${_short(e)}';
      return MockParser.compareMealImpact(planned: planned, actual: actual);
    }
  }

  String _short(Object e) {
    final s = '$e';
    return s.length > 160 ? '${s.substring(0, 160)}…' : s;
  }
}

