/// In-memory storage for daily distance (and steps) so we can show
/// "Performance Over Time" (last 7 days) and "Weekly Distance Goal".
/// Updated from bracelet_screen when type 24/25 is received.
class WeeklyDataStorage {
  WeeklyDataStorage._();

  /// date key "yyyy.MM.dd" or "yyyy-MM-dd" -> distance in km
  static final Map<String, double> _dailyDistanceKm = {};
  static final Map<String, int> _dailySteps = {};
  static const int _maxDays = 14;

  static String _dateKey(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  /// Call when dashboard has new distance for today (from type 24 or 25).
  static void updateTodayDistance(double distanceKm, int steps) {
    final key = _dateKey(DateTime.now());
    _dailyDistanceKm[key] = distanceKm;
    _dailySteps[key] = steps;
    if (_dailyDistanceKm.length > _maxDays) {
      final sorted = _dailyDistanceKm.keys.toList()..sort();
      while (_dailyDistanceKm.length > _maxDays) {
        final k = sorted.removeAt(0);
        _dailyDistanceKm.remove(k);
        _dailySteps.remove(k);
      }
    }
  }

  /// Clear all cached daily distance/steps (used on auth/logout to avoid cross-user leaks).
  static void clear() {
    _dailyDistanceKm.clear();
    _dailySteps.clear();
  }

  /// Restore daily maps from [BraceletMetricsCache] disk payload.
  /// Each value is `{ steps, distanceKm, calories? }`.
  static void hydrateFromDailyEntries(Map<String, Map<String, dynamic>> daily) {
    for (final e in daily.entries) {
      final v = e.value;
      final steps = v['steps'];
      final dist = v['distanceKm'];
      if (steps is num) {
        _dailySteps[e.key] = steps.toInt();
      }
      if (dist is num) {
        _dailyDistanceKm[e.key] = dist.toDouble();
      }
    }
  }

  /// Last 7 days distance (oldest first). [0]=oldest day, [6]=today. Missing days = 0.
  static List<double> get last7DaysDistanceKm {
    final now = DateTime.now();
    final out = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      out.add(_dailyDistanceKm[_dateKey(d)] ?? 0);
    }
    return out;
  }

  /// Last 7 days steps (oldest first).
  static List<int> get last7DaysSteps {
    final now = DateTime.now();
    final out = <int>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      out.add(_dailySteps[_dateKey(d)] ?? 0);
    }
    return out;
  }

  /// Total distance (km) for the last 7 days.
  static double get weeklyTotalDistanceKm =>
      last7DaysDistanceKm.fold(0.0, (a, b) => a + b);

  static const double weeklyDistanceGoalKm = 50.0;

  /// Progress 0..1 toward weekly goal.
  static double get weeklyGoalProgress {
    if (weeklyDistanceGoalKm <= 0) return 0;
    final p = weeklyTotalDistanceKm / weeklyDistanceGoalKm;
    return p > 1 ? 1.0 : p;
  }
}
