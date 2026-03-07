import 'models/live_health_metrics.dart';

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
    dynamic data = dic['Data'] ?? dic['data'] ?? dic['arrayActivityModeData'] ?? dic['arrayActivityMode'];
    if (data is! List || data.isEmpty) return null;
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

  /// Parse ActivityModeData (type 30) and return all sessions for today (date string contains today's date).
  static List<Map<String, dynamic>> parseActivityModeDataTodayList(Map<String, dynamic> dic) {
    dynamic data = dic['Data'] ?? dic['data'] ?? dic['arrayActivityModeData'] ?? dic['arrayActivityMode'];
    if (data is! List || data.isEmpty) return [];
    final today = DateTime.now();
    final todayStr = '${today.year}.${today.month.toString().padLeft(2, '0')}.${today.day.toString().padLeft(2, '0')}';
    final todayStrAlt = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    List<Map<String, dynamic>> sessions = [];
    for (final raw in data) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(
        (raw as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      final dateStr = (m['Date'] ?? m['date'] ?? '').toString();
      if (dateStr.isEmpty) continue;
      final isToday = dateStr.startsWith(todayStr) || dateStr.startsWith(todayStrAlt);
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
      sessions.add({
        'sportName': name,
        'date': dateStr,
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

  /// Parse DetailSleepData (type 27). Tries common SDK key variants.
  /// Returns a map with: totalSleepMinutes, deepMinutes, lightMinutes, remMinutes, awakeMinutes (nullable ints).
  static Map<String, dynamic>? parseSleepData(Map<String, dynamic> dic) {
    final flat = Map<String, dynamic>.from(dic);
    final data = dic['Data'] ?? dic['data'] ?? dic['arrayDetailSleepData'] ?? dic['arraySleepData'];
    if (data is List && data.isNotEmpty) {
      final record = data.last;
      if (record is Map) {
        final map = Map<String, dynamic>.from(
          (record as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        );
        flat.addAll(map);
      }
    } else if (data is Map) {
      for (final e in (data as Map<Object?, Object?>).entries) {
        flat[e.key?.toString() ?? ''] = e.value;
      }
    }
    int? total = intFrom(
      flat['totalSleepTime'] ??
          flat['TotalSleepTime'] ??
          flat['sleepTime'] ??
          flat['SleepTime'] ??
          flat['totalTime'] ??
          flat['TotalTime'] ??
          flat['duration'] ??
          flat['totalSleepMinutes'],
    );
    int? deep = intFrom(
      flat['deepSleepTime'] ??
          flat['DeepSleepTime'] ??
          flat['deepTime'] ??
          flat['deepSleepMinutes'] ??
          flat['deep'],
    );
    int? light = intFrom(
      flat['lightSleepTime'] ??
          flat['LightSleepTime'] ??
          flat['lightTime'] ??
          flat['lightSleepMinutes'] ??
          flat['light'],
    );
    int? rem = intFrom(
      flat['remSleepTime'] ??
          flat['RemSleepTime'] ??
          flat['remTime'] ??
          flat['remSleepMinutes'] ??
          flat['rem'],
    );
    int? awake = intFrom(
      flat['awakeTime'] ??
          flat['AwakeTime'] ??
          flat['wakeTime'] ??
          flat['awakeMinutes'] ??
          flat['awake'],
    );
    // If SDK sends values in seconds (e.g. 3600), convert to minutes
    int? toMinutes(int? v) {
      if (v == null) return null;
      if (v >= 60 && v <= 86400) return v ~/ 60; // likely seconds (1 min to 24 h)
      return v;
    }
    total = toMinutes(total);
    deep = toMinutes(deep);
    light = toMinutes(light);
    rem = toMinutes(rem);
    awake = toMinutes(awake);
    final hasAny = total != null || deep != null || light != null || rem != null || awake != null;
    if (!hasAny) return null;
    return <String, dynamic>{
      'totalSleepMinutes': total,
      'deepMinutes': deep,
      'lightMinutes': light,
      'remMinutes': rem,
      'awakeMinutes': awake,
      'startTime': flat['startTime'] ?? flat['StartTime'] ?? flat['beginTime'],
      'endTime': flat['endTime'] ?? flat['EndTime'] ?? flat['stopTime'],
    };
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
    if (total != null) {
      final realtimeStep = intFrom(firstOf(realtime, ['step', 'Step', 'steps', 'Steps']));
      final totalStep = intFrom(firstOf(total, ['step', 'Step', 'steps', 'Steps']));
      final realtimeDist = toDouble(firstOf(realtime, ['distance', 'Distance', 'mileage']));
      final totalDist = toDouble(firstOf(total, ['distance', 'Distance', 'totalDistance', 'TotalDistance', 'mileage']));
      final realtimeCal = toDouble(firstOf(realtime, ['calories', 'Calories']));
      final totalCal = toDouble(firstOf(total, ['calories', 'Calories']));
      if (realtimeStep == null && totalStep != null) {
        merged['step'] = totalStep;
      } else if (realtimeStep != null && totalStep != null) {
        merged['step'] = realtimeStep > totalStep ? realtimeStep : totalStep;
      } else if (realtimeStep != null) {
        merged['step'] = realtimeStep;
      }
      if (realtimeDist == null && totalDist != null) {
        merged['distance'] = totalDist;
      } else if (realtimeDist != null && totalDist != null) {
        merged['distance'] = realtimeDist > totalDist ? realtimeDist : totalDist;
      } else if (realtimeDist != null) {
        merged['distance'] = realtimeDist;
      }
      if (realtimeCal == null && totalCal != null) {
        merged['calories'] = totalCal;
      } else if (realtimeCal != null && totalCal != null) {
        merged['calories'] = realtimeCal > totalCal ? realtimeCal : totalCal;
      } else if (realtimeCal != null) {
        merged['calories'] = realtimeCal;
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
}
