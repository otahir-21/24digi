import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../main.dart' as app;
import 'heart_screen.dart';
import 'sleep_screen.dart';
import 'blood_pressure_screen.dart';
import 'hrv_screen.dart';
import 'hydration_screen.dart';
import 'spo2_screen.dart';
import 'activities_screen.dart';
import 'progress_screen.dart';
import 'stress_screen.dart';
import 'temperature_screen.dart';
import 'general_recovery_screen.dart';
import 'bracelet_scaffold.dart';
import 'bracelet_components.dart';

// BraceletScreen
// ─────────────────────────────────────────────────────────────────────────────
class BraceletScreen extends StatefulWidget {
  const BraceletScreen({super.key});

  @override
  State<BraceletScreen> createState() => _BraceletScreenState();
}

class _BraceletScreenState extends State<BraceletScreen> with RouteAware {
  int _activeTab = 0;
  final BraceletChannel _channel = BraceletChannel();
  StreamSubscription<BraceletEvent>? _subscription;
  Map<String, dynamic>? _realtimeData;

  /// Today's total from device (dataType 25). Used for steps, distance, calories so they are not 0.
  Map<String, dynamic>? _totalActivityData;

  /// Latest blood pressure from SDK (any type: e.g. ECG result 52, or realtime). Kept separate so we don't lose BP when last packet was type 24.
  int? _bpSystolic;
  int? _bpDiastolic;
  Timer? _totalActivityTimer;
  Timer? _realtimeRefreshTimer;
  bool _routeObserverSubscribed = false;

  @override
  void initState() {
    super.initState();
    _listenRealtime();
    _startRealtimeIfConnected();
    _startRealtimeRefresh();
    _startTotalActivityPolling();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_routeObserverSubscribed) {
      final route = ModalRoute.of(context);
      if (route != null) {
        app.braceletRouteObserver.subscribe(this, route);
        _routeObserverSubscribed = true;
      }
    }
  }

  @override
  void didPopNext() {
    // User came back to this screen (e.g. from Stress/BP). Resume polling.
    _startRealtimeRefresh();
    _startTotalActivityPolling();
    _startRealtimeIfConnected();
  }

  @override
  void didPop() {
    // User left the bracelet section. Pause polling and stop device realtime to save battery.
    _pauseRealtime();
  }

  void _pauseRealtime() {
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = null;
    _totalActivityTimer?.cancel();
    _totalActivityTimer = null;
    try {
      _channel.stopRealtime();
    } catch (_) {}
  }

  /// Request a fresh realtime snapshot periodically so steps/HR/temp update. Single timer for whole app; inner screens receive via same event stream.
  void _startRealtimeRefresh() {
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer.periodic(const Duration(seconds: 5), (
      _,
    ) async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true) {
          await _channel.startRealtime(RealtimeType.stepWithTemp);
        }
      } catch (_) {}
    });
  }

  /// Fallback: poll today's total every 30s in case realtime refresh doesn't return data.
  void _startTotalActivityPolling() {
    _totalActivityTimer?.cancel();
    _totalActivityTimer = Timer.periodic(const Duration(seconds: 30), (
      _,
    ) async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true) {
          await _channel.requestTotalActivityData();
        }
      } catch (_) {}
    });
  }

  void _listenRealtime() {
    _subscription?.cancel();
    _subscription = _channel.events.listen((BraceletEvent e) {
      if (e.event != 'realtimeData' || !mounted) return;
      final dataType = e.data['dataType'];
      final dataEnd = e.data['dataEnd'];
      final dic = e.data['dicData'];

      // DEBUG: print every payload from SDK to see what we get
      debugPrint(
        '[Bracelet SDK] dataType: $dataType, dataEnd: $dataEnd, dicData: $dic',
      );

      if (dic == null || dic is! Map) return;

      final dicMap = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );

      setState(() {
        // dataType 24 = RealTimeStep. 25 = TotalActivityData. 27 = Sleep. 52 = ECG_Success_Result (has BP).
        final type = dataType is int
            ? dataType as int
            : (dataType is num ? (dataType as num).toInt() : null);
        if (type != null && type == 25) {
          _totalActivityData = _parseTotalActivityData(dicMap);
          if (kDebugMode && _totalActivityData != null) {
            debugPrint(
              '[Bracelet SDK] TotalActivityData (25) parsed -> step: ${_totalActivityData!['step'] ?? _totalActivityData!['Step']}, distance: ${_totalActivityData!['distance'] ?? _totalActivityData!['Distance']}, calories: ${_totalActivityData!['calories'] ?? _totalActivityData!['Calories']} (raw keys: ${_totalActivityData!.keys.join(', ')})',
            );
          }
        } else if (type != null && type == 27) {
          debugPrint('[Bracelet SDK] SleepData (27) -> $dicMap');
        } else {
          _realtimeData = dicMap;
          if (type != null && type == 24) {
            debugPrint(
              '[Bracelet SDK] RealTimeStep (24) -> step: ${dicMap['step']}, distance: ${dicMap['distance']}, calories: ${dicMap['calories']}, heartRate: ${dicMap['heartRate']}',
            );
          }
        }
        if (kDebugMode && (type == 52 || type == 70)) {
          debugPrint(
            '[Bracelet SDK] dataType $type (ECG/ppg result) -> keys: ${dicMap.keys.join(', ')}, dicData: $dicMap',
          );
        }
        final bp = _parseBloodPressure(dicMap);
        if (bp != null) {
          _bpSystolic = bp.$1;
          _bpDiastolic = bp.$2;
          if (kDebugMode) {
            debugPrint(
              '[Bracelet SDK] Blood pressure -> systolic: ${bp.$1}, diastolic: ${bp.$2}',
            );
          }
        }
      });
    });
  }

  /// Parse TotalActivityData (type 25): may be single record or list in "Data".
  /// Use the most recent day (last in list); device often sends oldest-first.
  static Map<String, dynamic>? _parseTotalActivityData(
    Map<String, dynamic> dic,
  ) {
    final data = dic['Data'];
    if (data is List && data.isNotEmpty) {
      // Prefer last element (most recent day); fallback to first.
      final record = data.last as dynamic;
      if (record is Map) {
        final map = Map<String, dynamic>.from(
          (record as Map<Object?, Object?>).map(
            (k, v) => MapEntry(k?.toString() ?? '', v),
          ),
        );
        return _normalizeActivityKeys(map);
      }
    }
    if (dic.containsKey('step') ||
        dic.containsKey('Step') ||
        dic.containsKey('date') ||
        dic.containsKey('Date')) {
      return _normalizeActivityKeys(dic);
    }
    return null;
  }

  static Map<String, dynamic> _normalizeActivityKeys(Map<String, dynamic> m) {
    return <String, dynamic>{
      'step': m['step'] ?? m['Step'],
      'distance': m['distance'] ?? m['Distance'],
      'calories': m['calories'] ?? m['Calories'],
      'date': m['date'] ?? m['Date'],
      'exerciseMinutes': m['exerciseMinutes'] ?? m['ExerciseMinutes'],
      'activeMinutes': m['activeMinutes'] ?? m['ActiveMinutes'],
      'goal': m['goal'] ?? m['Goal'],
    };
  }

  Future<void> _startRealtimeIfConnected() async {
    try {
      final state = await _channel.getConnectionState();
      if (state['connected'] == true) {
        await _channel.startRealtime(RealtimeType.stepWithTemp);
      }
    } catch (e, st) {
      debugPrint('[Bracelet SDK] _startRealtimeIfConnected error: $e $st');
    }
  }

  /// Parse systolic/diastolic from SDK map. Supports top-level and nested Data/data (ECG result type 52, ppg result 70).
  static (int, int)? _parseBloodPressure(Map<String, dynamic> m) {
    final flat = _flattenForBp(m);
    int? sys = _intFrom(
      flat['systolic'] ??
          flat['Systolic'] ??
          flat['ECGhighBpValue'] ??
          flat['highBp'] ??
          flat['highBloodPressure'] ??
          flat['HighBloodPressure'],
    );
    int? dia = _intFrom(
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

  static Map<String, dynamic> _flattenForBp(Map<String, dynamic> m) {
    final out = Map<String, dynamic>.from(m);
    final data = m['Data'] ?? m['data'];
    if (data is Map) {
      for (final e in (data as Map<Object?, Object?>).entries) {
        out[e.key?.toString() ?? ''] = e.value;
      }
    }
    return out;
  }

  static int? _intFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return (v as num).toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// Estimate systolic/diastolic from heart rate when device does not send BP (type 24 has no BP). For display only.
  static (int, int) _estimateBpFromHeartRate(int heartRate) {
    final baseSys = 100;
    final baseDia = 65;
    final hrOffset = (heartRate - 65).clamp(-30, 40);
    final sys = (baseSys + hrOffset * 0.6).round().clamp(90, 160);
    final dia = (baseDia + hrOffset * 0.4).round().clamp(55, 100);
    return (sys, dia);
  }

  /// Merge total activity with realtime. Use realtime for live updates; only use total when it has non-null values (so we don't overwrite live data with null).
  /// Also derives stress (0-100) from heart rate when realtime has no Stress from device. Merges latest blood pressure when available.
  Map<String, dynamic>? _mergedLiveData() {
    final total = _totalActivityData;
    final realtime = _realtimeData;
    if (total == null && realtime == null && _bpSystolic == null) return null;
    final merged = <String, dynamic>{};
    if (realtime != null) merged.addAll(realtime);
    if (total != null) {
      final step = total['step'] ?? total['Step'];
      final distance = total['distance'] ?? total['Distance'];
      final calories = total['calories'] ?? total['Calories'];
      if (step != null) merged['step'] = step;
      if (distance != null) merged['distance'] = distance;
      if (calories != null) merged['calories'] = calories;
    }
    if (_bpSystolic != null && _bpDiastolic != null) {
      merged['systolic'] = _bpSystolic;
      merged['diastolic'] = _bpDiastolic;
    } else {
      final hr = merged['heartRate'] ?? merged['HeartRate'];
      if (hr != null) {
        final hrVal = _intFrom(hr);
        if (hrVal != null && hrVal >= 40 && hrVal <= 200) {
          final est = _estimateBpFromHeartRate(hrVal);
          merged['systolic'] = est.$1;
          merged['diastolic'] = est.$2;
        }
      }
    }
    if (merged.containsKey('Stress') == false &&
        merged.containsKey('stress') == false) {
      final hr = merged['heartRate'] ?? merged['HeartRate'];
      if (hr != null) {
        final hrVal = _intFrom(hr);
        if (hrVal != null && hrVal >= 40 && hrVal <= 200) {
          merged['stress'] = _stressFromHeartRate(hrVal);
        }
      }
    }
    return merged;
  }

  static int _stressFromHeartRate(int heartRate) {
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

  @override
  void dispose() {
    if (_routeObserverSubscribed) {
      app.braceletRouteObserver.unsubscribe(this);
    }
    _pauseRealtime();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final s = mq.size.width / AppConstants.figmaW;
    final liveData = _mergedLiveData();

    return BraceletScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hi user ──────────────────────────────────────────
          Center(
            child: Text(
              'HI, USER',
              style: TextStyle(
                fontFamily: 'LemonMilk',
                fontSize: 11 * s,
                fontWeight: FontWeight.w300,
                color: AppColors.labelDim,
                letterSpacing: 2.0,
              ),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Progress card ─────────────────────────────────────
          ProgressCard(
            s: s,
            liveData: liveData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProgressScreen()),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Activity tabs ─────────────────────────────────────
          ActivityTabs(
            s: s,
            activeIndex: _activeTab,
            onTabSelected: (i) => setState(() => _activeTab = i),
          ),
          SizedBox(height: 20 * s),

          // ── Latest Activity label ─────────────────────────────
          Center(
            child: Text(
              'Latest Activity',
              style: AppStyles.reg12(s).copyWith(color: AppColors.labelDim),
            ),
          ),
          SizedBox(height: 12 * s),

          // ── Latest Activity card ──────────────────────────────
          LatestActivityCard(
            s: s,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Recovery Data button ──────────────────────────────
          RecoveryDataButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GeneralRecoveryScreen()),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Health metrics grid ───────────────────────────────
          _HealthGrid(s: s, liveData: liveData, channel: _channel),
          SizedBox(height: 40 * s),
        ],
      ),
    );
  }
}

class _HealthGrid extends StatelessWidget {
  final double s;
  final Map<String, dynamic>? liveData;
  final BraceletChannel channel;

  const _HealthGrid({required this.s, this.liveData, required this.channel});

  @override
  Widget build(BuildContext context) {
    // Current values from SDK
    final hr = liveData?['heartRate'] ?? liveData?['HeartRate'];
    final hrv = liveData?['hrv'] ?? liveData?['HRV'];
    final spo2 =
        liveData?['spo2'] ??
        liveData?['oxygen'] ??
        liveData?['Oxygen'] ??
        liveData?['SPO2'];
    final systolic = liveData?['systolic'] ?? liveData?['Systolic'];
    final diastolic = liveData?['diastolic'] ?? liveData?['Diastolic'];
    final temp = liveData?['temperature'] ?? liveData?['Temperature'];
    final stress = liveData?['stress'] ?? liveData?['Stress'];

    // Formatting for display
    final hrStr = hr != null ? '$hr' : '72';
    final hrvStr = hrv != null ? '$hrv' : '45';
    final spo2Str = spo2 != null ? '$spo2' : '98';
    final bpStr = (systolic != null && diastolic != null)
        ? '$systolic/$diastolic'
        : '120/80';
    final tempStr = temp != null ? (temp as num).toStringAsFixed(1) : '36.5';
    final stressStr = stress != null ? '$stress' : '35';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 14 * s,
      crossAxisSpacing: 14 * s,
      childAspectRatio: 1.1,
      children: [
        HealthMetricCard(
          s: s,
          title: 'SLEEP',
          value: '7h 15m',
          unit: 'Deep',
          trend: '364.6 ~',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SleepScreen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HYDRATION',
          value: '72.5',
          unit: '%',
          trend: '74.1 ~',
          trendColor: Colors.greenAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HydrationScreen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HEART RATE',
          value: hrStr,
          unit: 'BPM',
          trend: '71.7 ~',
          trendColor: Colors.greenAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HeartScreen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HRV',
          value: hrvStr,
          unit: 'MS',
          trend: '35.7 ~',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HrvScreen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'STRESS',
          value: stressStr,
          unit: stress != null && (stress as num) > 50 ? 'HIGH' : 'LOW',
          trend: '63.1 ~',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StressScreen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'SPO2',
          value: spo2Str,
          unit: '%',
          trend: '96.7 ~',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Spo2Screen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'TEMPERATURE',
          value: tempStr,
          unit: '℃',
          trend: '36.2 ~',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TemperatureScreen()),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'BLOOD PRESSURE',
          value: bpStr,
          unit: 'mmHg',
          trend: '126/87 ~',
          trendColor: Colors.greenAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BloodPressureScreen()),
          ),
        ),
      ],
    );
  }
}
