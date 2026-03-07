import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/data/bracelet_data_parser.dart';
import '../../bracelet/hydration_storage.dart';
import '../../bracelet/sleep_storage.dart';
import '../../bracelet/activity_storage.dart';
import '../../bracelet/weekly_data_storage.dart';
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
  /// Optional initial data (e.g. from search screen when navigating after first realtime packet).
  final Map<String, dynamic>? initialRealtimeData;

  const BraceletScreen({super.key, this.initialRealtimeData});

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
  /// Requests total activity every 30s. Separate from stream restart.
  Timer? _realtimeRefreshTimer;
  /// Re-sends startRealtime(2) every 10s to keep device stream alive (device stops after first batch otherwise).
  Timer? _realtimeStreamRestartTimer;
  bool _routeObserverSubscribed = false;
  bool _realtimeRefreshTimerActive = false;
  bool _realtimeStreamRestartTimerActive = false;
  /// Bump when we receive new data so UI keys change and widgets rebuild.
  int _dataVersion = 0;
  /// When we last received type 24/25 from device (for "Last updated" in UI).
  DateTime? _lastDataUpdateTime;
  /// Realtime stability test: startRealtime(2) only once per connected session; reset on disconnect.
  bool _startRealtimeCalledForSession = false;
  /// Guard so _onConnected runs only once per connection (avoids duplicate timers and double commands).
  bool _onConnectedRunning = false;
  /// Session history for progress chart (max 24 points each).
  final List<double> _stepsHistory = [];
  final List<double> _distanceHistory = [];
  final List<double> _caloriesHistory = [];
  static const int _maxSessionHistory = 24;

  /// Latest sport session from device (dataType 30 ActivityModeData). Shown in Latest Activity card.
  Map<String, dynamic>? _latestActivityData;

  @override
  void initState() {
    super.initState();
    if (widget.initialRealtimeData != null && widget.initialRealtimeData!.isNotEmpty) {
      _realtimeData = Map<String, dynamic>.from(widget.initialRealtimeData!);
    }
    _listenRealtime();
    _verifyConnectionAndClearIfDisconnected();
    // If already connected (e.g. reopen after restart), run on-connected logic immediately.
    _runOnConnectedIfConnected();
  }

  /// On init/resume: if bracelet is not connected, clear data (handles disconnect while app in background).
  Future<void> _verifyConnectionAndClearIfDisconnected() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    try {
      final state = await _channel.getConnectionState();
      if (state['connected'] != true && mounted) {
        setState(() => _clearDeviceData());
      }
    } catch (_) {}
  }

  /// Run startRealtime, requestTotalActivityData, startSpo2Monitoring and timers. Only call after connectionState == 'connected'.
  Future<void> _onConnected() async {
    if (_onConnectedRunning) {
      debugPrint('[Bracelet] _onConnected SKIPPED (already running)');
      return;
    }
    _onConnectedRunning = true;
    try {
      if (!mounted) return;
      _realtimeRefreshTimer?.cancel();
      _realtimeStreamRestartTimer?.cancel();
      _realtimeRefreshTimerActive = false;
      _realtimeStreamRestartTimerActive = false;
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      try {
        await _channel.startRealtime(RealtimeType.stepWithTemp);
        if (!mounted) return;
        await _channel.requestTotalActivityData();
        if (!mounted) return;
        await _channel.startSpo2Monitoring();
        if (!mounted) return;
        await _channel.requestHRVData();
        await _channel.requestSleepData();
        await _channel.requestActivityModeData();
      } catch (e, st) {
        if (kDebugMode) debugPrint('[Bracelet SDK] _onConnected error: $e $st');
      }
      if (!mounted) return;
      debugPrint('[Bracelet] _onConnected commands sent at ${DateTime.now()}');
      _startRealtimeCalledForSession = true;
      _startRealtimeRefreshTimer();
      _startRealtimeStreamRestartTimer();
      // After hot restart the event channel may not be ready; re-request once so data appears.
      Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;
        try {
          final state = await _channel.getConnectionState();
          if (state['connected'] == true &&
              (_realtimeData == null || _totalActivityData == null)) {
            if (kDebugMode) debugPrint('[Bracelet] retry request (no data yet)');
            await _channel.startRealtime(RealtimeType.stepWithTemp);
            await _channel.requestTotalActivityData();
            await _channel.startSpo2Monitoring();
            await _channel.requestHRVData();
            await _channel.requestSleepData();
            await _channel.requestActivityModeData();
          }
        } catch (_) {}
      });
    } finally {
      _onConnectedRunning = false;
    }
  }

  /// If already connected (e.g. screen open after restart), run on-connected logic once.
  void _runOnConnectedIfConnected() {
    Future.microtask(() async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true && mounted) await _onConnected();
      } catch (_) {}
    });
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
  void didPush() {
    // intentionally empty — initState handles initial connect
  }

  @override
  void didPopNext() {
    // User came back (e.g. from HRV/Stress/BP). Refresh so dashboard shows lastKnownHrv if HRV was set on inner screen.
    if (mounted) setState(() {});
    _runOnConnectedIfConnected();
  }

  @override
  void didPop() {
    // User left the bracelet section. Pause polling and stop device realtime to save battery.
    _pauseRealtime();
  }

  void _pauseRealtime() {
    _realtimeRefreshTimerActive = false;
    _realtimeStreamRestartTimerActive = false;
    _totalActivityTimer?.cancel();
    _totalActivityTimer = null;
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = null;
    _realtimeStreamRestartTimer?.cancel();
    _realtimeStreamRestartTimer = null;
    try {
      _channel.stopRealtime();
    } catch (_) {}
  }

  /// Call device for latest total activity. Used every 30s by the timer. Stream kept alive by startRealtime(2) every 10s.
  Future<void> _refreshDataFromDevice() async {
    if (!mounted) return;
    final t = DateTime.now().toString().substring(11, 19);
    try {
      final state = await _channel.getConnectionState();
      if (state['connected'] == true) {
        if (kDebugMode) {
          debugPrint('[Bracelet] requestTotalActivityData every 30s @ $t');
        }
        await _channel.requestTotalActivityData();
        await _channel.requestHRVData();
        await _channel.requestSleepData();
        await _channel.requestActivityModeData();
      }
      if (!mounted) return;
      if (kDebugMode) {
        final live = _mergedLiveData();
        if (live != null && live.isNotEmpty) {
          final step = live['step'];
          final hr = live['heartRate'];
          final cal = live['calories'];
          final dist = live['distance'];
          final temp = live['temperature'];
          final hrv = live['hrv'];
          debugPrint(
            '[Bracelet] Latest @ $t -> step: $step, heartRate: $hr, calories: $cal, distance: $dist, temp: $temp, hrv: $hrv',
          );
        }
      }
      // Refresh "Last updated Xs ago" every second.
      if (mounted && _lastDataUpdateTime != null) {
        setState(() {});
      }
    } catch (_) {}
  }

  /// Refresh total activity every 30 seconds. Stream restart is a separate 10s timer.
  void _startRealtimeRefreshTimer() {
    if (_realtimeRefreshTimerActive) return;
    _realtimeRefreshTimerActive = true;
    _realtimeRefreshTimer?.cancel();
    _realtimeRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshDataFromDevice();
    });
    _refreshDataFromDevice();
  }

  /// Re-send startRealtime(2) periodically to keep device stream alive. First run after 25s so type 24 + SpO2 (57) can arrive first; then every 25s to avoid interrupting the stream too often.
  void _startRealtimeStreamRestartTimer() {
    if (_realtimeStreamRestartTimerActive) return;
    _realtimeStreamRestartTimerActive = true;
    _realtimeStreamRestartTimer?.cancel();
    void resend() async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true) {
          if (kDebugMode) {
            debugPrint('[Bracelet] startRealtime(2) re-sent to restart stream');
          }
          await _channel.startRealtime(RealtimeType.stepWithTemp);
          await _channel.startSpo2Monitoring();
          await _channel.requestHRVData();
        }
      } catch (_) {}
    }
    const interval = Duration(seconds: 25);
    _realtimeStreamRestartTimer = Timer(interval, () {
      if (!mounted) return;
      resend();
      _realtimeStreamRestartTimer = Timer.periodic(interval, (_) {
        resend();
      });
    });
  }

  /// Clear all device data when bracelet disconnects (so UI does not show stale data).
  void _clearDeviceData() {
    _realtimeData = null;
    _totalActivityData = null;
    _latestActivityData = null;
    _bpSystolic = null;
    _bpDiastolic = null;
    _lastDataUpdateTime = null;
    _startRealtimeCalledForSession = false;
    _onConnectedRunning = false;
    _stepsHistory.clear();
    _distanceHistory.clear();
    _caloriesHistory.clear();
    _totalActivityTimer?.cancel();
    _totalActivityTimer = null;
  }

  void _listenRealtime() {
    _subscription?.cancel();
    _subscription = _channel.events.listen((BraceletEvent e) {
      if (!mounted) return;
      if (kDebugMode) {
        debugPrint(
          '[Bracelet] event @ ${DateTime.now().toString().substring(11, 19)} -> ${e.event}',
        );
        debugPrint('[Bracelet DBG] event received: ${e.event} dataType=${e.data['dataType']}');
      }
      if (e.event == 'connectionState') {
        final state = e.data['state']?.toString();
        if (BraceletChannel.isDisconnectedState(state)) {
          _pauseRealtime();
          setState(() => _clearDeviceData());
        } else if (state == 'connected' && !_startRealtimeCalledForSession) {
          // Only run once per connection; avoid duplicate commands when event fires again.
          _onConnected();
        }
        return;
      }
      if (e.event != 'realtimeData') return;
      final dataType = e.data['dataType'];
      final dataEnd = e.data['dataEnd'];
      final dic = e.data['dicData'];

      final _t = DateTime.now().toString().substring(11, 19);
      debugPrint(
        '[Bracelet SDK] @ $_t dataType: $dataType, dataEnd: $dataEnd, dicData: $dic',
      );

      if (dic == null || dic is! Map) return;

      final dicMap = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );

      final type = BraceletDataParser.dataTypeAsInt(dataType);
      final dicMapCopy = Map<String, dynamic>.from(dicMap);

      void applyUpdate() {
        if (!mounted) return;
        setState(() {
          if (type != null &&
              (type == 24 ||
                  type == 25 ||
                  type == 42 ||
                  type == 43 ||
                  type == 57 ||
                  type == 38 ||
                  type == 56)) {
            _lastDataUpdateTime = DateTime.now();
          }
          if (type != null && type == 25) {
            _totalActivityData = BraceletDataParser.parseTotalActivityData(dicMapCopy);
            if (kDebugMode && _totalActivityData != null) {
              final _t = DateTime.now().toString().substring(11, 19);
              final step25 = _totalActivityData!['step'] ?? _totalActivityData!['Step'];
              debugPrint('[Bracelet SOURCE] type25 step=$step25');
              debugPrint(
                '[Bracelet SDK] @ $_t TotalActivityData (25) -> step: $step25, distance: ${_totalActivityData!['distance'] ?? _totalActivityData!['Distance']}, calories: ${_totalActivityData!['calories'] ?? _totalActivityData!['Calories']}',
              );
            }
          } else if (type != null && type == 27) {
            final _t = DateTime.now().toString().substring(11, 19);
            debugPrint('[Bracelet SDK] @ $_t SleepData (27) -> $dicMapCopy');
            final parsed = BraceletDataParser.parseSleepData(dicMapCopy);
            if (parsed != null) {
              SleepStorage.updateFromMap(parsed);
              _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
              _realtimeData!['sleep'] = parsed;
              if (mounted) setState(() {});
            }
          } else if (type != null && type == 30) {
            final _t = DateTime.now().toString().substring(11, 19);
            if (kDebugMode) debugPrint('[Bracelet SDK] @ $_t ActivityModeData (30) -> $dicMapCopy');
            final latest = BraceletDataParser.parseActivityModeDataLatest(dicMapCopy);
            if (latest != null) {
              _latestActivityData = latest;
            }
            final todayList = BraceletDataParser.parseActivityModeDataTodayList(dicMapCopy);
            ActivityStorage.updateSessions(todayList);
            if (mounted) setState(() {});
          } else if (type != null && (type == 38 || type == 56)) {
            _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
            _realtimeData!.addAll(dicMapCopy);
            int? hrvMs = BraceletDataParser.extractHrvFromMap(dicMapCopy);
            if (hrvMs == null) {
              final dataList =
                  dicMapCopy['arrayHrvData'] ?? dicMapCopy['Data'] ?? dicMapCopy['data'];
              if (dataList is List && dataList.isNotEmpty) {
                for (final record in [dataList.first, dataList.last]) {
                  if (record is! Map) continue;
                  final rec = Map<String, dynamic>.from(
                    (record as Map<Object?, Object?>).map(
                      (k, v) => MapEntry(k?.toString() ?? '', v),
                    ),
                  );
                  hrvMs = BraceletDataParser.extractHrvFromMap(rec);
                  if (hrvMs != null) break;
                }
              }
            }
            if (hrvMs != null) {
              _realtimeData!['hrv'] = hrvMs;
              BraceletChannel.lastKnownHrv = hrvMs;
            }
            if (kDebugMode) {
              final _t = DateTime.now().toString().substring(11, 19);
              debugPrint(
                '[Bracelet SDK] @ $_t HRV (type $type) -> hrv: $hrvMs, stress: ${dicMapCopy['Stress'] ?? dicMapCopy['stress']}',
              );
            }
          } else if (type != null && (type == 42 || type == 43 || type == 57)) {
            // Dedicated SpO2 types: 42 AutomaticSpo2Data, 43 ManualSpo2Data, 57 DeviceMeasurement_Spo2
            // Only store 1–100%; device sends 0 for "no reading" – don't overwrite last valid value.
            final spo2Raw = dicMapCopy['blood_oxygen'] ??
                dicMapCopy['Blood_oxygen'] ??
                dicMapCopy['spo2'] ??
                dicMapCopy['SPO2'] ??
                dicMapCopy['Spo2'] ??
                dicMapCopy['oxygen'] ??
                dicMapCopy['Oxygen'];
            final spo2Val = BraceletDataParser.intFrom(spo2Raw);
            if (spo2Val != null && spo2Val > 0 && spo2Val <= 100) {
              _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
              _realtimeData!['Blood_oxygen'] = spo2Val;
              _realtimeData!['spo2'] = spo2Val;
              if (kDebugMode) {
                final _t = DateTime.now().toString().substring(11, 19);
                debugPrint('[Bracelet SDK] @ $_t SpO2 (type $type) -> $spo2Val%');
              }
            }
          } else {
            final oldStep = _realtimeData?['step'] ?? _realtimeData?['Step'];
            _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
            _realtimeData!.addAll(dicMapCopy);
            if (type != null && type == 24) {
              final _t = DateTime.now().toString().substring(11, 19);
              final newStep = dicMapCopy['step'] ?? dicMapCopy['Step'];
              final spo24 = dicMapCopy['blood_oxygen'] ?? dicMapCopy['Blood_oxygen'] ?? dicMapCopy['spo2'];
              final hrv24 = BraceletDataParser.extractHrvFromMap(dicMapCopy);
              if (hrv24 != null) {
                _realtimeData!['hrv'] = hrv24;
                BraceletChannel.lastKnownHrv = hrv24;
                if (kDebugMode) {
                  debugPrint('[Bracelet SDK] @ $_t RealTimeStep (24) HRV: $hrv24');
                }
              }
              if (kDebugMode) {
                debugPrint('[Bracelet SOURCE] type24 step=$newStep (old=$oldStep)');
                debugPrint('[Bracelet DBG] applyUpdate: type24 step updated to $newStep (old=$oldStep)');
                if (newStep != oldStep) {
                  debugPrint(
                    '[Bracelet SDK] @ $_t step changed $oldStep -> $newStep (UI will update)',
                  );
                }
                if (spo24 != null) {
                  debugPrint('[Bracelet SDK] @ $_t RealTimeStep (24) Blood_oxygen/spo2: $spo24');
                }
              }
              debugPrint(
                '[Bracelet SDK] @ $_t RealTimeStep (24) -> step: ${dicMapCopy['step']}, distance: ${dicMapCopy['distance']}, calories: ${dicMapCopy['calories']}, heartRate: ${dicMapCopy['heartRate']}',
              );
            }
          }
          if (kDebugMode && (type == 52 || type == 70)) {
            final _t = DateTime.now().toString().substring(11, 19);
            debugPrint(
              '[Bracelet SDK] @ $_t dataType $type (ECG/ppg) -> keys: ${dicMapCopy.keys.join(', ')}',
            );
          }
          final bp = BraceletDataParser.parseBloodPressure(dicMapCopy);
          if (bp != null) {
            _bpSystolic = bp.$1;
            _bpDiastolic = bp.$2;
            if (kDebugMode) {
              final _t = DateTime.now().toString().substring(11, 19);
              debugPrint(
                '[Bracelet SDK] @ $_t Blood pressure -> systolic: ${bp.$1}, diastolic: ${bp.$2}',
              );
            }
          }
          if (type != null && (type == 24 || type == 25 || type == 42 || type == 43 || type == 57)) {
            final merged = BraceletDataParser.mergeLiveData(
              _realtimeData,
              _totalActivityData,
              _bpSystolic,
              _bpDiastolic,
            )?.toDisplayMap();
            if (merged != null) {
              final step = _numToDouble(merged['step']) ?? 0.0;
              final distRaw = _numToDouble(merged['distance'] ?? merged['Distance']);
              final distKm = distRaw != null
                  ? (distRaw > 100 ? distRaw / 1000.0 : distRaw)
                  : 0.0;
              final cal = _numToDouble(merged['calories']) ?? 0.0;
              _stepsHistory.add(step);
              if (_stepsHistory.length > _maxSessionHistory) _stepsHistory.removeAt(0);
              _distanceHistory.add(distKm);
              if (_distanceHistory.length > _maxSessionHistory) _distanceHistory.removeAt(0);
              _caloriesHistory.add(cal);
              if (_caloriesHistory.length > _maxSessionHistory) _caloriesHistory.removeAt(0);
              WeeklyDataStorage.updateTodayDistance(distKm, (step ?? 0).toInt());
            }
          }
          _dataVersion++;
        });
      }

      // Update state immediately so steps/HR/calories show in UI.
      applyUpdate();
      // Force another rebuild next frame so UI definitely repaints (e.g. if event came from platform thread).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (kDebugMode) {
            final merged = _mergedLiveData();
            final mergedStep = merged?['step'];
            debugPrint('[Bracelet SOURCE] merged step=$mergedStep (after type $type)');
          }
          setState(() {});
        }
      });
    });
  }

  /// Format "Last updated" for UI: "X s ago" if < 60s, else "at HH:mm".
  String _formatLastUpdated(DateTime t) {
    final sec = DateTime.now().difference(t).inSeconds;
    if (sec < 60) return '${sec}s ago';
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return 'at $h:$m';
  }

  static double? _numToDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// Build a "current activity" map from type 24 realtime data when we have no type 30 (sport session).
  /// Shows e.g. Walking with live steps/distance/calories so the card isn't empty while user is active.
  Map<String, dynamic>? _buildCurrentActivityFromRealtime() {
    final r = _realtimeData;
    if (r == null) return null;
    final exerciseMin = BraceletDataParser.intFrom(
      r['exerciseMinutes'] ?? r['ExerciseMinutes'] ?? r['activeMinutes'] ?? r['ActiveMinutes'],
    );
    final step = BraceletDataParser.intFrom(r['step'] ?? r['Step']);
    final distance = BraceletDataParser.toDouble(r['distance'] ?? r['Distance']);
    final calories = BraceletDataParser.toDouble(r['calories'] ?? r['Calories']);
    final hasActivity = (exerciseMin != null && exerciseMin > 0) ||
        (step != null && step > 50);
    if (!hasActivity) return null;
    return <String, dynamic>{
      'sportName': 'Walking',
      'date': 'Now',
      'activeMinutes': exerciseMin ?? 0,
      'step': step,
      'distance': distance,
      'calories': calories,
      'pace': null,
      'isLive': true,
    };
  }

  /// Merge total activity with realtime; delegates to parser. Returns same map shape for ProgressCard / _HealthGrid.
  Map<String, dynamic>? _mergedLiveData() {
    final metrics = BraceletDataParser.mergeLiveData(
      _realtimeData,
      _totalActivityData,
      _bpSystolic,
      _bpDiastolic,
    );
    return metrics?.toDisplayMap();
  }

  @override
  void dispose() {
    if (_routeObserverSubscribed) {
      app.braceletRouteObserver.unsubscribe(this);
    }
    _pauseRealtime();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    // Display data: _mergedLiveData() merges _realtimeData (type 24, 38, 56, …) + _totalActivityData (type 25).
    // HR/SpO2/temp come from type 24; HRV comes from type 38/56. We request HRV on the dashboard (connect, 30s refresh, stream restart).
    // Dashboard and HRV screen share the same event stream, so when the device sends 38/56 (e.g. after user opens HRV screen), the dashboard also receives it and shows HRV here—no need to pass back from the inner screen.
    // If the device hasn't sent 38/56 yet, use last known HRV when available.
    final liveData = _mergedLiveData();
    if (liveData != null &&
        liveData['hrv'] == null &&
        BraceletChannel.lastKnownHrv != null) {
      liveData['hrv'] = BraceletChannel.lastKnownHrv;
    }
    final stepKey = '${liveData?['step'] ?? 0}_v$_dataVersion';

    // When no type 30 (sport session) data, show current activity from type 24 if user is active
    final latestActivityToShow = _latestActivityData ?? _buildCurrentActivityFromRealtime();

    return BraceletScaffold(
      child: KeyedSubtree(
        key: ValueKey<int>(_dataVersion),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // ── Hi user ──────────────────────────────────────────
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final name = auth.profile?.name?.trim();
              final greeting = (name != null && name.isNotEmpty)
                  ? 'HI, ${name.toUpperCase()}'
                  : 'HI';
              return Center(
                child: Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'LemonMilk',
                    fontSize: 11 * s,
                    fontWeight: FontWeight.w300,
                    color: AppColors.labelDim,
                    letterSpacing: 2.0,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20 * s),

          // ── Progress card (key so it rebuilds when step/data changes) ──
          ProgressCard(
            key: ValueKey<String>('progress_$stepKey'),
            s: s,
            liveData: liveData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProgressScreen(
                  liveData: liveData,
                  stepsHistory: List<double>.from(_stepsHistory),
                  distanceHistory: List<double>.from(_distanceHistory),
                  caloriesHistory: List<double>.from(_caloriesHistory),
                ),
              ),
            ),
          ),
          if (_lastDataUpdateTime != null) ...[
            SizedBox(height: 6 * s),
            Center(
              child: Text(
                'Last updated ${_formatLastUpdated(_lastDataUpdateTime!)}',
                style: AppStyles.reg12(s).copyWith(
                  color: AppColors.labelDim.withOpacity(0.8),
                  fontSize: 10 * s,
                ),
              ),
            ),
          ],
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
            latestActivity: latestActivityToShow,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ActivitiesScreen(
                  channel: _channel,
                  liveData: liveData,
                ),
              ),
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

          // ── Health metrics grid (key so it rebuilds when data changes) ──
          _HealthGrid(
            key: ValueKey<String>('health_$stepKey'),
            s: s,
            liveData: liveData,
            channel: _channel,
          ),
          SizedBox(height: 40 * s),
          ],
        ),
      ),
    );
  }
}

class _HealthGrid extends StatelessWidget {
  final double s;
  final Map<String, dynamic>? liveData;
  final BraceletChannel channel;

  const _HealthGrid({
    super.key,
    required this.s,
    this.liveData,
    required this.channel,
  });

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
    final hrStr = hr != null ? '$hr' : '-1';
    final hrvStr = hrv != null ? '$hrv' : 'N/A';
    final spo2Str = spo2 != null ? '$spo2' : '-1';
    final bpStr = (systolic != null && diastolic != null)
        ? '$systolic/$diastolic'
        : '-1/-1';
    final tempStr = temp != null ? (temp as num).toStringAsFixed(1) : '-1';
    final stressStr = stress != null ? '$stress' : '-1';

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
          value: SleepStorage.displayString ?? 'N/A',
          unit: '',
          trend: '-1',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SleepScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HYDRATION',
          value: '${HydrationStorage.percentForDisplay}',
          unit: '%',
          trend: '-1',
          trendColor: Colors.greenAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HydrationScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HEART RATE',
          value: hrStr,
          unit: 'BPM',
          trend: '-1',
          trendColor: Colors.greenAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HeartScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HRV',
          value: hrvStr,
          unit: 'MS',
          trend: '-1',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HrvScreen(channel: channel, liveData: liveData)),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'STRESS',
          value: stressStr,
          unit: stress != null && (stress as num) > 50 ? 'HIGH' : 'LOW',
          trend: '-1',
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
          trend: '-1',
          trendColor: Colors.redAccent,
          onTap: () {
            final spo2Num = liveData?['spo2'] ?? liveData?['Blood_oxygen'] ?? liveData?['oxygen'];
            final initialSpO2 = spo2Num != null ? BraceletDataParser.intFrom(spo2Num) : null;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Spo2Screen(channel: channel, initialSpO2: initialSpO2),
              ),
            );
          },
        ),
        HealthMetricCard(
          s: s,
          title: 'TEMPERATURE',
          value: tempStr,
          unit: '℃',
          trend: '-1',
          trendColor: Colors.redAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TemperatureScreen(channel: channel),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'BLOOD PRESSURE',
          value: bpStr,
          unit: 'mmHg',
          trend: '-1',
          trendColor: Colors.greenAccent,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  BloodPressureScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
      ],
    );
  }
}
