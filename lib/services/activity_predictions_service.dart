import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Saves and retrieves predicted activity sessions to/from Firestore.
///
/// Collection path: `user_activity_predictions/{uid}/sessions/{autoId}`
///
/// Each document represents one activity session (e.g. a 12-minute run).
class ActivityPredictionsService {
  ActivityPredictionsService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _sessions(String uid) =>
      _db
          .collection('user_activity_predictions')
          .doc(uid)
          .collection('sessions');

  // ── Write ───────────────────────────────────────────────────────────────

  /// Save a completed (or in-progress) activity session.
  /// Returns the Firestore document ID, or null on failure.
  static Future<String?> saveSession({
    required String uid,
    required String predictedActivity,
    required double confidenceScore,
    required DateTime startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String source = 'rule_based',
    String? correctedActivity,
    bool wasCorrected = false,
  }) async {
    try {
      final doc = <String, dynamic>{
        'uid': uid,
        'predicted_activity': predictedActivity,
        'confidence_score': confidenceScore,
        'started_at': Timestamp.fromDate(startedAt),
        'source': source,
        'was_corrected': wasCorrected,
        'created_at': FieldValue.serverTimestamp(),
      };
      if (endedAt != null) doc['ended_at'] = Timestamp.fromDate(endedAt);
      if (durationSeconds != null) doc['duration_sec'] = durationSeconds;
      if (correctedActivity != null) {
        doc['corrected_activity'] = correctedActivity;
      }
      final ref = await _sessions(uid).add(doc);
      if (kDebugMode) {
        debugPrint(
          '[ActivityPredictions] saved $predictedActivity '
          '(conf=${confidenceScore.toStringAsFixed(2)}) → ${ref.id}',
        );
      }
      return ref.id;
    } catch (e, st) {
      if (kDebugMode) debugPrint('[ActivityPredictions] save failed: $e $st');
      return null;
    }
  }

  /// Update an existing session document (e.g. mark ended or corrected).
  static Future<void> updateSession({
    required String uid,
    required String sessionId,
    DateTime? endedAt,
    int? durationSeconds,
    String? correctedActivity,
    bool? wasCorrected,
  }) async {
    try {
      final patch = <String, dynamic>{};
      if (endedAt != null) patch['ended_at'] = Timestamp.fromDate(endedAt);
      if (durationSeconds != null) patch['duration_sec'] = durationSeconds;
      if (correctedActivity != null) {
        patch['corrected_activity'] = correctedActivity;
      }
      if (wasCorrected != null) patch['was_corrected'] = wasCorrected;
      if (patch.isEmpty) return;
      await _sessions(uid).doc(sessionId).update(patch);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ActivityPredictions] update failed: $e $st');
      }
    }
  }

  // ── Read ────────────────────────────────────────────────────────────────

  /// Fetch today's activity sessions, newest first.
  static Future<List<ActivitySession>> fetchToday(String uid) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final snap = await _sessions(uid)
          .where(
            'started_at',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .orderBy('started_at', descending: true)
          .limit(50)
          .get();
      return snap.docs
          .map((d) => ActivitySession.fromMap(d.id, d.data()))
          .toList();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ActivityPredictions] fetchToday failed: $e $st');
      }
      return [];
    }
  }
}

/// Data model for a single predicted activity session.
class ActivitySession {
  final String id;
  final String predictedActivity;
  final double confidenceScore;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final bool wasCorrected;
  final String? correctedActivity;
  final String source;

  const ActivitySession({
    required this.id,
    required this.predictedActivity,
    required this.confidenceScore,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    required this.wasCorrected,
    this.correctedActivity,
    required this.source,
  });

  factory ActivitySession.fromMap(String id, Map<String, dynamic> m) {
    DateTime _ts(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    return ActivitySession(
      id: id,
      predictedActivity: m['predicted_activity'] as String? ?? 'unknown',
      confidenceScore: (m['confidence_score'] as num?)?.toDouble() ?? 0.0,
      startedAt: _ts(m['started_at']),
      endedAt: m['ended_at'] != null ? _ts(m['ended_at']) : null,
      durationSeconds: m['duration_sec'] as int?,
      wasCorrected: m['was_corrected'] as bool? ?? false,
      correctedActivity: m['corrected_activity'] as String?,
      source: m['source'] as String? ?? 'rule_based',
    );
  }

  /// Display label, preferring the corrected value if the user fixed it.
  String get displayActivity =>
      wasCorrected && correctedActivity != null
          ? correctedActivity!
          : predictedActivity;

  String get durationLabel {
    final secs = durationSeconds ?? 0;
    if (secs < 60) return '${secs}s';
    final mins = secs ~/ 60;
    if (mins < 60) return '${mins}m';
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }
}
