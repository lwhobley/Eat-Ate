import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eat_ate/models/subscription_tier.dart';
import 'package:eat_ate/models/health_data.dart';
import 'package:eat_ate/services/store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Subscription Tier Architecture & Monetization', () {
    test('Default tier is Free with avatar acquisition and 3 daily logs limit', () {
      final store = Store();
      expect(store.subscriptionTier, equals(SubscriptionTier.free));
      expect(store.subscriptionTier.dailyLogLimit, equals(3));
      expect(store.subscriptionTier.hasUnlimitedLogging, isFalse);
      expect(store.subscriptionTier.hasWearableSync, isFalse);
      expect(store.subscriptionTier.hasCoachReview, isFalse);
      expect(store.canLogMore, isTrue);

      // Add 3 food logs
      store.foods.add(FoodLog(ts: DateTime.now(), rawText: 'Meal 1', items: []));
      store.foods.add(FoodLog(ts: DateTime.now(), rawText: 'Meal 2', items: []));
      store.foods.add(FoodLog(ts: DateTime.now(), rawText: 'Meal 3', items: []));

      expect(store.todayLogsCount, equals(3));
      expect(store.canLogMore, isFalse);
    });

    test('Pro Subscription (Annual & Monthly) unlocks unlimited logs & wearables', () {
      final store = Store();

      // Pro Monthly
      store.setSubscriptionTier(SubscriptionTier.proMonthly);
      expect(store.subscriptionTier.isProOrAbove, isTrue);
      expect(store.subscriptionTier.hasUnlimitedLogging, isTrue);
      expect(store.subscriptionTier.hasWearableSync, isTrue);
      expect(store.subscriptionTier.hasAdaptivePlan, isTrue);
      expect(store.subscriptionTier.hasLiveAvatarDrift, isTrue);
      expect(store.subscriptionTier.hasCoachReview, isFalse);
      expect(store.subscriptionTier.priceDisplay, contains('14.99'));

      // Pro Annual (Recommended 33% 1-yr retention benchmark)
      store.setSubscriptionTier(SubscriptionTier.proAnnual);
      expect(store.subscriptionTier.isProOrAbove, isTrue);
      expect(store.subscriptionTier.priceDisplay, contains('79.99'));
      expect(store.subscriptionTier.tagline, contains('33% 1-Yr Retention'));

      // Add 10 logs; canLogMore should remain true
      for (int i = 0; i < 10; i++) {
        store.foods.add(FoodLog(ts: DateTime.now(), rawText: 'Meal $i', items: []));
      }
      expect(store.canLogMore, isTrue);
    });

    test('Human-in-the-Loop Coach tier (\$49/mo) unlocks real coach accountability', () {
      final store = Store();
      store.setSubscriptionTier(SubscriptionTier.coachLoop);

      expect(store.subscriptionTier.hasCoachReview, isTrue);
      expect(store.subscriptionTier.isCoachOrAbove, isTrue);
      expect(store.subscriptionTier.priceDisplay, contains('49'));
      expect(store.coachProfile.name, contains('Sarah Jenkins'));
      expect(store.coachProfile.name, contains('CSCS'));
      expect(store.coachProfile.credentials, contains('CISSN'));
      expect(store.coachProfile.avatarInitials, equals('SJ'));
      expect(store.coachProfile.nextCheckInDate, contains('Sunday'));
    });

    test('B2B2C White-label Partner Code redemption (EQUINOX, WELLNESS, GLP1)', () {
      final store = Store();

      // Invalid code
      final invalidResult = store.redeemPartnerCode('INVALID_CODE');
      expect(invalidResult, isFalse);
      expect(store.activePartnerOrg, isNull);
      expect(store.subscriptionTier, equals(SubscriptionTier.free));

      // EQUINOX (US Gym Chains)
      final equinoxResult = store.redeemPartnerCode('EQUINOX');
      expect(equinoxResult, isTrue);
      expect(store.activePartnerOrg?.id, equals('equinox'));
      expect(store.activePartnerOrg?.type, equals(PartnerType.gymChain));
      expect(store.subscriptionTier, equals(SubscriptionTier.b2bPartner));
      expect(store.subscriptionTier.hasCoachReview, isTrue);

      // WELLNESS (Employer Wellness Programs)
      final wellnessResult = store.redeemPartnerCode('wellness'); // Case-insensitive test
      expect(wellnessResult, isTrue);
      expect(store.activePartnerOrg?.id, equals('vitality_corp'));
      expect(store.activePartnerOrg?.type, equals(PartnerType.employerWellness));

      // GLP1 (Metabolic Telehealth Clinic)
      final glp1Result = store.redeemPartnerCode('GLP1');
      expect(glp1Result, isTrue);
      expect(store.activePartnerOrg?.id, equals('glp1_rx'));
      expect(store.activePartnerOrg?.type, equals(PartnerType.glp1Telehealth));
      expect(store.activePartnerOrg?.tag, contains('GLP-1'));
    });

    test('Subscription tier and partner code persist into SharedPreferences', () async {
      final store1 = Store();
      store1.redeemPartnerCode('EQUINOX');
      await store1.persistAsync();
      expect(store1.subscriptionTier, equals(SubscriptionTier.b2bPartner));
      expect(store1.activePartnerOrg?.id, equals('equinox'));

      // Simulate app restart / new instance loading from mock SharedPreferences
      final store2 = Store();
      await store2.load();
      expect(store2.subscriptionTier, equals(SubscriptionTier.b2bPartner));
      expect(store2.activePartnerOrg?.id, equals('equinox'));
    });
  });
}
