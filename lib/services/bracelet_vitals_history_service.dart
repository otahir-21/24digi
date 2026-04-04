import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// One day's worth of vitals + activity read from `bracelet_history/{uid}/daily/{date}`.
class DailyVitals {
  final String dayKey;   // yyyy.MM.dd
  final DateTime date;
  // vitals
  final int? heartRateBpm;
  final int? hrvMs;
  final int? spo2Percent;
  final int? stressIndex;
  final double? temperatureC;
  // activity
  final int? steps;
  final double? distanceKm;
  final double? calories;

  const DailyVitals({
    required this.dayKey,
    required this.date,
    this.heartRateBpm,
    this.hrvMs,
    this.spo2Percent,
    this.stressIndex,
    this.temperatureC,
    this.steps,
    this.distanceKm,
    this.calories,
  });

  factory DailyVitals.fromMap(String docId, Map<String, dynamic> m) {
    final parts = docId.split('.');
    DateTime date;
    try {
      date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      date = DateTime.now();
    }
    return DailyVitals(
      dayKey: docId,
      date: date,
      heartRateBpm: _i(m['heart_rate_bpm']),
      hrvMs:         _i(m['hrv_ms']),
      spo2Percent:  _i(m['spo2_percent']),
      stressIndex:  _i(m['stress_index']),
      temperatureC: _d(m['temperature_c']),
      steps:        _i(m['steps']),
      distanceKm:   _d(m['distance_km']),
      calories:     _d(m['calories']),
    );
  }

  static int? _i(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  static double? _d(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return null;
  }
}

/// Reads historical vitals + activity from Firestore for weekly / monthly charts.
///
/// Data source: `bracelet_history/{uid}/daily/{yyyy.MM.dd}`
/// Written by [BraceletFirestoreSync.writeVitalsToHistory] whenever fresh data arrives.
class BraceletVitalsHistoryService {
  BraceletVitalsHistoryService._();

  static final _db = FirebaseFirestore.instance;

  static String _key(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Returns daily records for the last [days] days (inclusive of today),
  /// sorted oldest → newest.
  ///
  /// Queries by **document ID** (no composite index required).
  static Future<List<DailyVitals>> fetchLast(String uid, {required int days}) async {
    final now   = DateTime.now();
    final start = now.subtract(Duration(days: days - 1));
    final startKey = _key(DateTime(start.year, start.month, start.day));
    final endKey   = _key(DateTime(now.year, now.month, now.day));

    try {
      final snap = await _db
          .collection('bracelet_history')
          .doc(uid)
          .collection('daily')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endKey)
          .get();

      final docs = snap.docs.toList()
        ..sort((a, b) => a.id.compareTo(b.id));   // oldest → newest

      return docs.map((d) => DailyVitals.fromMap(d.id, d.data())).toList();
    } catch (e, st) {
      if (kDebugMode) debugPrint('[VitalsHistory] fetch error: $e $st');
      return [];
    }
  }

  /// Convenience: last 7 days.
  static Future<List<DailyVitals>> fetchWeekly(String uid) =>
      fetchLast(uid, days: 7);

  /// Convenience: last 30 days.
  static Future<List<DailyVitals>> fetchMonthly(String uid) =>
      fetchLast(uid, days: 30);
}
