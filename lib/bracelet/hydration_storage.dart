import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Today's water intake + goal. Persisted per user so hot restart / app relaunch keeps logged liters.
class HydrationStorage {
  HydrationStorage._();

  static const String _keyPrefix = 'hydration_v1_';
  static const double _defaultGoalLiters = 2.5;

  static double _currentLiters = 0;
  static double _goalLiters = _defaultGoalLiters;
  static final List<({DateTime time, double liters})> _todayLogs = [];

  static String? _persistUid;

  /// Bumps when liters/goal change or after [load] — use with [ListenableBuilder] on the dashboard tile.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static void _bumpRevision() {
    revision.value = revision.value + 1;
  }

  static String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  static String? _lastDayKey;

  /// Clear logs and daily total if we're in a new day (in-session midnight rollover).
  static void _ensureTodayLogs() {
    if (_lastDayKey != _todayKey) {
      _lastDayKey = _todayKey;
      _todayLogs.clear();
      _currentLiters = 0;
    }
  }

  static double get currentLiters => _currentLiters;

  static set currentLiters(double value) {
    _ensureTodayLogs();
    _currentLiters = value < 0 ? 0 : value;
    unawaited(persist());
    _bumpRevision();
  }

  static double get goalLiters => _goalLiters;

  static set goalLiters(double value) {
    _goalLiters = value < 0.1 ? _defaultGoalLiters : value;
    unawaited(persist());
    _bumpRevision();
  }

  static double get progress {
    if (_goalLiters <= 0) return 0;
    final p = _currentLiters / _goalLiters;
    return p > 1 ? 1.0 : p;
  }

  static int get percentForDisplay {
    if (_goalLiters <= 0) return 0;
    final p = (_currentLiters / _goalLiters * 100).round();
    return p.clamp(0, 100);
  }

  static void addLiters(double liters) {
    _ensureTodayLogs();
    _currentLiters += liters;
    if (_currentLiters < 0) _currentLiters = 0;
    _todayLogs.add((time: DateTime.now(), liters: liters));
    unawaited(persist());
    _bumpRevision();
  }

  static List<double> get hourlyLitersToday {
    _ensureTodayLogs();
    final hours = List<double>.filled(24, 0);
    for (final log in _todayLogs) {
      final h = log.time.hour;
      if (h >= 0 && h < 24) hours[h] += log.liters;
    }
    return hours;
  }

  static List<double> get hourlyProgressForGraph {
    final hourly = hourlyLitersToday;
    if (_goalLiters <= 0) return hourly.map((_) => 0.0).toList();
    return hourly.map((l) => (l / _goalLiters).clamp(0.0, 1.0)).toList();
  }

  /// Restore from disk for [uid]. Call after login (same time as bracelet metrics cache).
  static Future<void> load(String? uid) async {
    if (uid == null || uid.isEmpty) {
      _persistUid = null;
      return;
    }

    _currentLiters = 0;
    _todayLogs.clear();
    _lastDayKey = null;
    _goalLiters = _defaultGoalLiters;
    _persistUid = uid;

    final p = await SharedPreferences.getInstance();
    final raw = p.getString('$_keyPrefix$uid');
    final today = _todayKey;

    if (raw == null || raw.isEmpty) {
      _lastDayKey = today;
      _bumpRevision();
      return;
    }

    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final savedDay = j['day'] as String?;
      final gl = j['goalLiters'];
      if (gl is num) {
        final g = gl.toDouble();
        if (g >= 0.5 && g <= 10.0) _goalLiters = g;
      }

      if (savedDay != today) {
        _lastDayKey = today;
        _currentLiters = 0;
        _todayLogs.clear();
        await persist();
        _bumpRevision();
        return;
      }

      _lastDayKey = today;
      _currentLiters = (j['currentLiters'] as num?)?.toDouble() ?? 0;
      if (_currentLiters < 0) _currentLiters = 0;

      final logs = j['logs'];
      if (logs is List) {
        for (final e in logs) {
          if (e is! Map) continue;
          final mv = Map<String, dynamic>.from(
            e.map((k, v) => MapEntry(k.toString(), v)),
          );
          final ms = mv['ms'];
          final lit = mv['liters'];
          if (ms == null || lit == null) continue;
          final msInt = ms is num ? ms.toInt() : int.tryParse(ms.toString());
          if (msInt == null) continue;
          final l = lit is num ? lit.toDouble() : double.tryParse(lit.toString()) ?? 0;
          if (l > 0) {
            _todayLogs.add((
              time: DateTime.fromMillisecondsSinceEpoch(msInt),
              liters: l,
            ));
          }
        }
      }
      _bumpRevision();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[HydrationStorage] load failed: $e $st');
      }
      _lastDayKey = today;
      _bumpRevision();
    }
  }

  static Future<void> persist() async {
    final u = _persistUid;
    if (u == null || u.isEmpty) return;
    _ensureTodayLogs();
    try {
      final p = await SharedPreferences.getInstance();
      final logs = _todayLogs
          .map((e) => <String, dynamic>{
                'ms': e.time.millisecondsSinceEpoch,
                'liters': e.liters,
              })
          .toList();
      await p.setString(
        '$_keyPrefix$u',
        jsonEncode(<String, dynamic>{
          'day': _todayKey,
          'currentLiters': _currentLiters,
          'goalLiters': _goalLiters,
          'logs': logs,
        }),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HydrationStorage] persist failed: $e');
      }
    }
  }

  /// All of today's log entries — used by backup before clearing.
  static List<({DateTime time, double liters})> get todayLogsForBackup =>
      List.unmodifiable(_todayLogs);

  /// Clear local storage for a specific uid (used after backup to Firebase).
  static Future<void> clearForUser(String uid) async {
    if (_persistUid == uid) {
      _currentLiters = 0;
      _goalLiters = _defaultGoalLiters;
      _todayLogs.clear();
      _lastDayKey = null;
      _persistUid = null;
      _bumpRevision();
    }
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove('$_keyPrefix$uid');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HydrationStorage] clearForUser failed: $e');
      }
    }
  }

  /// Clear memory and delete saved file for the current persist user (logout).
  static Future<void> clear() async {
    final u = _persistUid;
    _currentLiters = 0;
    _goalLiters = _defaultGoalLiters;
    _todayLogs.clear();
    _lastDayKey = null;
    _persistUid = null;
    _bumpRevision();
    if (u != null && u.isNotEmpty) {
      try {
        final p = await SharedPreferences.getInstance();
        await p.remove('$_keyPrefix$u');
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[HydrationStorage] clear prefs failed: $e');
        }
      }
    }
  }
}
