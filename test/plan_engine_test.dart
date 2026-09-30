import 'package:flutter_test/flutter_test.dart';
import 'package:eat_ate/models/health_data.dart';
import 'package:eat_ate/services/plan_engine.dart';
import 'package:eat_ate/services/mock_parser.dart';

void main() {
  test('bad sleep swaps heavy for light + protein up', () {
    final p = generatePlan(
      foods: [],
      workouts: [],
      recovery: Recovery(sleepHours: 4.5, readiness: 42),
    );
    expect(p.trainingTitle, 'Light recovery');
    expect(p.proteinTarget, greaterThan(160));
  });

  test('big dinner trims tomorrow ~10%', () {
    final plate = MockParser.parseFood('Thanksgiving turkey plate + pie');
    final p = generatePlan(
      foods: [plate, plate], // full big day >3200 kcal
      workouts: [],
      recovery: Recovery(sleepHours: 8, readiness: 85),
    );
    expect(p.kcalTarget, 2160); // 2400 * 0.9
    expect(p.trainingTitle, contains('Heavy'));
    expect(p.programDay, 'Push');
  });

  test('burrito bowl + squats parse with sets/volume', () {
    final f = MockParser.parseFood('Burrito bowl');
    expect(f.kcal, 720);
    expect(f.items.first.confidence, greaterThan(0.5));
    final w =
        MockParser.parseWorkout('5x5 squats at 225 lbs, then 20 min Peloton');
    expect(w.sets.first.sets, 5);
    expect(w.sets.first.reps, 5);
    expect(w.volume, 5 * 5 * 225);
    expect(w.strain, inInclusiveRange(4, 8));
  });

  test('week spreads surplus, no crash diet', () {
    final plate = MockParser.parseFood('Thanksgiving turkey plate + pie');
    final week = generateWeek(
      foods: [plate, plate],
      workouts: [],
      recovery: Recovery(sleepHours: 8, readiness: 85),
    );
    expect(week.length, 7);
    // days 1-3 trimmed, day 4+ back to base
    expect(week[1].plan.kcalTarget, lessThan(2400));
    expect(week[5].plan.kcalTarget, 2400);
  });

  test('adherence math', () {
    expect(adherence7d(plannedWorkouts: 4, doneWorkouts: 3), 0.75);
    expect(adherence7d(plannedWorkouts: 0, doneWorkouts: 0), 1.0);
  });
}
