import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bracelet/bracelet_channel.dart';
import '../bracelet/bracelet_metrics_cache.dart';
import '../bracelet/data/bracelet_data_parser.dart';
import '../bracelet/hydration_storage.dart';

/// Writes bracelet snapshots to Firestore at most once every [minInterval].
/// Use [syncFromLocalCache] only (e.g. 15m timer / after login) — not on every live BLE tick.
/// Cooldown is persisted per user so app restarts still respect the window.
class BraceletFirestoreSync {
  BraceletFirestoreSync._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionName = 'bracelet_sync';
  static const Duration minInterval = Duration(minutes: 15);

  static String _lastOkPrefsKey(String uid) => 'bracelet_fs_last_ok_$uid';

  static String _dayKeyNow() {
    final n = DateTime.now();
    return '${n.year}.${n.month.toString().padLeft(2, '0')}.${n.day.toString().padLeft(2, '0')}';
  }

  static Future<bool> _writeCooldownElapsed(String uid) async {
    final p = await SharedPreferences.getInstance();
    final ms = p.getInt(_lastOkPrefsKey(uid));
    if (ms == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(ms);
    return DateTime.now().difference(last) >= minInterval;
  }

  static Future<void> _persistLastOkWrite(String uid) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(
      _lastOkPrefsKey(uid),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static int? _intField(Map<String, dynamic>? m, String k) {
    if (m == null) return null;
    final v = m[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  /// Compact sleep stages for the latest night (Firestore-safe ints only).
  static Map<String, dynamic>? _lastSleepBreakdown(Map<String, dynamic>? night) {
    if (night == null) return null;
    final out = <String, dynamic>{};
    void put(String srcKey, String outKey) {
      final v = _intField(night, srcKey);
      if (v != null) out[outKey] = v;
    }
    put('totalSleepMinutes', 'total_minutes');
    put('deepMinutes', 'deep_minutes');
    put('lightMinutes', 'light_minutes');
    put('remMinutes', 'rem_minutes');
    put('awakeMinutes', 'awake_minutes');
    put('inBedDurationMinutes', 'in_bed_minutes');
    return out.isEmpty ? null : out;
  }

  static Future<bool> _performWrite({
    required String uid,
    required String dayKey,
    required int steps,
    required double distanceKm,
    required double calories,
    String? sleepNightKey,
    int? sleepTotalMinutes,
    Map<String, dynamic>? sleepBreakdown,
    required List<Map<String, dynamic>> activitySessions,
    int? heartRateBpm,
    int? hrvMs,
    int? spo2Percent,
    int? stressIndex,
    double? temperatureC,
    required double hydrationLiters,
    required double hydrationGoalLiters,
  }) async {
    try {
      final doc = <String, dynamic>{
        'uid': uid,
        'day_key': dayKey,
        'steps': steps,
        'distance_km': distanceKm,
        'calories': calories,
        'updated_at': FieldValue.serverTimestamp(),
        // Type-30 sessions synced from local cache (same source as Activities screen).
        'activity_sessions': activitySessions,
        // Logged water today + goal (HydrationStorage).
        'hydration_liters_today': hydrationLiters,
        'hydration_goal_liters': hydrationGoalLiters,
      };
      if (sleepNightKey != null) {
        doc['last_sleep_night_key'] = sleepNightKey;
      }
      if (sleepTotalMinutes != null) {
        doc['last_sleep_total_minutes'] = sleepTotalMinutes;
      }
      if (sleepBreakdown != null && sleepBreakdown.isNotEmpty) {
        doc['last_sleep_breakdown'] = sleepBreakdown;
      }
      if (heartRateBpm != null) doc['heart_rate_bpm'] = heartRateBpm;
      if (hrvMs != null) doc['hrv_ms'] = hrvMs;
      if (spo2Percent != null) doc['spo2_percent'] = spo2Percent;
      if (stressIndex != null) doc['stress_index'] = stressIndex;
      if (temperatureC != null) doc['temperature_c'] = temperatureC;
      await _db.collection(collectionName).doc(uid).set(
            doc,
            SetOptions(merge: true),
          );
      if (kDebugMode) {
        debugPrint(
          '[BraceletFirestoreSync] wrote $collectionName/$uid (15m cooldown)',
        );
      }
      return true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[BraceletFirestoreSync] write failed: $e $st');
      }
      return false;
    }
  }

  /// Push latest values from [BraceletMetricsCache] (15-minute timer or after login).
  ///
  /// Also uploads: today’s **activity_sessions** (from type 30 cache), **last_sleep_breakdown**,
  /// **hydration** totals, and last known **vitals** from [BraceletChannel] (HR, HRV, SpO₂, stress, temp).
  static Future<void> syncFromLocalCache(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    if (!await _writeCooldownElapsed(uid)) return;
    final cache = BraceletMetricsCache.instance;
    final t = cache.todayTotals;
    final sn = cache.lastSleepNightAndMinutes;
    final steps =
        BraceletDataParser.intFrom(t?['step'] ?? t?['Step']) ?? 0;
    final distanceKm =
        BraceletDataParser.toDouble(t?['distance'] ?? t?['Distance']) ?? 0.0;
    final calories =
        BraceletDataParser.toDouble(t?['calories'] ?? t?['Calories']) ?? 0.0;
    final sleepBreakdown = _lastSleepBreakdown(cache.latestSleepNightMap);
    final sessions = cache.activitySessionsForFirestoreSync();
    final ok = await _performWrite(
      uid: uid,
      dayKey: _dayKeyNow(),
      steps: steps,
      distanceKm: distanceKm,
      calories: calories,
      sleepNightKey: sn.$1,
      sleepTotalMinutes: sn.$2,
      sleepBreakdown: sleepBreakdown,
      activitySessions: sessions,
      heartRateBpm: BraceletChannel.lastKnownHeartRate,
      hrvMs: BraceletChannel.lastKnownHrv,
      spo2Percent: BraceletChannel.lastKnownSpo2,
      stressIndex: BraceletChannel.lastKnownStress,
      temperatureC: BraceletChannel.lastKnownTemperature,
      hydrationLiters: HydrationStorage.currentLiters,
      hydrationGoalLiters: HydrationStorage.goalLiters,
    );
    if (ok) await _persistLastOkWrite(uid);
  }
}
