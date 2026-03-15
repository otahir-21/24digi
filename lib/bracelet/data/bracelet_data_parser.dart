import 'package:flutter/foundation.dart';

import 'models/live_health_metrics.dart';
import 'models/sleep_summary.dart';

/// Pure parsing and merge logic for bracelet SDK payloads.
/// Extracted from BraceletScreen; no UI or channel dependency.
class BraceletDataParser {
  BraceletDataParser._();

  static int? dataTypeAsInt(dynamic dataType) {
    if (dataType == null) return null;
    if (dataType is int) return dataType;
    if (dataType is num) return dataType.toInt();
    if (dataType is String) return int.tryParse(dataType);
    return null;
  }

  static int? intFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return (v).toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static dynamic firstOf(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return null;
    for (final k in keys) {
      final v = m[k];
      if (v != null) return v;
    }
    return null;
  }

  /// Parse TotalActivityData (type 25): may be "Data", "arrayTotalActivityData", or flat dic.
  static Map<String, dynamic>? parseTotalActivityData(Map<String, dynamic> dic) {
    final data = dic['Data'] ?? dic['arrayTotalActivityData'];
    if (data is List && data.isNotEmpty) {
      final record = data.last as dynamic;
      if (record is Map) {
        final map = Map<String, dynamic>.from(
          (record as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        );
        return normalizeActivityKeys(map);
      }
    }
    if (dic.containsKey('step') ||
        dic.containsKey('Step') ||
        dic.containsKey('date') ||
        dic.containsKey('Date')) {
      return normalizeActivityKeys(dic);
    }
    return null;
  }

  static Map<String, dynamic> normalizeActivityKeys(Map<String, dynamic> m) {
    final distance =
        m['distance'] ??
        m['Distance'] ??
        m['totalDistance'] ??
        m['TotalDistance'] ??
        m['distanceMeters'] ??
        m['DistanceMeters'] ??
        m['mileage'];
    return <String, dynamic>{
      'step': m['step'] ?? m['Step'],
      'distance': distance,
      'calories': m['calories'] ?? m['Calories'],
      'date': m['date'] ?? m['Date'],
      'exerciseMinutes': m['exerciseMinutes'] ?? m['ExerciseMinutes'],
      'activeMinutes': m['activeMinutes'] ?? m['ActiveMinutes'],
      'goal': m['goal'] ?? m['Goal'],
    };
  }

  static Map<String, dynamic> flattenForBp(Map<String, dynamic> m) {
    final out = Map<String, dynamic>.from(m);
    final data = m['Data'] ?? m['data'];
    if (data is Map) {
      for (final e in (data as Map<Object?, Object?>).entries) {
        out[e.key?.toString() ?? ''] = e.value;
      }
    }
    return out;
  }

  static (int, int)? parseBloodPressure(Map<String, dynamic> m) {
    final flat = flattenForBp(m);
    int? sys = intFrom(
      flat['systolic'] ??
          flat['Systolic'] ??
          flat['ECGhighBpValue'] ??
          flat['highBp'] ??
          flat['highBloodPressure'] ??
          flat['HighBloodPressure'],
    );
    int? dia = intFrom(
      flat['diastolic'] ??
          flat['Diastolic'] ??
          flat['ECGLowBpValue'] ??
          flat['lowBp'] ??
          flat['lowBloodPressure'] ??
          flat['LowBloodPressure'],
    );
    if (sys != null &&
        dia != null &&
        sys >= 60 &&
        sys <= 250 &&
        dia >= 40 &&
        dia <= 150) {
      return (sys, dia);
    }
    return null;
  }

  /// Sport type names for ActivityModeData (type 30), index 0–17 per SDK ACTIVITYMODE_J2208A.
  static const List<String> activityModeNames = [
    'Run', 'Cycling', 'Badminton', 'Football', 'Tennis', 'Yoga', 'Breath', 'Dance',
    'Basketball', 'Walk', 'Workout', 'Cricket', 'Hiking', 'Aerobics', 'Ping Pong', 'Rope Jump', 'Sit Ups', 'Volleyball',
  ];

  /// Parse ActivityModeData (type 30). Returns the latest session (most recent by date) or null.
  /// Expected keys per record: Date, ActivityMode (0–17), HeartRate, ActiveMinutes, Step, Pace, Distance, Calories.
  static Map<String, dynamic>? parseActivityModeDataLatest(Map<String, dynamic> dic) {
    final data = _findActivityModeArray(dic);
    if (data == null || data.isEmpty) return null;
    List<Map<String, dynamic>> sessions = [];
    for (final raw in data) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(
        (raw as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      final mode = intFrom(m['ActivityMode'] ?? m['activityMode'] ?? m['sportModel'] ?? m['sport']);
      final dateStr = m['Date'] ?? m['date'] ?? '';
      final activeMin = intFrom(m['ActiveMinutes'] ?? m['activeMinutes'] ?? m['duration']);
      final step = intFrom(m['Step'] ?? m['step'] ?? m['Steps']);
      final heartRate = intFrom(m['HeartRate'] ?? m['heartRate'] ?? m['HeartRate']);
      final pace = m['Pace'] ?? m['pace'] ?? '';
      final distance = toDouble(m['Distance'] ?? m['distance']);
      final calories = toDouble(m['Calories'] ?? m['calories']);
      final name = (mode != null && mode >= 0 && mode < activityModeNames.length)
          ? activityModeNames[mode]
          : (dateStr.toString().isNotEmpty ? 'Activity' : null);
      if (name == null && dateStr.toString().isEmpty) continue;
      sessions.add({
        'sportName': name ?? 'Activity',
        'date': dateStr.toString(),
        'activeMinutes': activeMin,
        'step': step,
        'heartRate': heartRate,
        'pace': pace is String ? pace : pace?.toString(),
        'distance': distance,
        'calories': calories,
      });
    }
    if (sessions.isEmpty) return null;
    // Sort by date descending and take first (latest)
    sessions.sort((a, b) {
      final da = a['date'] as String? ?? '';
      final db = b['date'] as String? ?? '';
      return db.compareTo(da);
    });
    return sessions.first;
  }

  /// True if [dateStr] (e.g. "2025.03.15 06:30:00", "2025-03-15", "2025/03/15") or timestamp is today.
  static bool _isDateStringToday(String dateStr) {
    if (dateStr.isEmpty) return false;
    final today = DateTime.now();
    // Timestamp (seconds or milliseconds since epoch)
    final numVal = int.tryParse(dateStr.trim());
    if (numVal != null) {
      final sec = numVal > 10000000000 ? numVal ~/ 1000 : numVal;
      final dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
      return dt.year == today.year && dt.month == today.month && dt.day == today.day;
    }
    final todayStrDot = '${today.year}.${today.month.toString().padLeft(2, '0')}.${today.day.toString().padLeft(2, '0')}';
    final todayStrDash = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayStrSlash = '${today.year}/${today.month.toString().padLeft(2, '0')}/${today.day.toString().padLeft(2, '0')}';
    if (dateStr.startsWith(todayStrDot) || dateStr.startsWith(todayStrDash) || dateStr.startsWith(todayStrSlash)) {
      return true;
    }
    final normalized = dateStr.length >= 10 ? dateStr.substring(0, 10).replaceAll('/', '-').replaceAll('.', '-') : '';
    if (normalized.length == 10) {
      final parts = normalized.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null && y == today.year && m == today.month && d == today.day) {
          return true;
        }
      }
    }
    return false;
  }

  /// Find activity-mode array from type 30 dic: try known keys, then any value that is List of Maps with activity-like keys.
  static List<dynamic>? _findActivityModeArray(Map<String, dynamic> dic) {
    final knownKeys = ['Data', 'data', 'arrayActivityModeData', 'arrayActivityMode', 'arrayDetailActivityData', 'arrayDetailActivityMode'];
    for (final k in knownKeys) {
      final v = dic[k];
      if (v is List && v.isNotEmpty) return v;
    }
    for (final entry in dic.entries) {
      final v = entry.value;
      if (v is! List || v.isEmpty) continue;
      final first = v.first;
      if (first is! Map) continue;
      final m = Map<String, dynamic>.from(
        (first as Map<Object?, Object?>).map(
          (key, val) => MapEntry(key?.toString() ?? '', val),
        ),
      );
      final hasActivityKey = m.containsKey('Date') || m.containsKey('date') ||
          m.containsKey('ActivityMode') || m.containsKey('activityMode') ||
          m.containsKey('Step') || m.containsKey('step') || m.containsKey('sportModel') || m.containsKey('sport');
      if (hasActivityKey) return v;
    }
    return null;
  }

  /// Parse ActivityModeData (type 30) and return all sessions for today (date string or timestamp).
  static List<Map<String, dynamic>> parseActivityModeDataTodayList(Map<String, dynamic> dic) {
    final data = _findActivityModeArray(dic);
    if (data == null || data.isEmpty) return [];
    final today = DateTime.now();
    List<Map<String, dynamic>> sessions = [];
    for (final raw in data) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(
        (raw as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      // Date can be string or numeric timestamp (seconds/ms). If missing, treat as today when we have activity fields.
      dynamic dateVal = m['Date'] ?? m['date'] ?? m['startTime'] ?? m['StartTime'] ?? m['time'];
      String dateStr = dateVal?.toString().trim() ?? '';
      bool isToday = false;
      if (dateStr.isEmpty) {
        // No date: include if record looks like activity (mode or step), assume today
        final hasMode = m.containsKey('ActivityMode') || m.containsKey('activityMode') || m.containsKey('sportModel') || m.containsKey('sport');
        final hasStep = m.containsKey('Step') || m.containsKey('step') || m.containsKey('Steps');
        isToday = hasMode || hasStep;
        dateStr = '${today.year}.${today.month.toString().padLeft(2, '0')}.${today.day.toString().padLeft(2, '0')} 00:00:00';
      } else {
        isToday = _isDateStringToday(dateStr);
        if (!isToday && dateVal is num) {
          final sec = dateVal.toDouble() > 10000000000 ? (dateVal.toDouble() / 1000).round() : dateVal.toInt();
          final dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
          isToday = dt.year == today.year && dt.month == today.month && dt.day == today.day;
        }
      }
      if (!isToday) continue;
      final mode = intFrom(m['ActivityMode'] ?? m['activityMode'] ?? m['sportModel'] ?? m['sport']);
      final activeMin = intFrom(m['ActiveMinutes'] ?? m['activeMinutes'] ?? m['duration']);
      final step = intFrom(m['Step'] ?? m['step'] ?? m['Steps']);
      final heartRate = intFrom(m['HeartRate'] ?? m['heartRate'] ?? m['HeartRate']);
      final pace = m['Pace'] ?? m['pace'] ?? '';
      final distance = toDouble(m['Distance'] ?? m['distance']);
      final calories = toDouble(m['Calories'] ?? m['calories']);
      final name = (mode != null && mode >= 0 && mode < activityModeNames.length)
          ? activityModeNames[mode]
          : 'Activity';
      // Normalise date for UI: if numeric timestamp, format as "YYYY.MM.DD HH:mm:ss"
      String displayDate = dateStr;
      if (dateVal is num) {
        final sec = dateVal.toDouble() > 10000000000 ? (dateVal.toDouble() / 1000).round() : dateVal.toInt();
        final dt = DateTime.fromMillisecondsSinceEpoch(sec * 1000);
        displayDate = '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      }
      sessions.add({
        'sportName': name,
        'date': displayDate,
        'activeMinutes': activeMin,
        'step': step,
        'heartRate': heartRate,
        'pace': pace is String ? pace : pace?.toString(),
        'distance': distance,
        'calories': calories,
      });
    }
    sessions.sort((a, b) {
      final da = a['date'] as String? ?? '';
      final db = b['date'] as String? ?? '';
      return db.compareTo(da);
    });
    return sessions;
  }

  static int? extractHrvFromMap(Map<String, dynamic> m) {
    final v =
        m['HRV'] ??
        m['hrv'] ??
        m['Value'] ??
        m['value'] ??
        m['SDNN'] ??
        m['sdnn'] ??
        m['RMSSD'] ??
        m['rmssd'] ??
        m['Hrv'] ??
        m['hrvValue'] ??
        m['hrvTestValue'] ??
        m['hrvResultValue'] ??
        m['hrvResultAvg'];
    return intFrom(v);
  }

  static (int, int) estimateBpFromHeartRate(int heartRate) {
    const baseSys = 100, baseDia = 65;
    final hrOffset = (heartRate - 65).clamp(-30, 40);
    final sys = (baseSys + hrOffset * 0.6).round().clamp(90, 160);
    final dia = (baseDia + hrOffset * 0.4).round().clamp(55, 100);
    return (sys, dia);
  }

  /// Stable key for deduplication: startTime_SleepData, totalSleepTime, sleepUnitLength, arraySleepQuality contents.
  static String _sleepRecordKey(Map<String, dynamic> map) {
    final start = map['startTime_SleepData']?.toString() ??
        map['startTime']?.toString() ??
        map['StartTime']?.toString() ??
        '';
    final total = map['totalSleepTime'] ?? map['TotalSleepTime'];
    final unit = map['sleepUnitLength'] ?? map['SleepUnitLength'];
    final quality = map['arraySleepQuality'] ?? map['arraySleepquality'] ?? map['ArraySleepQuality'];
    String qualityStr = '';
    if (quality is List) {
      qualityStr = quality.map((e) => e?.toString() ?? '').join(',');
    }
    return '$start|$total|$unit|$qualityStr';
  }

  /// Parse DetailSleepData (type 27) with dedup. Returns (chosen session, deduped record count).
  /// Deduplicates by _sleepRecordKey, then merges same-day (gap <= 45 min), then picks latest-date first, longest valid.
  static (SleepSummary?, int) parseSleepDataWithDedup(Map<String, dynamic> dic) {
    final raw = dic['arrayDetailSleepData'] ?? dic['Data'] ?? dic['data'] ?? dic['arraySleepData'];
    final List<Map<String, dynamic>> rawMaps = [];

    if (raw is List && raw.isNotEmpty) {
      for (final item in raw) {
        if (item is! Map) continue;
        rawMaps.add(Map<String, dynamic>.from(
          (item as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        ));
      }
    } else if (dic.containsKey('totalSleepTime') || dic.containsKey('startTime_SleepData') || dic.containsKey('arraySleepQuality')) {
      rawMaps.add(Map<String, dynamic>.from(dic));
    }
    if (rawMaps.isEmpty) return (null, 0);

    final seen = <String>{};
    final deduped = <Map<String, dynamic>>[];
    for (final map in rawMaps) {
      final key = _sleepRecordKey(map);
      if (seen.add(key)) deduped.add(map);
    }

    final List<SleepSummary> records = [];
    for (final map in deduped) {
      final summary = _parseOneSleepRecord(map);
      if (summary != null) records.add(summary);
    }
    if (records.isEmpty) return (null, deduped.length);

    final valid = _filterValidFragments(records);
    final sessionsWithCount = _mergeIntoNightlySessions(valid);
    if (sessionsWithCount.isEmpty) return (null, deduped.length);
    final chosen = _selectBestMergedSession(sessionsWithCount);

    if (kDebugMode) {
      final totalSleep = chosen.totalSleepMinutes ?? 0;
      final inBed = chosen.inBedDurationMinutes ?? 0;
      final dateStr = chosen.startTime != null
          ? '${chosen.startTime!.year}-${chosen.startTime!.month.toString().padLeft(2, '0')}-${chosen.startTime!.day.toString().padLeft(2, '0')}'
          : '?';
      debugPrint(
        '[Sleep 27] chosen latestDate=$dateStr totalSleep=$totalSleep inBedDuration=$inBed start=${chosen.startTime} end=${chosen.endTime}',
      );
      final d = chosen.deepMinutes ?? 0;
      final l = chosen.lightMinutes ?? 0;
      final r = chosen.remMinutes ?? 0;
      final a = chosen.awakeMinutes ?? 0;
      final inBedFromTimestamps = chosen.startTime != null && chosen.endTime != null
          ? chosen.endTime!.difference(chosen.startTime!).inMinutes
          : null;
      debugPrint(
        '[Sleep SDK26] start=${chosen.startTime} end=${chosen.endTime} unit=${chosen.sleepUnitLengthMinutes} samples=- '
        'deep=$d light=$l rem=$r awake=$a totalSleep=$totalSleep inBed=$inBedFromTimestamps',
      );
    }
    return (chosen, deduped.length);
  }

  /// Parse DetailSleepData (type 27). Returns chosen merged session or null. Uses dedup internally.
  static SleepSummary? parseSleepData(Map<String, dynamic> dic) {
    return parseSleepDataWithDedup(dic).$1;
  }

  /// Ignore very short (< 15 min) and non-wear-dominated fragments.
  static List<SleepSummary> _filterValidFragments(List<SleepSummary> records) {
    return records
        .where((r) => (r.totalSleepMinutes ?? 0) >= 15 && r.isReliable)
        .toList();
  }

  static bool _sameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// "Night" date for grouping: evening (18–24) → that day; early morning (0–12) → previous day.
  /// So 23:00 Mar 14 and 03:00 Mar 15 both map to night of Mar 14 and get merged.
  static DateTime? _nightDate(DateTime? start) {
    if (start == null) return null;
    final h = start.hour;
    if (h >= 18) return DateTime(start.year, start.month, start.day);
    if (h <= 12) {
      final prev = start.subtract(const Duration(days: 1));
      return DateTime(prev.year, prev.month, prev.day);
    }
    return DateTime(start.year, start.month, start.day);
  }

  /// Sort by startTime ascending. Merge consecutive records when they belong to the same "night"
  /// (even across midnight) and gap <= 90 minutes, so one night 23:00–07:30 becomes one session.
  static List<(SleepSummary, int)> _mergeIntoNightlySessions(List<SleepSummary> records) {
    if (records.isEmpty) return [];
    final sorted = List<SleepSummary>.from(records)
      ..sort((a, b) {
        final at = a.startTime ?? DateTime(0);
        final bt = b.startTime ?? DateTime(0);
        return at.compareTo(bt);
      });

    const maxGapMinutes = 90;
    final List<List<SleepSummary>> sessions = [];
    List<SleepSummary> current = [sorted.first];

    for (int i = 1; i < sorted.length; i++) {
      final prev = current.last;
      final next = sorted[i];
      final prevNight = _nightDate(current.first.startTime);
      final nextNight = _nightDate(next.startTime);
      final prevEnd = prev.endTime ?? prev.startTime;
      final nextStart = next.startTime;
      final sameNight = prevNight != null && nextNight != null &&
          prevNight.year == nextNight.year &&
          prevNight.month == nextNight.month &&
          prevNight.day == nextNight.day;
      if (prevEnd != null && nextStart != null && sameNight) {
        final gap = nextStart.difference(prevEnd).inMinutes;
        if (gap <= maxGapMinutes) {
          current.add(next);
          continue;
        }
      }
      sessions.add(List<SleepSummary>.from(current));
      current = [next];
    }
    sessions.add(current);

    return sessions.map((list) => (_buildMergedSummary(list), list.length)).toList();
  }

  /// One merged session: sum fragment deep/light/rem/awake; totalSleep = deep+light+rem; inBed from endTime−startTime.
  static SleepSummary _buildMergedSummary(List<SleepSummary> list) {
    if (list.isEmpty) {
      return const SleepSummary(isReliable: false);
    }
    if (list.length == 1) {
      final r = list.first;
      final inBed = r.inBedDurationMinutes ?? (r.startTime != null && r.endTime != null
          ? r.endTime!.difference(r.startTime!).inMinutes
          : null);
      final total = r.totalSleepMinutes ?? 0;
      final oversize = total > 720 || (inBed != null && inBed > 840);
      return SleepSummary(
        startTime: r.startTime,
        endTime: r.endTime,
        totalSleepMinutes: r.totalSleepMinutes,
        inBedDurationMinutes: inBed,
        sleepUnitLengthMinutes: r.sleepUnitLengthMinutes,
        deepMinutes: r.deepMinutes,
        lightMinutes: r.lightMinutes,
        remMinutes: r.remMinutes,
        awakeMinutes: r.awakeMinutes,
        rawStages: r.rawStages,
        sourceDate: r.sourceDate,
        isReliable: r.isReliable && !oversize,
        hasNonWearSignals: r.hasNonWearSignals,
      );
    }
    final first = list.first;
    final last = list.last;
    int deep = 0, light = 0, rem = 0, awake = 0;
    for (final r in list) {
      deep += r.deepMinutes ?? 0;
      light += r.lightMinutes ?? 0;
      rem += r.remMinutes ?? 0;
      awake += r.awakeMinutes ?? 0;
    }
    final totalSleepMinutes = deep + light + rem;
    final inBedStart = first.startTime;
    final inBedEnd = last.endTime;
    final inBedDuration = inBedStart != null && inBedEnd != null
        ? inBedEnd.difference(inBedStart).inMinutes
        : null;
    final sourceDate = inBedStart != null
        ? DateTime(inBedStart.year, inBedStart.month, inBedStart.day)
        : first.sourceDate;
    final oversize = totalSleepMinutes > 720 || (inBedDuration != null && inBedDuration > 840);
    return SleepSummary(
      startTime: inBedStart,
      endTime: inBedEnd,
      totalSleepMinutes: totalSleepMinutes,
      inBedDurationMinutes: inBedDuration,
      sleepUnitLengthMinutes: first.sleepUnitLengthMinutes,
      deepMinutes: deep,
      lightMinutes: light,
      remMinutes: rem,
      awakeMinutes: awake,
      rawStages: null,
      sourceDate: sourceDate,
      isReliable: !oversize,
      hasNonWearSignals: false,
    );
  }

  /// Session date from startTime for grouping (year-month-day only).
  static DateTime? _sessionDate(SleepSummary s) {
    final t = s.startTime ?? s.sourceDate;
    if (t == null) return null;
    return DateTime(t.year, t.month, t.day);
  }

  /// Prefer latest night first; on that night pick the valid session with largest totalSleepMinutes. Do not choose invalid/oversized.
  /// Uses _nightDate so sessions spanning midnight (e.g. 23:00–07:30) are grouped as one night.
  static SleepSummary _selectBestMergedSession(List<(SleepSummary, int)> sessionsWithCount) {
    if (sessionsWithCount.isEmpty) return const SleepSummary(isReliable: false);
    final sessions = sessionsWithCount.map((e) => e.$1).toList();
    final valid = sessions.where((s) => s.isReliable).toList();
    if (valid.isEmpty) return sessions.first;

    if (kDebugMode) {
      for (var i = 0; i < sessionsWithCount.length; i++) {
        final s = sessionsWithCount[i].$1;
        final fragmentCount = sessionsWithCount[i].$2;
        final dateStr = s.startTime != null
            ? '${s.startTime!.year}-${s.startTime!.month.toString().padLeft(2, '0')}-${s.startTime!.day.toString().padLeft(2, '0')}'
            : '?';
        debugPrint(
          '[Sleep 27 Merge] candidate date=$dateStr start=${s.startTime} end=${s.endTime} totalSleep=${s.totalSleepMinutes} inBed=${s.inBedDurationMinutes} '
          'merged=${fragmentCount > 1} valid=${s.isReliable}',
        );
      }
    }

    // Group by night date (evening = that day, early morning = previous day) so one night is one bucket.
    final byNight = <DateTime, List<SleepSummary>>{};
    for (final s in valid) {
      final d = _nightDate(s.startTime) ?? _sessionDate(s);
      if (d != null) {
        byNight.putIfAbsent(d, () => []).add(s);
      }
    }
    final nightsDesc = byNight.keys.toList()..sort((a, b) => b.compareTo(a));
    if (nightsDesc.isEmpty) return valid.first;

    for (final night in nightsDesc) {
      final onNight = byNight[night]!;
      onNight.sort((a, b) => (b.totalSleepMinutes ?? 0).compareTo(a.totalSleepMinutes ?? 0));
      return onNight.first;
    }
    return valid.first;
  }

  /// SDK sleep stage classification: unit 1 → 1=deep, 2=light, 3=REM, else=awake; unit 5 → 0..2=deep, >2..8=light, >8..20=REM, else=awake (value/5).
  static void _classifySleepSample(int unitMinutes, int rawValue, {required void Function() deep, required void Function() light, required void Function() rem, required void Function() awake}) {
    if (unitMinutes == 1) {
      switch (rawValue) {
        case 1:
          deep();
          return;
        case 2:
          light();
          return;
        case 3:
          rem();
          return;
        default:
          awake();
          return;
      }
    }
    // unit 5: SDK doc "arraySleepQuality中每一个数据除以5" then 0..2 deep, >2..8 light, >8..20 rem, else awake
    final effective = rawValue / 5.0;
    if (effective >= 0 && effective <= 2) {
      deep();
    } else if (effective > 2 && effective <= 8) {
      light();
    } else if (effective > 8 && effective <= 20) {
      rem();
    } else {
      awake();
    }
  }

  /// Parse one element of arrayDetailSleepData. SDK: do not skip first element; inBed = samples*unit; totalSleep = deep+light+rem.
  static SleepSummary? _parseOneSleepRecord(Map<String, dynamic> map) {
    final unitMinutes = intFrom(map['sleepUnitLength'] ?? map['SleepUnitLength']) ?? 1;
    final startStr = map['startTime_SleepData']?.toString() ??
        map['startTime']?.toString() ??
        map['StartTime']?.toString() ??
        map['date']?.toString() ??
        map['Date']?.toString();
    final startTime = _parseSleepDateTime(startStr);
    if (startTime == null) return null;

    final rawQuality = map['arraySleepQuality'] ?? map['arraySleepquality'] ?? map['ArraySleepQuality'];
    final List<int> codes = [];
    if (rawQuality is List && rawQuality.isNotEmpty) {
      for (final e in rawQuality) {
        final c = intFrom(e);
        if (c != null) codes.add(c);
      }
    } else if (rawQuality != null) {
      final s = rawQuality.toString().trim();
      if (s.isNotEmpty) {
        for (final part in s.split(RegExp(r'\s+'))) {
          final c = int.tryParse(part);
          if (c != null) codes.add(c);
        }
      }
    }
    if (codes.isEmpty) return null;

    // All samples count; do NOT skip first element (SDK: arraySleepQuality values are real sleep samples).
    int deepCount = 0, lightCount = 0, remCount = 0, awakeCount = 0;
    for (final rawValue in codes) {
      _classifySleepSample(unitMinutes, rawValue,
        deep: () => deepCount++,
        light: () => lightCount++,
        rem: () => remCount++,
        awake: () => awakeCount++,
      );
    }

    final deepMinutes = deepCount * unitMinutes;
    final lightMinutes = lightCount * unitMinutes;
    final remMinutes = remCount * unitMinutes;
    final awakeMinutes = awakeCount * unitMinutes;
    final totalSleepMinutes = deepMinutes + lightMinutes + remMinutes;

    final samples = codes.length;
    final inBedDurationMinutes = samples * unitMinutes;
    final endTime = startTime.add(Duration(minutes: inBedDurationMinutes));
    final sourceDate = DateTime(startTime.year, startTime.month, startTime.day);

    const veryShortThreshold = 15;
    final isReliable = totalSleepMinutes >= veryShortThreshold;

    if (kDebugMode) {
      debugPrint(
        '[Sleep SDK26] start=$startTime end=$endTime unit=$unitMinutes samples=$samples '
        'deep=$deepMinutes light=$lightMinutes rem=$remMinutes awake=$awakeMinutes totalSleep=$totalSleepMinutes inBed=$inBedDurationMinutes',
      );
    }

    return SleepSummary(
      startTime: startTime,
      endTime: endTime,
      totalSleepMinutes: totalSleepMinutes,
      inBedDurationMinutes: inBedDurationMinutes,
      sleepUnitLengthMinutes: unitMinutes,
      deepMinutes: deepMinutes,
      lightMinutes: lightMinutes,
      remMinutes: remMinutes,
      awakeMinutes: awakeMinutes,
      rawStages: codes.isEmpty ? null : codes,
      sourceDate: sourceDate,
      isReliable: isReliable,
      hasNonWearSignals: false,
    );
  }

  static DateTime? _parseSleepDateTime(String? s) {
    if (s == null || s.isEmpty) return null;
    s = s.trim();
    // "2026.03.03 23:52:01" or "2026-03-03 23:52:01"
    final normalized = s.replaceAll('.', '-');
    final dt = DateTime.tryParse(normalized);
    if (dt != null) return dt;
    final parts = s.split(RegExp(r'[\s\-\.]+'));
    if (parts.length >= 5) {
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      final h = int.tryParse(parts[3]);
      final min = int.tryParse(parts[4]);
      final sec = parts.length >= 6 ? int.tryParse(parts[5]) ?? 0 : 0;
      if (y != null && m != null && d != null && h != null && min != null) {
        return DateTime(y, m, d, h, min, sec);
      }
    }
    return null;
  }

  /// True when start time is in an overnight-like window: evening (18:00–23:59) or early morning (00:00–10:00).
  static bool _isOvernightLike(DateTime? start) {
    if (start == null) return false;
    final h = start.hour;
    return h >= 18 || h <= 10;
  }

  static int stressFromHeartRate(int heartRate) {
    const restLow = 55, restHigh = 75, high = 120;
    if (heartRate <= restLow) {
      return (20 * heartRate / restLow).round().clamp(0, 100);
    }
    if (heartRate <= restHigh) {
      return (20 + 30 * (heartRate - restLow) / (restHigh - restLow))
          .round()
          .clamp(0, 100);
    }
    if (heartRate <= high) {
      return (50 + 50 * (heartRate - restHigh) / (high - restHigh))
          .round()
          .clamp(0, 100);
    }
    return 100;
  }

  /// Merge realtime (type 24) + total (type 25) + BP. Same logic as former _mergedLiveData.
  /// Returns null when there is nothing to show.
  static LiveHealthMetrics? mergeLiveData(
    Map<String, dynamic>? realtime,
    Map<String, dynamic>? total,
    int? bpSystolic,
    int? bpDiastolic,
  ) {
    if (total == null && realtime == null && bpSystolic == null) return null;

    final merged = <String, dynamic>{};
    if (realtime != null) merged.addAll(realtime);
    // Step/distance/calories: prefer realtime (type 24) when present so dashboard feels live like the activity screen.
    // Use total (type 25) only as fallback when realtime has no value (e.g. before first type-24 or when not in an activity).
    if (total != null) {
      final realtimeStep = intFrom(firstOf(realtime, ['step', 'Step', 'steps', 'Steps']));
      final totalStep = intFrom(firstOf(total, ['step', 'Step', 'steps', 'Steps']));
      final realtimeDist = toDouble(firstOf(realtime, ['distance', 'Distance', 'mileage']));
      final totalDist = toDouble(firstOf(total, ['distance', 'Distance', 'totalDistance', 'TotalDistance', 'mileage']));
      final realtimeCal = toDouble(firstOf(realtime, ['calories', 'Calories']));
      final totalCal = toDouble(firstOf(total, ['calories', 'Calories']));
      if (realtimeStep != null) {
        merged['step'] = realtimeStep;
      } else if (totalStep != null) {
        merged['step'] = totalStep;
      }
      if (realtimeDist != null) {
        merged['distance'] = realtimeDist;
      } else if (totalDist != null) {
        merged['distance'] = totalDist;
      }
      if (realtimeCal != null) {
        merged['calories'] = realtimeCal;
      } else if (totalCal != null) {
        merged['calories'] = totalCal;
      }
    }

    final hr = firstOf(merged, ['heartRate', 'HeartRate', 'hr', 'HR', 'heart_rate']);
    if (hr != null) {
      merged['heartRate'] = hr;
    }
    final hrv = firstOf(merged, ['hrv', 'HRV', 'Hrv', 'hrvValue', 'hrvResultValue']);
    if (hrv != null) {
      merged['hrv'] = hrv;
    }
    final spo2 = firstOf(merged, ['blood_oxygen', 'Blood_oxygen', 'spo2', 'SPO2', 'Spo2', 'oxygen', 'Oxygen']);
    if (spo2 != null) {
      merged['spo2'] = spo2;
    }
    final temp = firstOf(merged, ['temperature', 'Temperature', 'temp', 'Temp']);
    if (temp != null) {
      merged['temperature'] = temp;
    }
    final stress = firstOf(merged, ['stress', 'Stress']);
    if (stress != null) {
      merged['stress'] = stress;
    }

    int? systolic = bpSystolic;
    int? diastolic = bpDiastolic;
    if (systolic == null || diastolic == null) {
      if (hr != null) {
        final hrVal = intFrom(hr);
        if (hrVal != null && hrVal >= 40 && hrVal <= 200) {
          final est = estimateBpFromHeartRate(hrVal);
          systolic = est.$1;
          diastolic = est.$2;
        }
      }
    }

    int? stressVal = intFrom(stress);
    if (stressVal == null && hr != null) {
      final hrVal = intFrom(hr);
      if (hrVal != null && hrVal >= 40 && hrVal <= 200) {
        stressVal = stressFromHeartRate(hrVal);
      }
    }

    return LiveHealthMetrics(
      step: intFrom(merged['step']),
      distance: toDouble(merged['distance']),
      calories: toDouble(merged['calories']),
      heartRate: intFrom(hr ?? merged['heartRate']),
      temperature: toDouble(merged['temperature']),
      hrv: intFrom(merged['hrv']),
      stress: stressVal,
      spo2: toDouble(merged['spo2'])?.round(),
      systolic: systolic,
      diastolic: diastolic,
      lastUpdated: null,
    );
  }

  /// Extract SpO2 from realtime payload.
  /// iOS J2208A: dataType 42 = AutomaticSpo2Data (arrayAutomaticSpo2Data), 43 = ManualSpo2Data, 57 = DeviceMeasurement_Spo2 (live).
  /// Value may be at top-level, under Data/data, or in first element of arrayAutomaticSpo2Data / arrayManualSpo2Data. Returns 0–100 or null.
  static int? extractSpo2FromDicData(Map<String, dynamic> dicData) {
    const keys = ['blood_oxygen', 'Blood_oxygen', 'spo2', 'SPO2', 'Spo2', 'oxygen', 'Oxygen'];
    final top = firstOf(dicData, keys);
    if (top != null) {
      final v = intFrom(top);
      if (v != null && v >= 0 && v <= 100) return v;
    }
    final data = dicData['Data'] ?? dicData['data'];
    if (data is Map) {
      final inner = Map<String, dynamic>.from(
        (data as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      final fromData = firstOf(inner, keys);
      if (fromData != null) {
        final v = intFrom(fromData);
        if (v != null && v >= 0 && v <= 100) return v;
      }
    }
    // Type 42: arrayAutomaticSpo2Data = [ { automaticSpo2Data: 97, date: "2026.03.15 13:02:00" }, ... ] — use first (most recent) value.
    final autoList = dicData['arrayAutomaticSpo2Data'] ?? dicData['ArrayAutomaticSpo2Data'];
    if (autoList is List && autoList.isNotEmpty) {
      final first = autoList.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(
          (first as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        );
        final val = intFrom(map['automaticSpo2Data'] ?? map['AutomaticSpo2Data']);
        if (val != null && val > 0 && val <= 100) return val;
      }
    }
    // Type 43: arrayManualSpo2Data = [ { manualSpo2Data: 98, date: "..." }, ... ]
    final manualList = dicData['arrayManualSpo2Data'] ?? dicData['ArrayManualSpo2Data'];
    if (manualList is List && manualList.isNotEmpty) {
      final first = manualList.first;
      if (first is Map) {
        final map = Map<String, dynamic>.from(
          (first as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        );
        final val = intFrom(map['manualSpo2Data'] ?? map['ManualSpo2Data']);
        if (val != null && val > 0 && val <= 100) return val;
      }
    }
    return null;
  }
}
