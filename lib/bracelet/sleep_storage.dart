import 'package:flutter/foundation.dart';

/// In-memory storage for last sleep data from the bracelet (type 27).
/// No dummy data: null until the device sends sleep data.
/// Dashboard and SleepScreen read from here.
class SleepStorage {
  SleepStorage._();

  /// Incremented every time [updateFromMap] stores new data.
  /// SleepScreen (and any other listener) uses this to rebuild reactively.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static Map<String, dynamic>? _lastSleepData;

  /// Per-night history (key = night date `yyyy.MM.dd`) for multi-day review and persistence.
  static final Map<String, Map<String, dynamic>> _sleepByNight = {};

  /// Night key for grouping (aligned with device "evening → that calendar day, morning → previous day").
  /// Uses [startTime] (has the real hour) before [sourceDate] (which is a date-only
  /// DateTime at midnight — hour 0 would otherwise trigger the "morning" branch incorrectly).
  static String? nightKeyFromMap(Map<String, dynamic> map) {
    // Prefer startTime: it carries the actual hour of sleep start.
    // sourceDate is a date-only DateTime(year,month,day) stored at midnight (hour=0);
    // if used for the h <= 12 branch it subtracts a day and produces a wrong night key.
    DateTime? d;
    final st = map['startTime'];
    if (st is DateTime) {
      d = st;
    } else if (st is String) {
      d = DateTime.tryParse(st);
    }

    if (d == null) {
      // Fallback: sourceDate — but treat midnight as "evening of that day" so we
      // don't subtract an extra day from a date-only value.
      final sd = map['sourceDate'];
      if (sd is DateTime) {
        d = sd;
      } else if (sd is String) {
        d = DateTime.tryParse(sd);
      }
      if (d != null && d.hour == 0 && d.minute == 0 && d.second == 0) {
        // Date-only: return that calendar day as the night key directly.
        return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
      }
    }

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
      revision.value++;
      return;
    }
    final keys = _sleepByNight.keys.toList()..sort();
    _lastSleepData = Map<String, dynamic>.from(_sleepByNight[keys.last]!);
    revision.value++;
  }

  /// Update from parsed sleep map (from BraceletDataParser.parseSleepData).
  static void updateFromMap(Map<String, dynamic>? data) {
    if (data == null) {
      _lastSleepData = null;
      revision.value++;
      return;
    }
    final copy = Map<String, dynamic>.from(data);
    _lastSleepData = copy;
    final nk = nightKeyFromMap(copy);
    if (nk != null) {
      _sleepByNight[nk] = copy;
    }
    revision.value++;
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

  /// How many calendar days ago the last sleep night was.
  /// Returns null if no data. 0 = today/tonight, 1 = last night, 2 = two nights ago.
  static int? get nightsAgo {
    if (_lastSleepData == null) return null;
    final nk = nightKeyFromMap(_lastSleepData!);
    if (nk == null) return null;
    try {
      final parts = nk.split('.');
      final nightDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      return todayOnly.difference(nightDate).inDays;
    } catch (_) {
      return null;
    }
  }

  /// True only when [lastSleepData] is from last night or the current night
  /// (within 1 calendar day). Stale data from previous nights is excluded.
  static bool get isFromLastNight {
    final n = nightsAgo;
    return n != null && n <= 1;
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
