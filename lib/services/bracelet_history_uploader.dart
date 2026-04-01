import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bracelet/bracelet_metrics_cache.dart';
import '../bracelet/hydration_storage.dart';

/// Uploads ALL local bracelet history to Firestore, then clears local storage.
///
/// Firestore layout:
///   bracelet_history/{uid}                  ← metadata / summary (for CRM)
///   bracelet_history/{uid}/daily/{date}     ← one doc per calendar day
///
/// Call [backupAndReset] once to migrate local data to Firebase.
/// Old data (> 3 months) is then always read from Firestore, not local cache.
class BraceletHistoryUploader {
  BraceletHistoryUploader._();

  static const String _collection = 'bracelet_history';
  static const String _subCollection = 'daily';

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── public API ───────────────────────────────────────────────────────────

  /// Backs up all local bracelet + hydration data to Firestore, then wipes
  /// local SharedPreferences for bracelet metrics.
  ///
  /// Returns the number of daily records that were uploaded.
  /// Throws on Firestore permission / network errors.
  static Future<int> backupAndReset(String uid) async {
    if (uid.isEmpty) throw ArgumentError('uid must not be empty');

    final cache = BraceletMetricsCache.instance;

    // ── 1. Read everything from the in-memory cache (already loaded from disk)
    final daily = cache.allDailyEntries;          // Map<date, {steps,dist,cal}>
    final sleep = cache.allSleepEntries;          // Map<date, sleepMap>
    final sessions = cache.allActivitySessions;   // List<Map>

    if (kDebugMode) {
      debugPrint('[BraceletHistoryUploader] daily=${daily.length} '
          'sleep=${sleep.length} sessions=${sessions.length}');
    }

    // ── 2. Group activity sessions by date key so we can attach them per day
    final sessionsByDay = <String, List<Map<String, dynamic>>>{};
    for (final s in sessions) {
      final rawDate = s['date']?.toString() ?? '';
      if (rawDate.isNotEmpty) {
        sessionsByDay.putIfAbsent(rawDate, () => []).add(s);
      }
    }

    // ── 3. Batch-write all days to Firestore
    final allDates = <String>{...daily.keys, ...sleep.keys, ...sessionsByDay.keys};
    int uploaded = 0;

    // Firestore batch max = 500 writes; chunk if needed
    const batchSize = 400;
    final dateList = allDates.toList()..sort();

    for (int offset = 0; offset < dateList.length; offset += batchSize) {
      final chunk = dateList.sublist(
        offset,
        (offset + batchSize).clamp(0, dateList.length),
      );
      final batch = _db.batch();

      for (final date in chunk) {
        final dayData = daily[date];
        final sleepData = sleep[date];
        final daySessions = sessionsByDay[date];

        final doc = <String, dynamic>{
          'date': date,
          'backed_up_at': FieldValue.serverTimestamp(),
        };

        if (dayData != null) {
          final steps = dayData['steps'];
          final dist  = dayData['distanceKm'];
          final cal   = dayData['calories'];
          if (steps != null) doc['steps'] = steps is num ? steps.toInt() : 0;
          if (dist  != null) doc['distance_km'] = dist is num ? dist.toDouble() : 0.0;
          if (cal   != null) doc['calories'] = cal is num ? cal.toDouble() : 0.0;
        }

        if (sleepData != null) {
          doc['sleep'] = _sanitiseSleepMap(sleepData);
        }

        if (daySessions != null && daySessions.isNotEmpty) {
          doc['activity_sessions'] =
              daySessions.map(_sanitiseSessionMap).toList();
        }

        final ref = _db
            .collection(_collection)
            .doc(uid)
            .collection(_subCollection)
            .doc(date);
        batch.set(ref, doc, SetOptions(merge: true));
        uploaded++;
      }

      await batch.commit();
    }

    // ── 4. Back up today's hydration
    final hydrationLiters = HydrationStorage.currentLiters;
    final hydrationGoal   = HydrationStorage.goalLiters;
    final hydrationLogs   = HydrationStorage.todayLogsForBackup;

    // ── 5. Write metadata doc (CRM overview)
    await _db.collection(_collection).doc(uid).set(
      <String, dynamic>{
        'uid': uid,
        'last_backup_at': FieldValue.serverTimestamp(),
        'total_days_backed_up': uploaded,
        'hydration_liters_today': hydrationLiters,
        'hydration_goal_liters': hydrationGoal,
        'hydration_logs_today': hydrationLogs
            .map((l) => <String, dynamic>{
                  'ms': l.time.millisecondsSinceEpoch,
                  'liters': l.liters,
                })
            .toList(),
      },
      SetOptions(merge: true),
    );

    if (kDebugMode) {
      debugPrint('[BraceletHistoryUploader] uploaded $uploaded days for uid=$uid');
    }

    // ── 6. Clear local storage AFTER successful upload
    await BraceletMetricsCache.instance.clearAll(uid);
    await HydrationStorage.clearForUser(uid);

    // Reset the Firestore cooldown so the normal sync can run immediately
    final p = await SharedPreferences.getInstance();
    await p.remove('bracelet_fs_last_ok_$uid');

    return uploaded;
  }

  // ── Fetch a date range from Firestore (for reading old data) ─────────────

  /// Returns all daily records between [from] and [to] (inclusive) from
  /// Firestore. Use this to show data older than what is cached locally.
  static Future<List<Map<String, dynamic>>> fetchRange({
    required String uid,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromKey = _dateKey(from);
    final toKey   = _dateKey(to);

    final snap = await _db
        .collection(_collection)
        .doc(uid)
        .collection(_subCollection)
        .where('date', isGreaterThanOrEqualTo: fromKey)
        .where('date', isLessThanOrEqualTo: toKey)
        .orderBy('date')
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  static String _dateKey(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  static Map<String, dynamic> _sanitiseSleepMap(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    for (final e in raw.entries) {
      final v = e.value;
      if (v is DateTime) {
        out[e.key] = v.toIso8601String();
      } else if (v is num || v is String || v is bool || v is List) {
        // skip rawStages (large int list) to keep doc small
        if (e.key != 'rawStages') out[e.key] = v;
      }
    }
    return out;
  }

  static Map<String, dynamic> _sanitiseSessionMap(Map<String, dynamic> raw) {
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

    return <String, dynamic>{
      if (raw['sportName'] != null) 'sport_name': raw['sportName'].toString(),
      if (raw['date'] != null) 'date': raw['date'].toString(),
      if (asInt(raw['activeMinutes']) != null) 'active_minutes': asInt(raw['activeMinutes']),
      if (asInt(raw['step']) != null) 'steps': asInt(raw['step']),
      if (asInt(raw['heartRate']) != null) 'heart_rate': asInt(raw['heartRate']),
      if (raw['pace'] != null && raw['pace'].toString().trim().isNotEmpty)
        'pace': raw['pace'].toString(),
      if (asDouble(raw['distance']) != null) 'distance_raw': asDouble(raw['distance']),
      if (asDouble(raw['calories']) != null) 'calories': asDouble(raw['calories']),
    };
  }
}
