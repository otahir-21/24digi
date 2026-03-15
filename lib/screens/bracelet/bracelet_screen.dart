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

  /// HRV samples collected this session (from type 38/56). Used to show average on HRV tile.
  final List<int> _hrvSessionSamples = [];
  /// For temporary Progress source logging: last step we logged so we log only when it changes.
  int? _lastLoggedProgressStep;

  /// Latest sport session from device (dataType 30 ActivityModeData). Shown in Latest Activity card.
  Map<String, dynamic>? _latestActivityData;

  /// When step count last increased (type 24/25). Used so we only show "Walking" fallback for ~25 min after activity.
  DateTime? _lastStepIncreaseTime;
  int? _lastSeenStepCount;

  /// Type-27 sleep fragments buffered until debounce fires; then parsed as one merged session.
  final List<Map<String, dynamic>> _sleepRecordsBuffer = [];
  static const Duration _sleepBatchDebounce = Duration(milliseconds: 800);
  Timer? _sleepBatchTimer;
  /// Incremented each time we send requestSleepData(); responses are tied to this cycle.
  int _sleepRequestCycle = 0;
  /// Cycle id for which we are currently collecting type-27 packets; null until first request.
  int? _activeSleepRequestCycle;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('[Bracelet Stream] dashboard: initState channel=${_channel.hashCode}');
    }
    if (widget.initialRealtimeData != null && widget.initialRealtimeData!.isNotEmpty) {
      _realtimeData = Map<String, dynamic>.from(widget.initialRealtimeData!);
    }
    _listenRealtime();
    // Same as activity screen: start realtime stream immediately so type 24 keeps flowing while dashboard is visible.
    if (kDebugMode) {
      debugPrint('[Bracelet Stream] dashboard: startRealtime(2) caller=initState channel=${_channel.hashCode}');
    }
    _channel.startRealtime(RealtimeType.stepWithTemp);
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
  /// Run only once per session so we don't flood the device and break the type 24 stream (activity screen only sends startRealtime once).
  Future<void> _onConnected() async {
    if (_onConnectedRunning) {
      if (kDebugMode) debugPrint('[Bracelet] _onConnected SKIPPED (already running)');
      return;
    }
    if (_startRealtimeCalledForSession) {
      if (kDebugMode) debugPrint('[Bracelet] _onConnected SKIPPED (already ran this session)');
      return;
    }
    _onConnectedRunning = true;
    try {
      if (!mounted) return;
      _realtimeRefreshTimer?.cancel();
      _realtimeStreamRestartTimer?.cancel();
      _realtimeRefreshTimerActive = false;
      _realtimeStreamRestartTimerActive = false;
      // No delay: request data immediately so dashboard shows data right after pair (Bug 1) and type 24 stream starts for live Progress (Bug 2).
      if (!mounted) return;
      try {
        if (kDebugMode) {
          debugPrint('[Bracelet Stream] dashboard: startRealtime(2) caller=_onConnected channel=${_channel.hashCode}');
        }
        await _channel.startRealtime(RealtimeType.stepWithTemp);
        if (!mounted) return;
        await _channel.requestTotalActivityData();
        if (!mounted) return;
        await _channel.requestHRVData();
        await _channel.requestAutomaticSpo2History();
        if (kDebugMode) debugPrint('[Bracelet Sleep] requestSleepData() in _onConnected');
        _requestSleepData();
        await _channel.requestActivityModeData();
      } catch (e, st) {
        if (kDebugMode) debugPrint('[Bracelet SDK] _onConnected error: $e $st');
      }
      if (!mounted) return;
      debugPrint('[Bracelet] _onConnected commands sent at ${DateTime.now()}');
      _startRealtimeCalledForSession = true;
      _startRealtimeRefreshTimer();
      _startRealtimeStreamRestartTimer();
      // One-time retry if no data yet: only startRealtime + requestTotalActivityData so we don't flood device.
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        try {
          final state = await _channel.getConnectionState();
          if (state['connected'] == true &&
              (_realtimeData == null || _totalActivityData == null)) {
            if (kDebugMode) debugPrint('[Bracelet] retry (no data yet): startRealtime + requestTotalActivityData');
            await _channel.startRealtime(RealtimeType.stepWithTemp);
            await _channel.requestTotalActivityData();
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
    // User came back: only restart step stream (like activity screen). Do not re-run full _onConnected to avoid flooding device and breaking type 24.
    if (mounted) setState(() {});
    _channel.startRealtime(RealtimeType.stepWithTemp);
    if (kDebugMode) debugPrint('[Bracelet Sleep] requestSleepData() on didPopNext');
    _requestSleepData();
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
        await _channel.requestAutomaticSpo2History();
        _requestSleepData();
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

  /// Re-send only startRealtime(2) periodically to keep type 24 stream alive (like activity screen). No HRV/SpO2 here to avoid interrupting step stream.
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
            debugPrint('[Bracelet Stream] dashboard: startRealtime(2) keepalive channel=${_channel.hashCode}');
          }
          await _channel.startRealtime(RealtimeType.stepWithTemp);
        }
      } catch (_) {}
    }
    const interval = Duration(seconds: 10);
    _realtimeStreamRestartTimer = Timer(const Duration(seconds: 8), () {
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
    BraceletChannel.lastKnownHrv = null;  // Avoid stale HRV on dashboard after removal.
    BraceletChannel.lastKnownSpo2 = null; // Avoid stale SpO2 on dashboard after removal.
    _hrvSessionSamples.clear();
    _lastStepIncreaseTime = null;
    _lastSeenStepCount = null;
  }

  void _listenRealtime() {
    _subscription?.cancel();
    if (kDebugMode) {
      debugPrint('[Bracelet Stream] dashboard: subscribe channel=${_channel.hashCode}');
    }
    _subscription = _channel.events.listen((BraceletEvent e) {
      if (!mounted) return;
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
          } else if (type != null && type == 27) {
            _bufferSleepRecords(dicMapCopy);
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
              _hrvSessionSamples.add(hrvMs);
              if (_hrvSessionSamples.length > 100) _hrvSessionSamples.removeAt(0);
              final avgHrv = (_hrvSessionSamples.reduce((a, b) => a + b) / _hrvSessionSamples.length).round();
              _realtimeData!['hrv'] = avgHrv;
              BraceletChannel.lastKnownHrv = avgHrv;
            }
            if (kDebugMode) {
              final _t = DateTime.now().toString().substring(11, 19);
              debugPrint(
                '[Bracelet SDK] @ $_t HRV (type $type) -> hrv: $hrvMs, stress: ${dicMapCopy['Stress'] ?? dicMapCopy['stress']}',
              );
            }
          } else if (type != null && (type == 42 || type == 43 || type == 57)) {
            // Dedicated SpO2 types: 42 AutomaticSpo2Data, 43 ManualSpo2Data, 57 DeviceMeasurement_Spo2
            // iOS may put value in top-level or under dicData['Data'] – use shared extractor.
            final spo2Val = BraceletDataParser.extractSpo2FromDicData(dicMapCopy);
            if (kDebugMode) {
              final _t = DateTime.now().toString().substring(11, 19);
              final hasData = dicMapCopy.containsKey('Data') || dicMapCopy.containsKey('data');
              debugPrint(
                '[Bracelet SDK] @ $_t SpO2 received type=$type keys=${dicMapCopy.keys.join(', ')} hasData=$hasData -> parsed spo2=$spo2Val',
              );
            }
            if (spo2Val != null && spo2Val > 0 && spo2Val <= 100) {
              _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
              _realtimeData!['Blood_oxygen'] = spo2Val;
              _realtimeData!['spo2'] = spo2Val;
              BraceletChannel.lastKnownSpo2 = spo2Val;
              if (kDebugMode) {
                final _t = DateTime.now().toString().substring(11, 19);
                debugPrint('[Bracelet SDK] @ $_t SpO2 (type $type) -> $spo2Val%');
              }
            }
          } else {
            _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
            _realtimeData!.addAll(dicMapCopy);
            if (type != null && type == 24) {
              if (kDebugMode) {
                final step24 = dicMapCopy['step'] ?? dicMapCopy['Step'];
                debugPrint('[Bracelet Stream] dashboard received type 24 channel=${_channel.hashCode} step=$step24');
              }
              final hrv24 = BraceletDataParser.extractHrvFromMap(dicMapCopy);
              if (hrv24 != null) {
                _realtimeData!['hrv'] = hrv24;
                BraceletChannel.lastKnownHrv = hrv24;
              }
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
          if (type != null && (type == 24 || type == 25)) {
            final step24 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(_realtimeData, ['step', 'Step']));
            final step25 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(_totalActivityData, ['step', 'Step']));
            final currentStep = step24 ?? step25;
            if (currentStep != null && currentStep > 0) {
              if (_lastSeenStepCount != null && currentStep > _lastSeenStepCount!) {
                _lastStepIncreaseTime = DateTime.now();
              }
              _lastSeenStepCount = currentStep;
            }
          }
          _dataVersion++;
        });
      }

      // Update state immediately so steps/HR/calories show in UI.
      applyUpdate();
      // Force another rebuild next frame so UI definitely repaints (e.g. if event came from platform thread).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
  }

  /// Send sleep request and start a new response cycle: clear buffer, cancel timer, then request.
  void _requestSleepData() {
    _sleepRequestCycle++;
    _activeSleepRequestCycle = _sleepRequestCycle;
    _sleepRecordsBuffer.clear();
    _sleepBatchTimer?.cancel();
    _sleepBatchTimer = null;
    _channel.requestSleepData();
  }

  /// Append type-27 packet records to buffer (only for active cycle) and reset 800ms debounce; when timer fires, process only that cycle's batch.
  void _bufferSleepRecords(Map<String, dynamic> dicMapCopy) {
    if (_activeSleepRequestCycle == null) return;
    final raw = dicMapCopy['arrayDetailSleepData'] ?? dicMapCopy['Data'] ?? dicMapCopy['data'] ?? dicMapCopy['arraySleepData'];
    if (raw is List && raw.isNotEmpty) {
      for (final item in raw) {
        if (item is Map) {
          _sleepRecordsBuffer.add(Map<String, dynamic>.from(
            (item as Map<Object?, Object?>).map(
              (k, v) => MapEntry(k?.toString() ?? '', v),
            ),
          ));
        }
      }
    } else if (dicMapCopy.containsKey('totalSleepTime') || dicMapCopy.containsKey('startTime_SleepData') || dicMapCopy.containsKey('arraySleepQuality')) {
      _sleepRecordsBuffer.add(Map<String, dynamic>.from(dicMapCopy));
    }
    final cycleForThisBatch = _activeSleepRequestCycle;
    _sleepBatchTimer?.cancel();
    _sleepBatchTimer = Timer(_sleepBatchDebounce, () {
      if (!mounted) return;
      if (cycleForThisBatch != _activeSleepRequestCycle) return;
      final list = List<Map<String, dynamic>>.from(_sleepRecordsBuffer);
      _sleepRecordsBuffer.clear();
      _sleepBatchTimer?.cancel();
      _sleepBatchTimer = null;
      if (list.isEmpty) return;
      final payload = <String, dynamic>{'arrayDetailSleepData': list};
      final result = BraceletDataParser.parseSleepDataWithDedup(payload);
      final parsed = result.$1;
      final dedupedCount = result.$2;
      if (kDebugMode) {
        debugPrint('[Sleep 27 Batch] cycle=$cycleForThisBatch buffered=${list.length} deduped=$dedupedCount');
      }
      if (parsed != null) {
        final map = parsed.toMap();
        SleepStorage.updateFromMap(map);
        _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
        _realtimeData!['sleep'] = map;
        if (mounted) setState(() {});
      }
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

  /// Today's activity from type 24/25 when there is no type 30 (sport session).
  /// Shown as "Walking" / "Today's activity" with today's date so recent walks appear in Latest Activity
  /// even when the device doesn't send type 30 for auto-detected walks. Not "in progress" — date is today.
  Map<String, dynamic>? _buildTodayActivityFallback() {
    final r = _realtimeData;
    final t = _totalActivityData;
    final step = BraceletDataParser.intFrom(BraceletDataParser.firstOf(r, ['step', 'Step'])) ??
        BraceletDataParser.intFrom(BraceletDataParser.firstOf(t, ['step', 'Step']));
    final distance = BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['distance', 'Distance'])) ??
        BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, ['distance', 'Distance', 'totalDistance', 'TotalDistance']));
    final calories = BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['calories', 'Calories'])) ??
        BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, ['calories', 'Calories']));
    final exerciseMin = BraceletDataParser.intFrom(
      r?['exerciseMinutes'] ?? r?['ExerciseMinutes'] ?? r?['activeMinutes'] ?? r?['ActiveMinutes'] ??
      t?['exerciseMinutes'] ?? t?['ExerciseMinutes'] ?? t?['activeMinutes'] ?? t?['ActiveMinutes'],
    );
    final hasActivity = (step != null && step > 0) ||
        (exerciseMin != null && exerciseMin > 0) ||
        (distance != null && distance > 0);
    if (!hasActivity) return null;
    final now = DateTime.now();
    final dateStr = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return <String, dynamic>{
      'sportName': 'Walking',
      'date': dateStr,
      'activeMinutes': exerciseMin ?? 0,
      'step': step,
      'distance': distance,
      'calories': calories,
      'pace': null,
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

  /// Progress-only data: step/distance/calories from type 24 (_realtimeData) when present, else type 25 (_totalActivityData). Same as activity screen — no stale merge.
  Map<String, dynamic>? _progressLiveData() {
    final base = _mergedLiveData();
    final r = _realtimeData;
    final t = _totalActivityData;
    final step24 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(r, ['step', 'Step', 'steps', 'Steps']));
    final step25 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(t, ['step', 'Step', 'steps', 'Steps']));
    final dist24 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['distance', 'Distance', 'mileage']));
    final dist25 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, ['distance', 'Distance', 'totalDistance', 'TotalDistance', 'mileage']));
    final cal24 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['calories', 'Calories']));
    final cal25 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, ['calories', 'Calories']));
    final step = step24 ?? step25;
    final distance = dist24 ?? dist25;
    final calories = cal24 ?? cal25;
    if (kDebugMode) {
      if (step != _lastLoggedProgressStep) {
        _lastLoggedProgressStep = step;
        debugPrint('[Bracelet Progress] type24 step=$step24 type25 step=$step25 -> final step=$step (ProgressCard source)');
      }
    }
    if (base == null && step == null && distance == null && calories == null) return null;
    final out = Map<String, dynamic>.from(base ?? {});
    if (step != null) out['step'] = step;
    if (distance != null) out['distance'] = distance;
    if (calories != null) out['calories'] = calories;
    return out;
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('[Bracelet Stream] dashboard: dispose unsubscribe channel=${_channel.hashCode}');
    }
    if (_routeObserverSubscribed) {
      app.braceletRouteObserver.unsubscribe(this);
    }
    _sleepBatchTimer?.cancel();
    _sleepBatchTimer = null;
    _pauseRealtime();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    // Display data: _mergedLiveData() for health grid / other tiles. Progress uses _progressLiveData() so step/distance/calories come from type 24 when present (same as activity screen).
    final liveData = _mergedLiveData();
    final progressLiveData = _progressLiveData();
    final stepKey = '${progressLiveData?['step'] ?? liveData?['step'] ?? 0}_v$_dataVersion';

    // Prefer type 30 (sport session). Else show today's activity fallback only when steps increased recently (~25 min) so we don't show "Walking" when sitting.
    final fallback = _buildTodayActivityFallback();
    final showFallback = fallback != null &&
        _lastStepIncreaseTime != null &&
        DateTime.now().difference(_lastStepIncreaseTime!).inMinutes < 25;
    final latestActivityToShow = _latestActivityData ?? (showFallback ? fallback : null);

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

          // ── Progress card: type-24-first data so it updates like activity screen ──
          ProgressCard(
            key: ValueKey<String>('progress_$stepKey'),
            s: s,
            liveData: progressLiveData ?? liveData,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProgressScreen(
                  liveData: progressLiveData ?? liveData,
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

  static num? _validHeartRate(dynamic v) {
    if (v == null) return null;
    final n = v is num ? v : (v is String ? num.tryParse(v) : null);
    if (n == null) return null;
    return (n.toDouble() >= 30 && n.toDouble() <= 250) ? n : null;
  }

  static num? _validSpo2(dynamic v) {
    if (v == null) return null;
    final n = v is num ? v : (v is String ? num.tryParse(v) : null);
    if (n == null) return null;
    return (n.toDouble() > 0 && n.toDouble() <= 100) ? n : null;
  }

  static num? _validTemp(dynamic v) {
    if (v == null) return null;
    final n = v is num ? v : (v is String ? num.tryParse(v) : null);
    if (n == null) return null;
    return (n.toDouble() >= 30 && n.toDouble() <= 45) ? n : null;
  }

  @override
  Widget build(BuildContext context) {
    // Current values from SDK
    final hr = liveData?['heartRate'] ?? liveData?['HeartRate'];
    // HRV: prefer live map, then fall back to the last known value cached in
    // BraceletChannel.lastKnownHrv (set whenever type 38/56 arrives or HrvScreen
    // receives data). This means the tile is never blank after the first measurement.
    final hrv = liveData?['hrv'] ?? liveData?['HRV'] ?? BraceletChannel.lastKnownHrv;
    final spo2 =
        liveData?['spo2'] ??
        liveData?['oxygen'] ??
        liveData?['Oxygen'] ??
        liveData?['SPO2'] ??
        BraceletChannel.lastKnownSpo2;
    final systolic = liveData?['systolic'] ?? liveData?['Systolic'];
    final diastolic = liveData?['diastolic'] ?? liveData?['Diastolic'];
    final temp = liveData?['temperature'] ?? liveData?['Temperature'];
    final stress = liveData?['stress'] ?? liveData?['Stress'];

    // Formatting for display: use "--" for no reading so we don't show fake values when bracelet not worn.
    final hrVal = _validHeartRate(hr);
    final hrvVal = (hrv != null && (hrv as num) > 0) ? hrv : null;
    final spo2Val = _validSpo2(spo2);
    final tempVal = _validTemp(temp);
    final hrStr = hrVal != null ? '${hrVal is int ? hrVal : hrVal.toInt()}' : '--';
    final hrvStr = hrvVal != null ? '$hrvVal' : '--';
    final spo2Str = spo2Val != null ? '${spo2Val is int ? spo2Val : spo2Val.toInt()}' : '--';
    final bpStr = (systolic != null && diastolic != null &&
        (systolic as num) > 0 && (diastolic as num) > 0)
        ? '$systolic/$diastolic'
        : '--';
    final tempStr = tempVal != null ? tempVal.toStringAsFixed(1) : '--';
    final stressStr = (stress != null && (stress as num) >= 0) ? '$stress' : '--';

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
            MaterialPageRoute(builder: (_) => StressScreen(channel: channel)),
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
