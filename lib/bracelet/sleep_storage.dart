/// In-memory storage for last sleep data from the bracelet (type 27).
/// No dummy data: null until the device sends sleep data.
/// Dashboard and SleepScreen read from here.
class SleepStorage {
  SleepStorage._();

  static Map<String, dynamic>? _lastSleepData;

  /// Update from parsed sleep map (from BraceletDataParser.parseSleepData).
  static void updateFromMap(Map<String, dynamic>? data) {
    _lastSleepData = data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Clear all cached sleep data (used on auth/logout to avoid cross-user leaks).
  static void clear() {
    _lastSleepData = null;
  }

  /// Last parsed sleep data (totalSleepMinutes, deepMinutes, lightMinutes, remMinutes, awakeMinutes).
  static Map<String, dynamic>? get lastSleepData => _lastSleepData != null
      ? Map<String, dynamic>.from(_lastSleepData!)
      : null;

  /// Total sleep in minutes, or null if no data.
  static int? get totalSleepMinutes {
    final v = _lastSleepData?['totalSleepMinutes'];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  /// Display string for dashboard, e.g. "7h 20m" or null when no data.
  static String? get displayString {
    final min = totalSleepMinutes;
    if (min == null || min <= 0) return null;
    final h = min ~/ 60;
    final m = min % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}
