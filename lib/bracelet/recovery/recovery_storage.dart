// Storage for daily recovery snapshots (score + status) for trend charts.
// Persist or keep in-memory; see integration notes in docs.

import 'recovery_score_calculator.dart';

/// One daily recovery snapshot (e.g. computed in the morning from last night's sleep + today's HRV).
class RecoverySnapshot {
  const RecoverySnapshot({
    required this.date,
    required this.score,
    required this.status,
    this.reasons = const [],
    this.recordedAt,
  });

  /// Date this recovery applies to (e.g. "today" when computed in AM).
  final DateTime date;

  final int score;
  final String status;
  final List<String> reasons;
  final DateTime? recordedAt;

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'score': score,
      'status': status,
      'reasons': List<String>.from(reasons),
      'recordedAt': recordedAt?.toIso8601String(),
    };
  }

  static RecoverySnapshot? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final dateStr = map['date'] as String?;
    final score = map['score'] as int?;
    final status = map['status'] as String?;
    if (dateStr == null || score == null || status == null) return null;
    final date = DateTime.tryParse(dateStr);
    if (date == null) return null;
    final reasons = map['reasons'] is List ? (map['reasons'] as List).cast<String>() : <String>[];
    final recordedAt = map['recordedAt'] != null ? DateTime.tryParse(map['recordedAt'] as String) : null;
    return RecoverySnapshot(
      date: date,
      score: score,
      status: status,
      reasons: reasons,
      recordedAt: recordedAt,
    );
  }
}

/// In-memory storage for daily recovery snapshots.
/// Key = date "yyyy.MM.dd". For persistence, write to shared_preferences or local DB.
class RecoveryStorage {
  RecoveryStorage._();

  static final Map<String, RecoverySnapshot> _byDate = {};
  static const int _maxDays = 30;

  static String _dateKey(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Save a snapshot for the given date (overwrites same day).
  static void save(RecoverySnapshot snapshot) {
    final key = _dateKey(snapshot.date);
    _byDate[key] = snapshot;
    if (_byDate.length > _maxDays) {
      final sorted = _byDate.keys.toList()..sort();
      while (_byDate.length > _maxDays) {
        _byDate.remove(sorted.removeAt(0));
      }
    }
  }

  /// Get snapshot for a specific date.
  static RecoverySnapshot? get(DateTime date) => _byDate[_dateKey(date)];

  /// Last 7 days of snapshots (oldest first). Missing days are null.
  static List<RecoverySnapshot?> get last7Days {
    final now = DateTime.now();
    final out = <RecoverySnapshot?>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      out.add(_byDate[_dateKey(d)]);
    }
    return out;
  }

  /// Last 7 days scores only (for charts). Missing = null.
  static List<int?> get last7DaysScores =>
      last7Days.map((s) => s?.score).toList();

  /// Today's snapshot if any.
  static RecoverySnapshot? get today => get(DateTime.now());
}
