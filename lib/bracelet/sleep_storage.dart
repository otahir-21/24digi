/// In-memory storage for last sleep data from the bracelet (type 27).
/// No dummy data: null until the device sends sleep data.
/// Dashboard and SleepScreen read from here.
class SleepStorage {
  SleepStorage._();

  static Map<String, dynamic>? _lastSleepData;

  /// Per-night history (key = night date `yyyy.MM.dd`) for multi-day review and persistence.
  static final Map<String, Map<String, dynamic>> _sleepByNight = {};

  /// Night key for grouping (aligned with device "evening → that calendar day, morning → previous day").
  static String? nightKeyFromMap(Map<String, dynamic> map) {
    dynamic sd = map['sourceDate'];
    DateTime? d;
    if (sd is DateTime) {
      d = sd;
    } else if (sd is String) {
      d = DateTime.tryParse(sd);
    }
    d ??= map['startTime'] is DateTime
        ? map['startTime'] as DateTime
        : DateTime.tryParse(map['startTime']?.toString() ?? '');
    if (d == null) return null;
    final h = d.hour;
    if (h >= 18) {
      return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    }
    if (h <= 12) {
      final p = d.subtract(const Duration(days: 1));
      return '${p.year}.${p.month.toString().padLeft(2, '0')}.${p.day.toString().padLeft(2, '0')}';
    }
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }

  /// Restore from disk; picks newest night as [lastSleepData].
  static void hydrateFromPersistentMaps(Map<String, Map<String, dynamic>> byNight) {
    _sleepByNight
      ..clear()
      ..addAll(byNight.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v))));
    if (_sleepByNight.isEmpty) {
      _lastSleepData = null;
      return;
    }
    final keys = _sleepByNight.keys.toList()..sort();
    _lastSleepData = Map<String, dynamic>.from(_sleepByNight[keys.last]!);
  }

  /// Update from parsed sleep map (from BraceletDataParser.parseSleepData).
  static void updateFromMap(Map<String, dynamic>? data) {
    if (data == null) {
      _lastSleepData = null;
      return;
    }
    final copy = Map<String, dynamic>.from(data);
    _lastSleepData = copy;
    final nk = nightKeyFromMap(copy);
    if (nk != null) {
      _sleepByNight[nk] = copy;
    }
  }

  /// Clear all cached sleep data (used on auth/logout to avoid cross-user leaks).
  static void clear() {
    _lastSleepData = null;
    _sleepByNight.clear();
  }

  /// Read-only night → sleep map (newest keys sort last).
  static Map<String, Map<String, dynamic>> get sleepByNight =>
      Map<String, Map<String, dynamic>>.unmodifiable(_sleepByNight);

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
