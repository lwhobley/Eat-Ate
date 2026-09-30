import 'health_data.dart';

class MealComparisonImpact {
  final String plannedMealName;
  final FoodItem plannedNutrients;
  final String actualMealName;
  final FoodItem actualNutrients;
  final String nutritionalBackground; // AI analysis of ingredients, glycemic index, micronutrients
  final List<String> rewards;          // Gains / positive athletic & metabolic outcomes
  final List<String> consequences;     // Costs / negative physiological & body composition outcomes
  final int calorieDelta;              // actual - planned
  final double proteinDelta;           // actual - planned
  final String planAdaptation;         // How tomorrow's plan adapts
  final String avatarProjectionImpact; // Visual drift on future avatar
  final String exerciseOffset;         // Cardio / steps required to offset or burn surplus
  final bool isNetPositive;

  const MealComparisonImpact({
    required this.plannedMealName,
    required this.plannedNutrients,
    required this.actualMealName,
    required this.actualNutrients,
    required this.nutritionalBackground,
    required this.rewards,
    required this.consequences,
    required this.calorieDelta,
    required this.proteinDelta,
    required this.planAdaptation,
    required this.avatarProjectionImpact,
    required this.exerciseOffset,
    required this.isNetPositive,
  });

  Map<String, dynamic> toJson() => {
        'plannedMealName': plannedMealName,
        'plannedNutrients': plannedNutrients.toJson(),
        'actualMealName': actualMealName,
        'actualNutrients': actualNutrients.toJson(),
        'nutritionalBackground': nutritionalBackground,
        'rewards': rewards,
        'consequences': consequences,
        'calorieDelta': calorieDelta,
        'proteinDelta': proteinDelta,
        'planAdaptation': planAdaptation,
        'avatarProjectionImpact': avatarProjectionImpact,
        'exerciseOffset': exerciseOffset,
        'isNetPositive': isNetPositive,
      };

  factory MealComparisonImpact.fromJson(Map<String, dynamic> j) {
    return MealComparisonImpact(
      plannedMealName: '${j['plannedMealName'] ?? 'Planned Meal'}',
      plannedNutrients: j['plannedNutrients'] is Map<String, dynamic>
          ? FoodItem.fromJson(j['plannedNutrients'] as Map<String, dynamic>)
          : const FoodItem(name: 'Planned', kcal: 600, proteinG: 40, carbsG: 60, fatG: 18),
      actualMealName: '${j['actualMealName'] ?? 'Actual Meal'}',
      actualNutrients: j['actualNutrients'] is Map<String, dynamic>
          ? FoodItem.fromJson(j['actualNutrients'] as Map<String, dynamic>)
          : const FoodItem(name: 'Actual', kcal: 850, proteinG: 30, carbsG: 95, fatG: 35),
      nutritionalBackground: '${j['nutritionalBackground'] ?? ''}',
      rewards: ((j['rewards'] as List?) ?? const []).map((e) => '$e').toList(),
      consequences: ((j['consequences'] as List?) ?? const []).map((e) => '$e').toList(),
      calorieDelta: (j['calorieDelta'] as num? ?? 0).toInt(),
      proteinDelta: (j['proteinDelta'] as num? ?? 0).toDouble(),
      planAdaptation: '${j['planAdaptation'] ?? ''}',
      avatarProjectionImpact: '${j['avatarProjectionImpact'] ?? ''}',
      exerciseOffset: '${j['exerciseOffset'] ?? ''}',
      isNetPositive: j['isNetPositive'] as bool? ?? false,
    );
  }
}
