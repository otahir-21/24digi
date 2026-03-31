import 'package:flutter/foundation.dart';

/// In-memory storage for today's activity sessions from the bracelet (type 30).
/// Activities screen reads todaySessions and listens to versionNotifier to rebuild.
class ActivityStorage {
  ActivityStorage._();

  static List<Map<String, dynamic>> _todaySessions = [];
  static final ValueNotifier<int> versionNotifier = ValueNotifier(0);

  /// Replace today's sessions (from BraceletDataParser.parseActivityModeDataTodayList).
  static void updateSessions(List<Map<String, dynamic>> sessions) {
    _todaySessions = List<Map<String, dynamic>>.from(sessions);
    versionNotifier.value++;
  }

  /// Today's activity sessions (newest first). Do not modify the returned list.
  static List<Map<String, dynamic>> get todaySessions =>
      List<Map<String, dynamic>>.unmodifiable(_todaySessions);

  /// Total calories from today's sessions.
  static double get totalCalories {
    double sum = 0;
    for (final s in _todaySessions) {
      final c = s['calories'];
      if (c is num) sum += c.toDouble();
    }
    return sum;
  }

  /// Sum of steps from type-30 (and fallback) sessions for today — used when daily totals (24/25) are still zero.
  static int get totalSteps {
    var sum = 0;
    for (final s in _todaySessions) {
      final v = s['step'];
      if (v is num) sum += v.toInt();
    }
    return sum;
  }

  /// Sum distance from sessions (km if values look like km, else meters → km).
  static double get totalDistanceKm {
    var sum = 0.0;
    for (final s in _todaySessions) {
      final v = s['distance'];
      if (v is! num) continue;
      var d = v.toDouble();
      if (d > 100) d /= 1000.0;
      sum += d;
    }
    return sum;
  }

  /// Total active minutes from today's sessions.
  static int get totalActiveMinutes {
    int sum = 0;
    for (final s in _todaySessions) {
      final m = s['activeMinutes'];
      if (m is int) sum += m;
      if (m is num) sum += m.toInt();
    }
    return sum;
  }

  /// Clear today's sessions (used on auth/logout to avoid cross-user leaks).
  static void clear() {
    _todaySessions = [];
    versionNotifier.value++;
  }
}
