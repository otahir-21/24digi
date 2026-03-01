import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_constants.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../widgets/digi_background.dart';
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

  static const _tabs = ['All', 'Walking', 'Running', 'Cycling', 'Workout'];
  static const _tabIcons = [
    Icons.grid_view_rounded,
    Icons.directions_walk_rounded,
    Icons.directions_run_rounded,
    Icons.directions_bike_rounded,
    Icons.fitness_center_rounded,
  ];

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
    _realtimeRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
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
    _totalActivityTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
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
      debugPrint('[Bracelet SDK] dataType: $dataType, dataEnd: $dataEnd, dicData: $dic');

      if (dic == null || dic is! Map) return;

      final dicMap = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map((k, v) => MapEntry(k?.toString() ?? '', v)),
      );

      setState(() {
        // dataType 24 = RealTimeStep. 25 = TotalActivityData. 27 = Sleep. 52 = ECG_Success_Result (has BP).
        final type = dataType is int ? dataType as int : (dataType is num ? (dataType as num).toInt() : null);
        if (type != null && type == 25) {
          _totalActivityData = _parseTotalActivityData(dicMap);
          if (kDebugMode && _totalActivityData != null) {
            debugPrint('[Bracelet SDK] TotalActivityData (25) parsed -> step: ${_totalActivityData!['step'] ?? _totalActivityData!['Step']}, distance: ${_totalActivityData!['distance'] ?? _totalActivityData!['Distance']}, calories: ${_totalActivityData!['calories'] ?? _totalActivityData!['Calories']} (raw keys: ${_totalActivityData!.keys.join(', ')})');
          }
        } else if (type != null && type == 27) {
          debugPrint('[Bracelet SDK] SleepData (27) -> $dicMap');
        } else {
          _realtimeData = dicMap;
          if (type != null && type == 24) {
            debugPrint('[Bracelet SDK] RealTimeStep (24) -> step: ${dicMap['step']}, distance: ${dicMap['distance']}, calories: ${dicMap['calories']}, heartRate: ${dicMap['heartRate']}');
          }
        }
        if (kDebugMode && (type == 52 || type == 70)) {
          debugPrint('[Bracelet SDK] dataType $type (ECG/ppg result) -> keys: ${dicMap.keys.join(', ')}, dicData: $dicMap');
        }
        final bp = _parseBloodPressure(dicMap);
        if (bp != null) {
          _bpSystolic = bp.$1;
          _bpDiastolic = bp.$2;
          if (kDebugMode) debugPrint('[Bracelet SDK] Blood pressure -> systolic: ${bp.$1}, diastolic: ${bp.$2}');
        }
      });
    });
  }

  /// Parse TotalActivityData (type 25): may be single record or list in "Data".
  /// Use the most recent day (last in list); device often sends oldest-first.
  static Map<String, dynamic>? _parseTotalActivityData(Map<String, dynamic> dic) {
    final data = dic['Data'];
    if (data is List && data.isNotEmpty) {
      // Prefer last element (most recent day); fallback to first.
      final record = data.last as dynamic;
      if (record is Map) {
        final map = Map<String, dynamic>.from(
          (record as Map<Object?, Object?>).map((k, v) => MapEntry(k?.toString() ?? '', v)),
        );
        return _normalizeActivityKeys(map);
      }
    }
    if (dic.containsKey('step') || dic.containsKey('Step') || dic.containsKey('date') || dic.containsKey('Date')) {
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
    int? sys = _intFrom(flat['systolic'] ?? flat['Systolic'] ?? flat['ECGhighBpValue'] ?? flat['highBp'] ?? flat['highBloodPressure'] ?? flat['HighBloodPressure']);
    int? dia = _intFrom(flat['diastolic'] ?? flat['Diastolic'] ?? flat['ECGLowBpValue'] ?? flat['lowBp'] ?? flat['lowBloodPressure'] ?? flat['LowBloodPressure']);
    if (sys != null && dia != null && sys >= 60 && sys <= 250 && dia >= 40 && dia <= 150) return (sys, dia);
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
    if (merged.containsKey('Stress') == false && merged.containsKey('stress') == false) {
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
    if (heartRate <= restLow) return (20 * heartRate / restLow).round().clamp(0, 100);
    if (heartRate <= restHigh) return (20 + 30 * (heartRate - restLow) / (restHigh - restLow)).round().clamp(0, 100);
    if (heartRate <= high) return (50 + 50 * (heartRate - restHigh) / (high - restHigh)).round().clamp(0, 100);
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
    final hPad = 16.0 * s;
    final cw = mq.size.width - hPad * 2;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: DigiBackground(
        logoOpacity: 0,
        showCircuit: false,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding:
                EdgeInsets.symmetric(horizontal: hPad, vertical: 14 * s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ──────────────────────────────────────────
                _TopBar(s: s),
                SizedBox(height: 6 * s),

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
                SizedBox(height: 16 * s),

                // ── Progress card ─────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgressScreen()),
                  ),
                  child: _BorderCard(
                    s: s,
                    width: cw,
                    child: _ProgressCard(s: s, liveData: _mergedLiveData()),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Activity tabs ─────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final active = i == _activeTab;
                      return GestureDetector(
                        onTap: () => setState(() => _activeTab = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: 8 * s),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * s,
                            vertical: 8 * s,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24 * s),
                            color: active
                                ? AppColors.cyanTint18
                                : const Color(0xFF0A1820),
                            border: Border.all(
                              color: active
                                  ? AppColors.cyan
                                  : const Color(0xFF1E3040),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tabIcons[i],
                                size: 14 * s,
                                color: active
                                    ? AppColors.cyan
                                    : AppColors.labelDim,
                              ),
                              SizedBox(width: 5 * s),
                              Text(
                                _tabs[i],
                                style: GoogleFonts.inter(
                                  fontSize: 11 * s,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: active
                                      ? AppColors.cyan
                                      : AppColors.labelDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 12 * s),

                // ── Latest Activity label ─────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ActivitiesScreen()),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Latest Activity',
                        style: GoogleFonts.inter(
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w400,
                          color: AppColors.labelDim,
                        ),
                      ),
                      Text(
                        'View All >',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8 * s),

                // ── Activity card ─────────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ActivitiesScreen()),
                  ),
                  child: _BorderCard(
                    s: s,
                    width: cw,
                    child: _ActivityCard(s: s),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Recovery Data button ──────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GeneralRecoveryScreen()),
                  ),
                  child: _BorderCard(
                    s: s,
                    width: cw,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 18 * s, vertical: 14 * s),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recovery Data',
                            style: TextStyle(
                              fontFamily: 'LemonMilk',
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: AppColors.cyan, size: 20 * s),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14 * s),

                // ── Health metrics 2×4 grid ───────────────────────────
                _HealthGrid(s: s, cw: cw, liveData: _mergedLiveData(), channel: _channel),
                SizedBox(height: 20 * s),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient-border card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _BorderCard extends StatelessWidget {
  final double s;
  final double width;
  final Widget child;
  const _BorderCard(
      {required this.s, required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 16 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar (pill with back arrow + logo + avatar)
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final double s;
  const _TopBar({required this.s});

  @override
  Widget build(BuildContext context) {
    final pillH = 60.0 * s;
    final radius = pillH / 2;
    return CustomPaint(
      painter: SmoothGradientBorder(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: const Color(0xFF060E16),
          child: SizedBox(
            height: pillH,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18 * s),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.cyan, size: 20 * s),
                  ),
                  const Spacer(),
                  Image.asset('assets/24 logo.png',
                      height: 40 * s, fit: BoxFit.contain),
                  const Spacer(),
                  CustomPaint(
                    painter: SmoothGradientBorder(radius: 22 * s),
                    child: ClipOval(
                      child: SizedBox(
                        width: 42 * s,
                        height: 42 * s,
                        child: Image.asset('assets/fonts/male.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress card (concentric rings + stat rows) — uses live bracelet data when present
// ─────────────────────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final double s;
  final Map<String, dynamic>? liveData;

  const _ProgressCard({required this.s, this.liveData});

  static const _goalCalories = 800.0;
  static const _goalSteps = 10000.0;
  static const _goalDistanceKm = 8.0;

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final calories = _toDouble(liveData?['calories']);
    final steps = _toInt(liveData?['step']);
    final distance = _toDouble(liveData?['distance']);

    final calVal = calories?.toInt() ?? 0;
    final stepVal = steps ?? 0;
    final distVal = distance ?? 0.0;

    final calProgress = (calories != null ? (calories / _goalCalories).clamp(0.0, 1.0) : 0.55) as double;
    final stepsProgress = (steps != null ? (steps / _goalSteps).clamp(0.0, 1.0) : 0.70) as double;
    final distProgress = (distance != null ? (distance / _goalDistanceKm).clamp(0.0, 1.0) : 0.40) as double;

    final calStr = liveData != null ? '$calVal' : '-1';
    final stepStr = liveData != null ? _formatInt(stepVal) : '-1';
    final distStr = liveData != null ? (distance ?? 0.0).toStringAsFixed(2) : '-1';

    return Padding(
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 15 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.cyan, size: 20 * s),
            ],
          ),
          SizedBox(height: 14 * s),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatRow(
                      s: s,
                      color: const Color(0xFFE53935),
                      icon: Icons.local_fire_department_rounded,
                      label: 'CALORIES (Kcal)',
                      value: calStr,
                      sub: liveData != null ? '$calVal / ${_goalCalories.toInt()}' : '-1 / -1',
                    ),
                    SizedBox(height: 12 * s),
                    _StatRow(
                      s: s,
                      color: AppColors.cyan,
                      icon: Icons.directions_walk_rounded,
                      label: 'STEPS',
                      value: stepStr,
                      sub: liveData != null ? '${_formatInt(stepVal)} / -1' : '-1 / -1',
                    ),
                    SizedBox(height: 12 * s),
                    _StatRow(
                      s: s,
                      color: const Color(0xFF00C853),
                      icon: Icons.straighten_rounded,
                      label: 'DISTANCE (km)',
                      value: distStr,
                      sub: liveData != null ? '${distance?.toStringAsFixed(2) ?? '0'} / $_goalDistanceKm' : '-1 / -1',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12 * s),
              SizedBox(
                width: 110 * s,
                height: 110 * s,
                child: CustomPaint(
                  painter: _RingsPainter(
                    caloriesProgress: calProgress,
                    stepsProgress: stepsProgress,
                    distanceProgress: distProgress,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatInt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _StatRow extends StatelessWidget {
  final double s;
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  const _StatRow({
    required this.s,
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14 * s),
        SizedBox(width: 6 * s),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8 * s,
                color: AppColors.labelDim,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              sub,
              style: GoogleFonts.inter(
                fontSize: 8 * s,
                color: AppColors.labelDimmer,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Concentric progress-rings painter
// ─────────────────────────────────────────────────────────────────────────────
class _RingsPainter extends CustomPainter {
  final double caloriesProgress;
  final double stepsProgress;
  final double distanceProgress;

  const _RingsPainter({
    required this.caloriesProgress,
    required this.stepsProgress,
    required this.distanceProgress,
  });

  void _drawRing(Canvas canvas, Size size, double inset, double progress,
      Color color) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - inset;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track (inactive arc)
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = color.withAlpha(40)
        ..strokeCap = StrokeCap.round,
    );
    // Active arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = color
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawRing(canvas, size, 4, caloriesProgress, const Color(0xFFE53935));
    _drawRing(canvas, size, 20, stepsProgress, AppColors.cyan);
    _drawRing(canvas, size, 36, distanceProgress, const Color(0xFF00C853));
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.caloriesProgress != caloriesProgress ||
      old.stepsProgress != stepsProgress ||
      old.distanceProgress != distanceProgress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Latest activity card
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final double s;
  const _ActivityCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14 * s),
      child: Column(
        children: [
          // Running header row
          Row(
            children: [
              Container(
                width: 44 * s,
                height: 44 * s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyanTint10,
                  border:
                      Border.all(color: AppColors.cyan.withAlpha(60)),
                ),
                child: Icon(Icons.directions_run_rounded,
                    color: AppColors.cyan, size: 22 * s),
              ),
              SizedBox(width: 12 * s),
              Text(
                'Running',
                style: TextStyle(
                  fontFamily: 'LemonMilk',
                  fontSize: 13 * s,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _TimeRow(s: s, label: 'Start', time: '00:00'),
                  SizedBox(height: 2 * s),
                  _TimeRow(s: s, label: 'Finish', time: '00:00'),
                ],
              ),
            ],
          ),
          SizedBox(height: 14 * s),
          Divider(color: AppColors.divider, height: 1),
          SizedBox(height: 10 * s),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActivityStat(s: s, value: '-1', label: 'Pace'),
              _ActivityStat(s: s, value: '-1', label: 'Distance'),
              _ActivityStat(s: s, value: '-1', label: 'Calories'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  final double s;
  final String label;
  final String time;
  const _TimeRow(
      {required this.s, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label  ',
          style: GoogleFonts.inter(
              fontSize: 9 * s, color: AppColors.labelDim),
        ),
        Text(
          time,
          style: GoogleFonts.inter(
            fontSize: 9 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 2 * s),
        Icon(Icons.arrow_forward_ios_rounded,
            size: 8 * s, color: AppColors.labelDim),
      ],
    );
  }
}

class _ActivityStat extends StatelessWidget {
  final double s;
  final String value;
  final String label;
  const _ActivityStat(
      {required this.s, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 11 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2 * s),
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 9 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health metrics 2-column grid (8 tiles) — uses live bracelet data when present
// ─────────────────────────────────────────────────────────────────────────────
class _HealthGrid extends StatelessWidget {
  final double s;
  final double cw;
  final Map<String, dynamic>? liveData;
  final BraceletChannel? channel;

  const _HealthGrid({required this.s, required this.cw, this.liveData, this.channel});

  static const _metrics = [
    (title: 'SLEEP',          value: '-1',     unit: 'C',    color: Color(0xFF7C4DFF), trend: '-1'),
    (title: 'HYDRATION',      value: '-1',     unit: '%',    color: Color(0xFF00BCD4), trend: '-1'),
    (title: 'HEART RATE',     value: '-1',     unit: 'bpm',  color: Color(0xFFE53935), trend: '-1'),
    (title: 'HRV',            value: '-1',     unit: 'MS',   color: Color(0xFF00C853), trend: '-1'),
    (title: 'STRESS',         value: '-1',     unit: 'Low',  color: Color(0xFFFFB300), trend: '-1'),
    (title: 'SPO2',           value: '-1',     unit: '%',    color: Color(0xFF00BCD4), trend: '-1'),
    (title: 'TEMPERATURE',    value: '-1',     unit: '°C',   color: Color(0xFFE53935), trend: '-1'),
    (title: 'BLOOD PRESSURE', value: '-1',     unit: 'mmHg', color: Color(0xFF7C4DFF), trend: '-1'),
  ];

  String _valueFor(int index) {
    final m = _metrics[index];
    if (liveData == null) return m.value;
    if (m.title == 'HEART RATE') {
      final v = liveData!['heartRate'] ?? liveData!['HeartRate'];
      if (v != null) return (v is num) ? (v as num).toInt().toString() : v.toString();
    }
    if (m.title == 'STRESS') {
      final v = liveData!['stress'] ?? liveData!['Stress'];
      if (v != null) return (v is num) ? (v as num).toInt().toString() : v.toString();
    }
    if (m.title == 'BLOOD PRESSURE') {
      final sys = liveData!['systolic'] ?? liveData!['Systolic'];
      final dia = liveData!['diastolic'] ?? liveData!['Diastolic'];
      if (sys != null && dia != null) {
        final s = (sys is num) ? (sys as num).toInt().toString() : sys.toString();
        final d = (dia is num) ? (dia as num).toInt().toString() : dia.toString();
        return '$s/$d';
      }
    }
    if (m.title == 'TEMPERATURE') {
      final v = liveData!['temperature'] ?? liveData!['TempData'];
      if (v != null) {
        if (v is num) return (v as num).toStringAsFixed(1);
        final parsed = double.tryParse(v.toString());
        return parsed != null ? parsed.toStringAsFixed(1) : v.toString();
      }
    }
    return m.value;
  }

  String _trendFor(int index) {
    final m = _metrics[index];
    if (liveData == null) return m.trend;
    if (m.title == 'TEMPERATURE') {
      final v = liveData!['temperature'] ?? liveData!['TempData'];
      if (v != null) return 'Live';
    }
    if (m.title == 'HEART RATE') {
      if (liveData!['heartRate'] != null || liveData!['HeartRate'] != null) return 'Live';
    }
    if (m.title == 'STRESS') {
      if (liveData!['stress'] != null || liveData!['Stress'] != null) return 'Live';
    }
    if (m.title == 'BLOOD PRESSURE') {
      if (liveData!['systolic'] != null && liveData!['diastolic'] != null) return 'Live';
    }
    return m.trend;
  }

  @override
  Widget build(BuildContext context) {
    final gap = 10.0 * s;
    final cardW = (cw - gap) / 2;
    VoidCallback? tapFor(int index, BuildContext ctx) {
      if (_metrics[index].title == 'HEART RATE') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const HeartScreen()),
            );
      }
      if (_metrics[index].title == 'SLEEP') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const SleepScreen()),
            );
      }
      if (_metrics[index].title == 'HYDRATION') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const HydrationScreen()),
            );
      }
      if (_metrics[index].title == 'SPO2') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const Spo2Screen()),
            );
      }
      if (_metrics[index].title == 'HRV') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const HrvScreen()),
            );
      }
      if (_metrics[index].title == 'TEMPERATURE') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const TemperatureScreen()),
            );
      }
      if (_metrics[index].title == 'BLOOD PRESSURE') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => BloodPressureScreen(channel: channel, liveData: liveData)),
            );
      }
      if (_metrics[index].title == 'STRESS') {
        return () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => StressScreen(channel: channel)),
            );
      }
      return null;
    }

    final rows = <Widget>[];
    for (int i = 0; i < _metrics.length; i += 2) {
      final m0 = _metrics[i];
      final m1 = _metrics[i + 1];
      rows.add(Row(
        children: [
          _MetricCard(
            s: s,
            width: cardW,
            m: (title: m0.title, value: _valueFor(i), unit: m0.unit, color: m0.color, trend: _trendFor(i)),
            onTap: tapFor(i, context),
          ),
          SizedBox(width: gap),
          _MetricCard(
            s: s,
            width: cardW,
            m: (title: m1.title, value: _valueFor(i + 1), unit: m1.unit, color: m1.color, trend: _trendFor(i + 1)),
            onTap: tapFor(i + 1, context),
          ),
        ],
      ));
      if (i + 2 < _metrics.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}

class _MetricCard extends StatelessWidget {
  final double s;
  final double width;
  final ({String title, String value, String unit, Color color, String trend}) m;
  final VoidCallback? onTap;

  const _MetricCard(
      {required this.s, required this.width, required this.m, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
      width: width,
      child: CustomPaint(
        painter: SmoothGradientBorder(radius: 14 * s),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14 * s),
          child: ColoredBox(
            color: const Color(0xFF060E16),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 12 * s, vertical: 12 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + chevron
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          m.title,
                          style: GoogleFonts.inter(
                            fontSize: 8 * s,
                            fontWeight: FontWeight.w600,
                            color: AppColors.labelDim,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.labelDim, size: 14 * s),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  // Value
                  Text(
                    m.value,
                    style: GoogleFonts.inter(
                      fontSize: 22 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 2 * s),
                  // Unit + trend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m.unit,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: AppColors.labelDim,
                        ),
                      ),
                      Text(
                        m.trend,
                        style: GoogleFonts.inter(
                          fontSize: 9 * s,
                          color: m.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
