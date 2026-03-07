/// In-memory storage for today's hydration (water intake).
/// No dummy data: values are 0 until the user logs water via the Hydration screen.
/// Dashboard and HydrationScreen read/write here.
class HydrationStorage {
  HydrationStorage._();

  static double _currentLiters = 0;
  static const double _defaultGoalLiters = 2.5;
  static double _goalLiters = _defaultGoalLiters;

  /// Logs of (time, liters) for today. Used for the hourly graph.
  static final List<({DateTime time, double liters})> _todayLogs = [];

  static String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  static String? _lastDayKey;

  /// Clear logs and daily total if we're in a new day.
  static void _ensureTodayLogs() {
    if (_lastDayKey != _todayKey) {
      _lastDayKey = _todayKey;
      _todayLogs.clear();
      _currentLiters = 0;
    }
  }

  /// Today's water intake in liters (0 if none logged).
  static double get currentLiters => _currentLiters;
  static set currentLiters(double value) {
    _currentLiters = value < 0 ? 0 : value;
  }

  /// Daily goal in liters.
  static double get goalLiters => _goalLiters;
  static set goalLiters(double value) {
    _goalLiters = value < 0.1 ? _defaultGoalLiters : value;
  }

  /// Progress as fraction 0..1 (current / goal). 0 if goal is 0.
  static double get progress {
    if (_goalLiters <= 0) return 0;
    final p = _currentLiters / _goalLiters;
    return p > 1 ? 1.0 : p;
  }

  /// Percent 0..100 for display (0 when no intake).
  static int get percentForDisplay {
    if (_goalLiters <= 0) return 0;
    final p = (_currentLiters / _goalLiters * 100).round();
    return p.clamp(0, 100);
  }

  /// Add water in liters (e.g. 0.25 for one cup). Also logs time for the graph.
  static void addLiters(double liters) {
    _ensureTodayLogs();
    _currentLiters += liters;
    if (_currentLiters < 0) _currentLiters = 0;
    _todayLogs.add((time: DateTime.now(), liters: liters));
  }

  /// Hourly liters for today (24 values, index = hour 0–23). For the daily graph.
  static List<double> get hourlyLitersToday {
    _ensureTodayLogs();
    final hours = List<double>.filled(24, 0);
    for (final log in _todayLogs) {
      final h = log.time.hour;
      if (h >= 0 && h < 24) hours[h] += log.liters;
    }
    return hours;
  }

  /// Bar heights 0..1 for the graph (hourly intake / goal, capped at 1).
  static List<double> get hourlyProgressForGraph {
    final hourly = hourlyLitersToday;
    if (_goalLiters <= 0) return hourly.map((_) => 0.0).toList();
    return hourly.map((l) => (l / _goalLiters).clamp(0.0, 1.0)).toList();
  }
}
