import 'package:flutter_test/flutter_test.dart';
import 'package:eat_ate/models/ai_persona.dart';
import 'package:eat_ate/services/mock_parser.dart';
import 'package:eat_ate/services/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MockParser compareMealImpact calculates calorie delta, rewards and consequences', () {
    final impact = MockParser.compareMealImpact(
      planned: 'Grilled Chicken, Brown Rice & Broccoli',
      actual: 'Double Cheeseburger & Large Fries with Soda',
      persona: AiPersona.matterOfFact,
    );

    expect(impact.calorieDelta, greaterThan(0));
    expect(impact.rewards, isNotEmpty);
    expect(impact.consequences, isNotEmpty);
    expect(impact.nutritionalBackground, isNotEmpty);
    expect(impact.planAdaptation, contains('Adaptive engine'));
    expect(impact.avatarProjectionImpact, contains('avatar'));
    expect(impact.exerciseOffset, contains('Offset required'));
  });

  test('AI Response Levels: Kind, Matter-of-Fact, Careful, Explicitly Honest', () {
    const planned = 'Chicken Breast & Quinoa';
    const actual = 'Pepperoni Pizza';

    // 1. Kind: empathetic, zero guilt
    final kindImpact = MockParser.compareMealImpact(
      planned: planned,
      actual: actual,
      persona: AiPersona.kind,
    );
    expect(kindImpact.nutritionalBackground, contains('natural part of life'));
    expect(kindImpact.planAdaptation, contains('Gentle adaptation'));

    // 2. Matter-of-Fact: objective, data-driven
    final mofImpact = MockParser.compareMealImpact(
      planned: planned,
      actual: actual,
      persona: AiPersona.matterOfFact,
    );
    expect(mofImpact.nutritionalBackground, contains('glycemic density'));
    expect(mofImpact.planAdaptation, contains('Adaptive engine'));

    // 3. Careful: safety, digestion, fatigue
    final carefulImpact = MockParser.compareMealImpact(
      planned: planned,
      actual: actual,
      persona: AiPersona.careful,
    );
    expect(carefulImpact.nutritionalBackground, contains('Prudent'));
    expect(carefulImpact.planAdaptation, contains('Cautious rebalance'));

    // 4. Explicitly Honest: brutally direct, calls out excuses
    final honestImpact = MockParser.compareMealImpact(
      planned: planned,
      actual: actual,
      persona: AiPersona.explicitlyHonest,
    );
    expect(honestImpact.nutritionalBackground, contains('sugarcoat'));
    expect(honestImpact.consequences.first, contains('Massive insulin spike'));
    expect(honestImpact.planAdaptation, contains('Reality check'));
  });

  test('Store updates and persists AiPersona', () async {
    final store = Store(geminiKey: null, terraKey: null);
    expect(store.aiPersona, AiPersona.matterOfFact);

    store.setAiPersona(AiPersona.explicitlyHonest);
    expect(store.aiPersona, AiPersona.explicitlyHonest);

    final impact = await store.analyzePlannedVsActualMeal(
      planned: 'Chicken Salad',
      actual: 'Burger & Fries',
    );
    expect(impact.nutritionalBackground, contains('sugarcoat'));
  });
}
