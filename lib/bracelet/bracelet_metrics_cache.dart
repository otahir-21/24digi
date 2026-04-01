import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'activity_storage.dart';
import 'sleep_storage.dart';
import 'weekly_data_storage.dart';

/// Local persistence for bracelet totals, sleep, and activity sessions.
/// Survives BLE drops, app restarts, and leaving the bracelet section (unlike pure RAM stores).
class BraceletMetricsCache {
  BraceletMetricsCache._();
  static final BraceletMetricsCache instance = BraceletMetricsCache._();

  static const String _keyPrefix = 'bracelet_metrics_v1_';
  static const Duration _minDiskWriteGap = Duration(seconds: 45);

  String? _uid;

  /// Last [load] uid; used for throttled Firestore writes.
  String? get currentUid => _uid;

  final Map<String, Map<String, dynamic>> _daily = {};
  final Map<String, Map<String, dynamic>> _sleepByNight = {};
  List<Map<String, dynamic>> _activitySessions = [];
  DateTime? _lastDiskWrite;

  String _dateKey(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Today's cached step / distance / calories for offline UI (after disconnect).
  Map<String, dynamic>? get todayTotals {
    final key = _dateKey(DateTime.now());
    final e = _daily[key];
    if (e == null) return null;
    final steps = e['steps'];
    final dist = e['distanceKm'];
    final cal = e['calories'];
    if (steps == null && dist == null && cal == null) return null;
    return <String, dynamic>{
      if (steps != null) 'step': steps,
      if (dist != null) 'distance': dist,
      if (cal != null) 'calories': cal,
    };
  }

  Future<void> load(String? uid) async {
    if (uid == null || uid.isEmpty) {
      _uid = null;
      _daily.clear();
      _sleepByNight.clear();
      _activitySessions = [];
      return;
    }
    _uid = uid;
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('$_keyPrefix$uid');
    if (raw == null || raw.isEmpty) {
      _daily.clear();
      _sleepByNight.clear();
      _activitySessions = [];
      return;
    }
    // Pathological / corrupted prefs can stress jsonDecode; keep a sane upper bound.
    if (raw.length > 6 * 1024 * 1024) {
      if (kDebugMode) {
        debugPrint('[BraceletMetricsCache] load skipped: payload too large (${raw.length} bytes)');
      }
      _daily.clear();
      _sleepByNight.clear();
      _activitySessions = [];
      return;
    }
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      _daily.clear();
      final dailyRaw = j['daily'];
      if (dailyRaw is Map) {
        for (final e in dailyRaw.entries) {
          final v = e.value;
          if (v is Map) {
            _daily[e.key.toString()] = Map<String, dynamic>.from(
              v.map((k, val) => MapEntry(k.toString(), val)),
            );
          }
        }
      }
      _sleepByNight.clear();
      final sleepRaw = j['sleepByNight'];
      if (sleepRaw is Map) {
        for (final e in sleepRaw.entries) {
          final v = e.value;
          if (v is Map) {
            _sleepByNight[e.key.toString()] = _decodeSleepMap(
              Map<String, dynamic>.from(
                v.map((k, val) => MapEntry(k.toString(), val)),
              ),
            );
          }
        }
      }
      _activitySessions = [];
      final actRaw = j['activitySessions'];
      if (actRaw is List) {
        for (final item in actRaw) {
          if (item is Map) {
            _activitySessions.add(
              Map<String, dynamic>.from(
                item.map((k, v) => MapEntry(k.toString(), v)),
              ),
            );
          }
        }
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[BraceletMetricsCache] load failed: $e $st');
      }
      _daily.clear();
      _sleepByNight.clear();
      _activitySessions = [];
    }
  }

  /// Push disk state into [WeeklyDataStorage], [SleepStorage], [ActivityStorage].
  void applyToMemoryStores() {
    WeeklyDataStorage.hydrateFromDailyEntries(_daily);
    SleepStorage.hydrateFromPersistentMaps(_sleepByNight);
    if (_activitySessions.isNotEmpty) {
      ActivityStorage.updateSessions(_activitySessions);
    }
  }

  void recordTodayTotals({
    required int steps,
    required double distanceKm,
    required double calories,
  }) {
    final key = _dateKey(DateTime.now());
    _daily[key] = <String, dynamic>{
      'steps': steps,
      'distanceKm': distanceKm,
      'calories': calories,
    };
    WeeklyDataStorage.updateTodayDistance(distanceKm, steps);
  }

  void recordSleepNight(String nightKey, Map<String, dynamic> sleepMap) {
    _sleepByNight[nightKey] = Map<String, dynamic>.from(sleepMap);
  }

  void recordActivitySessions(List<Map<String, dynamic>> sessions) {
    _activitySessions = List<Map<String, dynamic>>.from(sessions);
  }

  Future<void> scheduleFlushToDisk() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    final now = DateTime.now();
    if (_lastDiskWrite != null &&
        now.difference(_lastDiskWrite!) < _minDiskWriteGap) {
      return;
    }
    _lastDiskWrite = now;
    await _save(uid);
  }

  Future<void> flushNowForUser(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    await _save(uid);
  }

  Future<void> _save(String uid) async {
    try {
      final p = await SharedPreferences.getInstance();
      final dailyJson = <String, dynamic>{};
      for (final e in _daily.entries) {
        dailyJson[e.key] = e.value;
      }
      final sleepJson = <String, dynamic>{};
      for (final e in _sleepByNight.entries) {
        sleepJson[e.key] = _encodeSleepMapForJson(e.value);
      }
      final actList = _activitySessions.map(_encodeActivityMapForJson).toList();
      final payload = jsonEncode(<String, dynamic>{
        'daily': dailyJson,
        'sleepByNight': sleepJson,
        'activitySessions': actList,
      });
      await p.setString('$_keyPrefix$uid', payload);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[BraceletMetricsCache] save failed: $e $st');
      }
    }
  }

  Map<String, dynamic> _encodeSleepMapForJson(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    for (final e in m.entries) {
      final v = e.value;
      if (v is DateTime) {
        out[e.key] = v.toIso8601String();
      } else if (v is List && e.key == 'rawStages') {
        out[e.key] = v;
      } else {
        out[e.key] = v;
      }
    }
    return out;
  }

  Map<String, dynamic> _encodeActivityMapForJson(Map<String, dynamic> m) {
    final out = <String, dynamic>{};
    for (final e in m.entries) {
      out[e.key] = e.value;
    }
    return out;
  }

  Map<String, dynamic> _decodeSleepMap(Map<String, dynamic> raw) {
    final out = Map<String, dynamic>.from(raw);
    for (final k in ['startTime', 'endTime', 'sourceDate']) {
      final v = out[k];
      if (v is String) {
        final d = DateTime.tryParse(v);
        if (d != null) out[k] = d;
      }
    }
    return out;
  }

  /// Last wall-clock day (`yyyy.MM.dd`) we successfully applied sleep from the band (prefs).
  static Future<String?> lastSleepWallFetchDay(String? uid) async {
    if (uid == null || uid.isEmpty) return null;
    final p = await SharedPreferences.getInstance();
    return p.getString('bracelet_sleep_wall_day_$uid');
  }

  /// Call after a sleep payload is merged so we do not re-request on every resume the same day.
  static Future<void> markSleepFetchedWallDay(String? uid) async {
    if (uid == null || uid.isEmpty) return;
    final p = await SharedPreferences.getInstance();
    final n = DateTime.now();
    final day =
        '${n.year}.${n.month.toString().padLeft(2, '0')}.${n.day.toString().padLeft(2, '0')}';
    await p.setString('bracelet_sleep_wall_day_$uid', day);
  }

  /// True when we have not yet stored sleep for today’s calendar date (new day → refresh).
  static Future<bool> needsSleepFetchForNewWallDay(String? uid) async {
    if (uid == null || uid.isEmpty) return false;
    final last = await lastSleepWallFetchDay(uid);
    final today = _staticDateKey(DateTime.now());
    return last != today;
  }

  static String _staticDateKey(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Calories per day for the last 7 days (oldest first) from local daily map.
  List<double> get last7DaysCalories {
    final now = DateTime.now();
    final out = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final c = _daily[_dateKey(d)]?['calories'];
      out.add(c is num ? c.toDouble() : 0.0);
    }
    return out;
  }

  /// Steps per day for the last 7 days (oldest first), for hydration / activity charts.
  List<double> get last7DaysSteps {
    final now = DateTime.now();
    final out = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final s = _daily[_dateKey(d)]?['steps'];
      out.add(s is num ? s.toDouble() : 0.0);
    }
    return out;
  }

  List<double> _lastNDaysField(String field, int n) {
    final now = DateTime.now();
    final out = <double>[];
    for (int i = n - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final v = _daily[_dateKey(d)]?[field];
      out.add(v is num ? v.toDouble() : 0.0);
    }
    return out;
  }

  static List<double> _bucketSum7(List<double> flat) {
    final bars = <double>[];
    for (int i = 0; i < 7; i++) {
      double s = 0;
      for (int j = 0; j < 4; j++) {
        final idx = i * 4 + j;
        if (idx < flat.length) s += flat[idx];
      }
      bars.add(s);
    }
    return bars;
  }

  /// ~4-day buckets over the last 28 days (7 bars) for monthly chart.
  List<double> get monthlyStepBars7 =>
      _bucketSum7(_lastNDaysField('steps', 28));
  List<double> get monthlyDistanceBars7 =>
      _bucketSum7(_lastNDaysField('distanceKm', 28));
  List<double> get monthlyCaloriesBars7 =>
      _bucketSum7(_lastNDaysField('calories', 28));

  /// Latest sleep night key and flat minutes for Firestore (optional).
  (String?, int?) get lastSleepNightAndMinutes {
    if (_sleepByNight.isEmpty) return (null, null);
    final keys = _sleepByNight.keys.toList()..sort();
    final lastKey = keys.last;
    final m = _sleepByNight[lastKey];
    final min = m?['totalSleepMinutes'];
    int? total;
    if (min is int) total = min;
    if (min is num) total = min.toInt();
    return (lastKey, total);
  }

  /// Most recent night sleep map (read-only copy), or null.
  Map<String, dynamic>? get latestSleepNightMap {
    if (_sleepByNight.isEmpty) return null;
    final keys = _sleepByNight.keys.toList()..sort();
    final m = _sleepByNight[keys.last];
    if (m == null) return null;
    return Map<String, dynamic>.from(m);
  }

  // ── Full-history accessors (used by BraceletHistoryUploader) ─────────────

  /// All daily entries (date key → {steps, distanceKm, calories}).
  Map<String, Map<String, dynamic>> get allDailyEntries =>
      Map.unmodifiable(_daily);

  /// All sleep-by-night entries (night key → sleep map).
  Map<String, Map<String, dynamic>> get allSleepEntries =>
      Map.unmodifiable(_sleepByNight);

  /// All activity sessions stored locally.
  List<Map<String, dynamic>> get allActivitySessions =>
      List.unmodifiable(_activitySessions);

  /// Wipe all bracelet metrics from SharedPreferences and in-memory for [uid].
  /// Call only after a successful Firebase backup.
  Future<void> clearAll(String uid) async {
    _daily.clear();
    _sleepByNight.clear();
    _activitySessions = [];
    _lastDiskWrite = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove('$_keyPrefix$uid');
      await p.remove('bracelet_sleep_wall_day_$uid');
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[BraceletMetricsCache] clearAll failed: $e $st');
      }
    }
  }

  /// Today’s sport sessions from disk, capped for Firestore (primitives only).
  List<Map<String, dynamic>> activitySessionsForFirestoreSync({int maxSessions = 25}) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final out = <Map<String, dynamic>>[];
    for (final raw in _activitySessions.take(maxSessions)) {
      final m = <String, dynamic>{
        if (raw['sportName'] != null) 'sport_name': raw['sportName'].toString(),
        if (raw['date'] != null) 'date': raw['date'].toString(),
        if (asInt(raw['activeMinutes']) != null)
          'active_minutes': asInt(raw['activeMinutes']),
        if (asInt(raw['step']) != null) 'steps': asInt(raw['step']),
        if (asInt(raw['heartRate']) != null) 'heart_rate': asInt(raw['heartRate']),
        if (raw['pace'] != null && raw['pace'].toString().trim().isNotEmpty)
          'pace': raw['pace'].toString(),
        if (asDouble(raw['distance']) != null) 'distance_raw': asDouble(raw['distance']),
        if (asDouble(raw['calories']) != null) 'calories': asDouble(raw['calories']),
      };
      if (m.length > 2) out.add(m);
    }
    return out;
  }
}
