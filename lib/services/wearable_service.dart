import 'dart:convert';

import 'package:health/health.dart';
import 'package:http/http.dart' as http;
import '../models/health_data.dart';

// On-device pull via `health` plugin (HealthKit on iOS, Health Connect on Android).
// Cloud (Oura/Whoop/Garmin/Fitbit) via Terra — set terraKey via
// --dart-define=TERRA_API_KEY=xxx plus TERRA_DEV_ID; otherwise null → manual.
class WearableService {
  final Health _health = Health();
  String? terraKey;
  String? relayUrl;
  String? terraUserId = const String.fromEnvironment('TERRA_USER_ID',
      defaultValue: '');

  static const _types = [
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  Future<bool> requestAuth() async {
    try {
      final perms = _types.map((t) => HealthDataAccess.READ).toList();
      return await _health.requestAuthorization(_types, permissions: perms);
    } catch (_) {
      return false;
    }
  }

  double _sum(List<HealthDataPoint> pts) {
    var total = 0.0;
    for (final p in pts) {
      if (p.value is NumericHealthValue) {
        final v = (p.value as NumericHealthValue).numericValue.toDouble();
        total += v > 100000 ? 0 : v; // guard junk
      }
    }
    return total;
  }

  // Returns Recovery on success, null when unavailable/denied.
  Future<({Recovery recovery, String source})?> fetchLastNight() async {
    // 1. Self-hosted Terra relay (Oura/Whoop/Garmin/Fitbit via webhook).
    final relay = await _fetchRelay();
    if (relay != null) return relay;
    // 2. Terra cloud direct if key present.
    final terra = await _fetchTerra();
    if (terra != null) return terra;
    // 3. On-device HealthKit / Health Connect.
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final ok = await requestAuth();
      if (!ok) return null;

      final sleepPts = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP],
      );
      var sleepH = 0.0;
      for (final p in sleepPts) {
        if (p.value is NumericHealthValue) {
          final v = (p.value as NumericHealthValue).numericValue.toDouble();
          sleepH += v > 24 ? v / 3600 : v; // seconds→hours guard
        }
      }
      sleepH = sleepH.clamp(0, 12);
      if (sleepH == 0) return null;

      final rhrPts = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.RESTING_HEART_RATE],
      );
      double rhr = 60;
      if (rhrPts.isNotEmpty && rhrPts.last.value is NumericHealthValue) {
        rhr = (rhrPts.last.value as NumericHealthValue)
            .numericValue
            .toDouble()
            .clamp(35, 100);
      }
      final hrvPts = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
      );
      double hrv = 0;
      if (hrvPts.isNotEmpty && hrvPts.last.value is NumericHealthValue) {
        hrv = (hrvPts.last.value as NumericHealthValue)
            .numericValue
            .toDouble()
            .clamp(0, 250);
      }
      final stepsPts = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.STEPS],
      );
      final kcalPts = await _health.getHealthDataFromTypes(
        startTime: yesterday,
        endTime: now,
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      final readiness =
          ((sleepH / 8).clamp(0.0, 1.0) * 70 + ((75 - rhr) / 25).clamp(-1.0, 1.0) * 15 + 20)
              .round()
              .clamp(10, 99);
      return (
        recovery: Recovery(
          sleepHours: sleepH,
          readiness: readiness,
          hrvMs: hrv,
          restingHr: rhr.round(),
          steps: _sum(stepsPts).round(),
          activeKcal: _sum(kcalPts).round(),
        ),
        source: 'healthkit/connect',
      );
    } catch (_) {
      return null;
    }
  }

  // Self-hosted relay (see terra-relay/): GET /recovery/:userId returns
  // normalized {sleepHours,readiness,hrvMs,restingHr,steps,activeKcal}.
  Future<({Recovery recovery, String source})?> _fetchRelay() async {
    final base = relayUrl;
    final uid = terraUserId;
    if (base == null || base.isEmpty || uid == null || uid.isEmpty) {
      return null;
    }
    try {
      final res = await http
          .get(Uri.parse('$base/recovery/$uid'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return _recoveryFromJson(map, 'terra-relay');
    } catch (_) {
      return null;
    }
  }

  ({Recovery recovery, String source})? _recoveryFromJson(
      Map<String, dynamic> j, String source) {
    if (!j.containsKey('sleepHours')) return null;
    return (
      recovery: Recovery.fromJson(j),
      source: '${j['source'] ?? source}',
    );
  }
  // Terra cloud direct. Full OAuth lives in terra-relay/ server-side;
  // Env: TERRA_API_KEY, TERRA_DEV_ID, TERRA_USER_ID.
  Future<({Recovery recovery, String source})?> _fetchTerra() async {
    if (terraKey == null || terraKey!.isEmpty) return null;
    const devId = String.fromEnvironment('TERRA_DEV_ID', defaultValue: '');
    const userId = String.fromEnvironment('TERRA_USER_ID', defaultValue: '');
    if (devId.isEmpty || userId.isEmpty) return null;
    try {
      final res = await http.get(
        Uri.parse('https://api.tryterra.co/v2/sleep?user_id=$userId'),
        headers: {'dev-id': devId, 'x-api-key': terraKey!},
      );
      if (res.statusCode != 200) return null;
      // v1: acknowledge link works; full sleep-score mapping is next.
      // Fall through to on-device so demo keeps working.
      return null;
    } catch (_) {
      return null;
    }
  }
}
