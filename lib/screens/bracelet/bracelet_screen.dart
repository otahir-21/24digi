import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/bracelet_alias_storage.dart';
import '../../bracelet/bracelet_device_storage.dart';
import '../../bracelet/bracelet_verbose_log.dart';
import '../../bracelet/data/bracelet_data_parser.dart';
import '../../bracelet/data/models/live_health_metrics.dart';
import '../../bracelet/hydration_storage.dart';
import '../../bracelet/sleep_storage.dart';
import '../../bracelet/activity_storage.dart';
import '../../bracelet/live_activity_storage.dart';
import '../../bracelet/weekly_data_storage.dart';
import '../../bracelet/bracelet_metrics_cache.dart';
import '../../services/bracelet_firestore_sync.dart';
import '../../services/activity_predictions_service.dart';
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
import '../../widgets/digi_pill_header.dart';
import '../../providers/navigation_provider.dart';
import '../../bracelet/bracelet_dashboard_typography.dart';

// BraceletScreen
// ─────────────────────────────────────────────────────────────────────────────
class BraceletScreen extends StatefulWidget {
  /// Optional initial data (e.g. from search screen when navigating after first realtime packet).
  final Map<String, dynamic>? initialRealtimeData;

  const BraceletScreen({super.key, this.initialRealtimeData});

  @override
  State<BraceletScreen> createState() => _BraceletScreenState();
}

class _BraceletScreenState extends State<BraceletScreen>
    with RouteAware, WidgetsBindingObserver {
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
  /// Pulls type-25-style totals every second while walking/running so Progress stays live; type ~24 also streams ~1 Hz.
  static const Duration _liveTotalsPollInterval = Duration(seconds: 1);
  Timer? _liveTotalsPollTimer;
  /// HRV, SpO2, activity mode on a slower cadence to limit BLE load.
  Timer? _auxiliaryBraceletPollTimer;
  /// Re-sends startRealtime(1) so type 24 carries real step/distance/cal when the band updates (mode 2 often zeros them).
  Timer? _realtimeStreamRestartTimer;
  bool _routeObserverSubscribed = false;
  bool _livePollingActive = false;
  bool _realtimeStreamRestartTimerActive = false;
  /// Bump when we receive new data so UI keys change and widgets rebuild.
  int _dataVersion = 0;
  /// [mergeLiveData] is expensive; cache until inputs change (version, map identity, BP, fallbacks).
  int? _mergeCacheTag;
  LiveHealthMetrics? _mergeCache;
  /// When we last received type 24/25 from device (for "Last updated" in UI).
  DateTime? _lastDataUpdateTime;
  /// Realtime stability: startRealtime(1) only once per connected session; reset on disconnect.
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

  /// Fires every 15 minutes while connected to upload latest cache to Firestore (cooldown still enforced in service).
  Timer? _firebaseBraceletSyncTimer;

  /// Type-27 sleep fragments buffered until debounce fires; then parsed as one merged session.
  final List<Map<String, dynamic>> _sleepRecordsBuffer = [];
  static const Duration _sleepBatchDebounce = Duration(milliseconds: 800);
  Timer? _sleepBatchTimer;
  /// Incremented each time we send requestSleepData(); responses are tied to this cycle.
  int _sleepRequestCycle = 0;
  /// Cycle id for which we are currently collecting type-27 packets; null until first request.
  int? _activeSleepRequestCycle;

  /// When BLE maps are empty, show last persisted steps/distance/calories (survives disconnect / side button BLE drop).
  Map<String, dynamic>? _cachedOfflineTotals;

  /// Throttle extra [requestTotalActivityData] when type 24 sends zeros for daily totals (HR/temp still update).
  DateTime? _lastTotalActivityNudgeForZeros;
  static const Duration _totalActivityNudgeCooldown = Duration(seconds: 4);

  /// Space out method-channel / BLE writes so iOS does not stack many SDK commands in one runloop tick
  /// (helps with intermittent DartWorker crashes in debug on some devices).
  static const Duration _nativeBraceletCmdGap = Duration(milliseconds: 280);
  Future<void> _pauseNativeBraceletCmd() =>
      Future<void>.delayed(_nativeBraceletCmdGap);

  @override
  void initState() {
    super.initState();
    braceletVerboseLog(
      '[Bracelet Stream] dashboard: initState channel=${_channel.hashCode}',
    );
    if (widget.initialRealtimeData != null && widget.initialRealtimeData!.isNotEmpty) {
      _realtimeData = BraceletDataParser.shallowMergeDataProperty(
        Map<String, dynamic>.from(widget.initialRealtimeData!),
      );
    }
    _listenRealtime();
    // Same as activity screen: start realtime stream immediately so type 24 keeps flowing while dashboard is visible.
    braceletVerboseLog(
      '[Bracelet Stream] dashboard: startRealtime(1) caller=initState channel=${_channel.hashCode}',
    );
    _channel.startRealtime(RealtimeType.step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().firebaseUser?.uid;
      unawaited(_bootstrapLocalBraceletCache(uid));
    });
    _verifyConnectionAndRestoreOfflineIfDisconnected();
    // If already connected (e.g. reopen after restart), run on-connected logic immediately.
    _runOnConnectedIfConnected();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_onBraceletSectionResumed());
    }
  }

  /// New calendar day or cold resume: refresh sleep once; nudge totals if connected.
  Future<void> _onBraceletSectionResumed() async {
    if (!mounted) return;
    try {
      final st = await _channel.getConnectionState();
      if (st['connected'] != true) return;
      final uid = BraceletMetricsCache.instance.currentUid;
      if (await BraceletMetricsCache.needsSleepFetchForNewWallDay(uid)) {
        braceletVerboseLog('[Bracelet] app resumed — new wall day, requestSleepData');
        _requestSleepData();
      }
      unawaited(_pollLiveTotalsQuick());
    } catch (_) {}
  }

  Future<void> _bootstrapLocalBraceletCache(String? uid) async {
    await BraceletMetricsCache.instance.load(uid);
    await HydrationStorage.load(uid);
    // Load the alias for the currently connected device, if any.
    try {
      final st = await _channel.getConnectionState();
      if (st['connected'] == true) {
        final id = st['identifier'] as String?;
        if (id != null && id.isNotEmpty) {
          await BraceletAliasStorage.load(id);
        }
      }
    } catch (_) {}
    if (!mounted) return;
    BraceletMetricsCache.instance.applyToMemoryStores();
    setState(() {
      _cachedOfflineTotals = BraceletMetricsCache.instance.todayTotals;
    });
  }

  /// If BLE is not connected after startup, keep sleep/history from disk and only clear live stream fields.
  Future<void> _verifyConnectionAndRestoreOfflineIfDisconnected() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    try {
      final state = await _channel.getConnectionState();
      if (state['connected'] != true && mounted) {
        setState(() {
          _clearLiveStreamingState();
          _cachedOfflineTotals = BraceletMetricsCache.instance.todayTotals;
        });
      }
    } catch (_) {}
  }

  /// Run startRealtime, requestTotalActivityData, startSpo2Monitoring and timers. Only call after connectionState == 'connected'.
  /// Run only once per session so we don't flood the device and break the type 24 stream (activity screen only sends startRealtime once).
  /// Pull automatic SpO₂ history (type 42) so the dashboard has a value when type 24 omits Blood_oxygen.
  void _scheduleAutomaticSpo2HistoryFetch(Duration delay) {
    Future.delayed(delay, () async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] != true) return;
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.requestAutomaticSpo2History();
        braceletVerboseLog('[Bracelet SpO2] requestAutomaticSpo2History after ${delay.inSeconds}s');
      } catch (_) {}
    });
  }

  Future<void> _onConnected() async {
    if (_onConnectedRunning) {
      braceletVerboseLog('[Bracelet] _onConnected SKIPPED (already running)');
      return;
    }
    if (_startRealtimeCalledForSession) {
      braceletVerboseLog('[Bracelet] _onConnected SKIPPED (already ran this session)');
      return;
    }
    _onConnectedRunning = true;
    try {
      if (!mounted) return;
      _liveTotalsPollTimer?.cancel();
      _auxiliaryBraceletPollTimer?.cancel();
      _realtimeStreamRestartTimer?.cancel();
      _livePollingActive = false;
      _realtimeStreamRestartTimerActive = false;
      // No delay: request data immediately so dashboard shows data right after pair (Bug 1) and type 24 stream starts for live Progress (Bug 2).
      if (!mounted) return;
      try {
        braceletVerboseLog(
          '[Bracelet Stream] dashboard: startRealtime(1) caller=_onConnected channel=${_channel.hashCode}',
        );
        await _channel.startRealtime(RealtimeType.step);
        if (!mounted) return;
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.startHeartRateMonitoring();
        if (!mounted) return;
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.startSpo2Monitoring();
        if (!mounted) return;
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.startTemperatureMonitoring();
        if (!mounted) return;
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.requestTotalActivityData();
        if (!mounted) return;
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.requestDetailActivityData();
        if (!mounted) return;
        braceletVerboseLog('[Bracelet Sleep] requestSleepData() in _onConnected');
        _requestSleepData();
      } catch (e, st) {
        if (kDebugMode) debugPrint('[Bracelet SDK] _onConnected error: $e $st');
      }
      if (!mounted) return;
      braceletVerboseLog('[Bracelet] _onConnected commands sent at ${DateTime.now()}');
      _startRealtimeCalledForSession = true;
      // Reload alias so the device name chip is always correct after reconnect.
      try {
        final connSt = await _channel.getConnectionState();
        final connId = connSt['identifier'] as String?;
        if (connId != null && connId.isNotEmpty) {
          await BraceletAliasStorage.load(connId);
        }
      } catch (_) {}
      _startLivePollingTimers();
      _startRealtimeStreamRestartTimer();
      _startFirebaseBraceletPeriodicSync();
      Future.delayed(const Duration(seconds: 4), () async {
        if (!mounted) return;
        try {
          final state = await _channel.getConnectionState();
          if (state['connected'] == true) {
            await _channel.requestTemperatureData();
          }
        } catch (_) {}
      });
      // Type 24 often has no Blood_oxygen until a live reading; history (dataType 42) fills the tile.
      _scheduleAutomaticSpo2HistoryFetch(const Duration(seconds: 6));
      // One-time retry if no data yet: only startRealtime + requestTotalActivityData so we don't flood device.
      Future.delayed(const Duration(seconds: 2), () async {
        if (!mounted) return;
        try {
          final state = await _channel.getConnectionState();
          if (state['connected'] == true &&
              (_realtimeData == null || _totalActivityData == null)) {
            braceletVerboseLog(
              '[Bracelet] retry (no data yet): startRealtime + requestTotalActivityData',
            );
            await _channel.startRealtime(RealtimeType.step);
            await _pauseNativeBraceletCmd();
            if (!mounted) return;
            await _channel.startHeartRateMonitoring();
            await _pauseNativeBraceletCmd();
            if (!mounted) return;
            await _channel.startSpo2Monitoring();
            await _pauseNativeBraceletCmd();
            if (!mounted) return;
            await _channel.startTemperatureMonitoring();
            await _pauseNativeBraceletCmd();
            if (!mounted) return;
            await _channel.requestTotalActivityData();
            await _pauseNativeBraceletCmd();
            if (!mounted) return;
            await _channel.requestDetailActivityData();
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
    // User came back: sync latest from detail screens (e.g. SpO2), refresh "Last updated", resume stream.
    if (mounted) {
      setState(() {
        final spo2 = BraceletChannel.lastKnownSpo2;
        if (spo2 != null && spo2 > 0 && spo2 <= 100) {
          _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
          _realtimeData!['spo2'] = spo2;
          _realtimeData!['Blood_oxygen'] = spo2;
        }
        _lastDataUpdateTime = DateTime.now();
        _dataVersion++;
      });
    }
    unawaited(() async {
      await _channel.startRealtime(RealtimeType.step);
      await _pauseNativeBraceletCmd();
      if (!mounted) return;
      await _channel.startSpo2Monitoring();
      await _pauseNativeBraceletCmd();
      if (!mounted) return;
      await _channel.startTemperatureMonitoring();
    }());
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) unawaited(_channel.requestTemperatureData());
    });
    _scheduleAutomaticSpo2HistoryFetch(const Duration(seconds: 3));
    braceletVerboseLog('[Bracelet Sleep] requestSleepData() on didPopNext');
    _requestSleepData();
  }

  @override
  void didPop() {
    // User left the bracelet section. Pause polling and stop device realtime to save battery.
    _pauseRealtime();
  }

  void _pauseRealtime() {
    _livePollingActive = false;
    _realtimeStreamRestartTimerActive = false;
    _totalActivityTimer?.cancel();
    _totalActivityTimer = null;
    _liveTotalsPollTimer?.cancel();
    _liveTotalsPollTimer = null;
    _auxiliaryBraceletPollTimer?.cancel();
    _auxiliaryBraceletPollTimer = null;
    _realtimeStreamRestartTimer?.cancel();
    _realtimeStreamRestartTimer = null;
    _stopFirebaseBraceletPeriodicSync();
    try {
      _channel.stopRealtime();
    } catch (_) {}
    try {
      _channel.stopSpo2Monitoring();
    } catch (_) {}
    try {
      _channel.stopTemperatureMonitoring();
    } catch (_) {}
  }

  void _startFirebaseBraceletPeriodicSync() {
    _firebaseBraceletSyncTimer?.cancel();
    final uid = BraceletMetricsCache.instance.currentUid;
    unawaited(BraceletFirestoreSync.syncFromLocalCache(uid));
    _firebaseBraceletSyncTimer = Timer.periodic(
      BraceletFirestoreSync.minInterval,
      (_) {
        final u = BraceletMetricsCache.instance.currentUid;
        unawaited(BraceletFirestoreSync.syncFromLocalCache(u));
      },
    );
  }

  void _stopFirebaseBraceletPeriodicSync() {
    _firebaseBraceletSyncTimer?.cancel();
    _firebaseBraceletSyncTimer = null;
  }

  /// ~1 Hz: daily totals from band for live Progress card (Firestore unchanged — 15m sync only).
  Future<void> _pollLiveTotalsQuick() async {
    if (!mounted) return;
    try {
      final state = await _channel.getConnectionState();
      if (state['connected'] == true) {
        await _channel.requestTotalActivityData();
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.requestDetailActivityData();
      }
      if (mounted && _lastDataUpdateTime != null) {
        setState(() {});
      }
    } catch (_) {}
  }

  /// Slower BLE batch: HRV + activity list only. SpO2 history is **not** repeated here (it floods BLE with large type-42 batches); requested once in [_onConnected]. SpO2 still updates from live packets / SpO2 screen.
  Future<void> _pollAuxiliaryBraceletData() async {
    if (!mounted) return;
    try {
      final state = await _channel.getConnectionState();
      if (state['connected'] == true) {
        await _channel.startHeartRateMonitoring();
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.requestHRVData();
        await _pauseNativeBraceletCmd();
        if (!mounted) return;
        await _channel.requestActivityModeData();
      }
      if (!mounted) return;
      final t = DateTime.now().toString().substring(11, 19);
      final live = _mergedLiveData();
      if (live != null && live.isNotEmpty) {
        braceletVerboseLog(
          '[Bracelet] auxiliary poll @ $t -> step: ${live['step']}, hr: ${live['heartRate']}, hrv: ${live['hrv']}',
        );
      }
    } catch (_) {}
  }

  /// Live UI: 1s totals poll + 30s auxiliary; type 24 stream keeps steps/HR/temp ~1 Hz from the band.
  void _startLivePollingTimers() {
    if (_livePollingActive) return;
    _livePollingActive = true;
    _liveTotalsPollTimer?.cancel();
    _auxiliaryBraceletPollTimer?.cancel();
    unawaited(_pollLiveTotalsQuick());
    unawaited(_pollAuxiliaryBraceletData());
    _liveTotalsPollTimer = Timer.periodic(_liveTotalsPollInterval, (_) {
      unawaited(_pollLiveTotalsQuick());
    });
    _auxiliaryBraceletPollTimer = Timer.periodic(const Duration(seconds: 90), (_) {
      unawaited(_pollAuxiliaryBraceletData());
    });
  }

  /// Re-send startRealtime(1) so the band keeps emitting type 24 when steps change (not 1 Hz; avoids zeroed totals from mode 2).
  void _startRealtimeStreamRestartTimer() {
    if (_realtimeStreamRestartTimerActive) return;
    _realtimeStreamRestartTimerActive = true;
    _realtimeStreamRestartTimer?.cancel();
    void resend() async {
      if (!mounted) return;
      try {
        final state = await _channel.getConnectionState();
        if (state['connected'] == true) {
          braceletVerboseLog(
            '[Bracelet Stream] dashboard: startRealtime(1) keepalive channel=${_channel.hashCode}',
          );
          await _channel.startRealtime(RealtimeType.step);
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

  /// Clear live BLE-derived maps only. Sleep, weekly history, and disk cache stay intact.
  void _clearLiveStreamingState() {
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
    BraceletChannel.lastKnownHrv = null;
    BraceletChannel.lastKnownSpo2 = null;
    BraceletChannel.lastKnownTemperature = null;
    BraceletChannel.lastKnownHeartRate = null;
    BraceletChannel.lastKnownStress = null;
    _hrvSessionSamples.clear();
    _lastStepIncreaseTime = null;
    _lastSeenStepCount = null;
  }

  void _onBleDisconnected() {
    _pauseRealtime();
    setState(() {
      _clearLiveStreamingState();
      _cachedOfflineTotals = BraceletMetricsCache.instance.todayTotals;
    });
  }

  void _listenRealtime() {
    _subscription?.cancel();
    braceletVerboseLog(
      '[Bracelet Stream] dashboard: subscribe channel=${_channel.hashCode}',
    );
    _subscription = _channel.events.listen((BraceletEvent e) {
      if (!mounted) return;
      if (e.event == 'connectionState') {
        final state = e.data['state']?.toString();
        if (BraceletChannel.isDisconnectedState(state)) {
          _onBleDisconnected();
        } else if (state == 'connected' && !_startRealtimeCalledForSession) {
          // Only run once per connection; avoid duplicate commands when event fires again.
          _onConnected();
        }
        return;
      }
      if (e.event != 'realtimeData') return;
      final dataType = e.data['dataType'];
      var dic = e.data['dicData'];
      final typeEarly = BraceletDataParser.dataTypeAsInt(dataType);
      // Type 25/26 must still run handlers when dicData is empty/malformed (SDK sometimes omits keys).
      if (dic == null || dic is! Map) {
        if (typeEarly != 25 && typeEarly != 26) return;
        dic = <String, dynamic>{};
      }

      // Shallow ingest only — full [normalizeIncomingDic] on every ~1 Hz packet deep-copied the
      // whole tree and correlated with DartWorker EXC_BAD_ACCESS in debug on device.
      final dicFlat = Map<String, dynamic>.from(
        (dic as Map<Object?, Object?>).map(
          (k, v) => MapEntry(k?.toString() ?? '', v),
        ),
      );
      final dicMap = BraceletDataParser.shallowMergeDataProperty(dicFlat);

      final type = BraceletDataParser.dataTypeAsInt(dataType);
      final dicMapCopy = Map<String, dynamic>.from(dicMap);

      void applyUpdate() {
        if (!mounted) return;
        setState(() {
          _mergeCacheTag = null;
          if (type != null &&
              (type == 24 ||
                  type == 25 ||
                  type == 42 ||
                  type == 43 ||
                  type == 45 ||
                  type == 46 ||
                  type == 55 ||
                  type == 57 ||
                  type == 58 ||
                  type == 38 ||
                  type == 56 ||
                  type == 26)) {
            _lastDataUpdateTime = DateTime.now();
            unawaited(BraceletDeviceStorage.saveLastSync());
          }
          if (type != null && type == 25) {
            final parsed = BraceletDataParser.parseTotalActivityData(dicMapCopy);
            if (parsed != null) {
              _totalActivityData = BraceletDataParser.mergeActivityTotalsPreferHigher(
                _totalActivityData,
                parsed,
              );
              braceletVerboseLog(
                '[Bracelet] type 25 total activity -> step=${parsed['step']}, distance=${parsed['distance']}, calories=${parsed['calories']}',
              );
            } else {
              braceletVerboseLog(
                '[Bracelet] type 25 parseTotalActivityData null; keys=${dicMapCopy.keys.join(', ')}',
              );
            }
            if (ActivityStorage.todaySessions.isEmpty) {
              final fallback = _buildTodayActivityFallback();
              if (fallback != null) ActivityStorage.updateSessions([fallback]);
            }
          } else if (type != null && type == 26) {
            final parsed = BraceletDataParser.parseDetailActivityAggregateForToday(dicMapCopy);
            if (parsed != null) {
              _totalActivityData = BraceletDataParser.mergeActivityTotalsPreferHigher(
                _totalActivityData,
                parsed,
              );
              braceletVerboseLog(
                '[Bracelet] type 26 detail activity -> steps=${parsed['step']}, dist=${parsed['distance']}, cal=${parsed['calories']}',
              );
            }
          } else if (type != null && type == 27) {
            _bufferSleepRecords(dicMapCopy);
          } else if (type != null && type == 30) {
            final _t = DateTime.now().toString().substring(11, 19);
            braceletVerboseLog('[Bracelet SDK] @ $_t ActivityModeData (30) -> $dicMapCopy');
            final latest = BraceletDataParser.parseActivityModeDataLatest(dicMapCopy);
            if (latest != null) {
              _latestActivityData = latest;
            }
            List<Map<String, dynamic>> todayList = BraceletDataParser.parseActivityModeDataTodayList(dicMapCopy);
            if (todayList.isEmpty) {
              final fallback = _buildTodayActivityFallback();
              if (fallback != null) todayList = [fallback];
            }
            ActivityStorage.updateSessions(todayList);
            BraceletMetricsCache.instance.recordActivitySessions(todayList);
            unawaited(BraceletMetricsCache.instance.scheduleFlushToDisk());
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
            final _t = DateTime.now().toString().substring(11, 19);
            braceletVerboseLog(
              '[Bracelet SDK] @ $_t HRV (type $type) -> hrv: $hrvMs, stress: ${dicMapCopy['Stress'] ?? dicMapCopy['stress']}',
            );
            _applySpo2FromPacketToRealtime(dicMapCopy, removeOnZero: false);
          } else if (type != null && (type == 42 || type == 43 || type == 57)) {
            // Dedicated SpO2 types: 42 AutomaticSpo2Data, 43 ManualSpo2Data, 57 DeviceMeasurement_Spo2
            // iOS may put value in top-level or under dicData['Data'] – use shared extractor.
            final spo2Val = BraceletDataParser.extractSpo2FromDicData(dicMapCopy);
            final _t = DateTime.now().toString().substring(11, 19);
            final hasData = dicMapCopy.containsKey('Data') || dicMapCopy.containsKey('data');
            braceletVerboseLog(
              '[Bracelet SDK] @ $_t SpO2 received type=$type keys=${dicMapCopy.keys.join(', ')} hasData=$hasData -> parsed spo2=$spo2Val',
            );
            if (spo2Val != null && spo2Val > 0 && spo2Val <= 100) {
              _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
              _realtimeData!['Blood_oxygen'] = spo2Val;
              _realtimeData!['spo2'] = spo2Val;
              BraceletChannel.lastKnownSpo2 = spo2Val;
              final _t2 = DateTime.now().toString().substring(11, 19);
              braceletVerboseLog('[Bracelet SDK] @ $_t2 SpO2 (type $type) -> $spo2Val%');
            }
          } else if (type != null && (type == 45 || type == 46)) {
            _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
            _realtimeData!.addAll(dicMapCopy);
            final tempHist = BraceletDataParser.extractTemperatureFromDicData(dicMapCopy);
            if (tempHist != null) {
              _realtimeData!['temperature'] = tempHist;
              BraceletChannel.lastKnownTemperature = tempHist;
            }
            _applySpo2FromPacketToRealtime(dicMapCopy, removeOnZero: false);
          } else if (type != null && type == 58) {
            _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
            _realtimeData!.addAll(dicMapCopy);
            final tempLive = BraceletDataParser.extractTemperatureFromDicData(dicMapCopy);
            if (tempLive != null) {
              _realtimeData!['temperature'] = tempLive;
              BraceletChannel.lastKnownTemperature = tempLive;
            }
            _applySpo2FromPacketToRealtime(dicMapCopy, removeOnZero: false);
          } else {
            _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
            _realtimeData!.addAll(dicMapCopy);
            if (type != null && type == 24) {
              final step24 = dicMapCopy['step'] ?? dicMapCopy['Step'];
              braceletVerboseLog(
                '[Bracelet Stream] dashboard received type 24 channel=${_channel.hashCode} step=$step24',
              );
              final hrv24 = BraceletDataParser.extractHrvFromMap(dicMapCopy);
              if (hrv24 != null) {
                _realtimeData!['hrv'] = hrv24;
                BraceletChannel.lastKnownHrv = hrv24;
              }
              // SpO2 in type 24: deep-scan **packet** only; clear stale reading on explicit 0 from band.
              _applySpo2FromPacketToRealtime(dicMapCopy, removeOnZero: true);
              final tempFrom24 = BraceletDataParser.extractTemperatureFromDicData(dicMapCopy);
              if (tempFrom24 != null) {
                _realtimeData!['temperature'] = tempFrom24;
                BraceletChannel.lastKnownTemperature = tempFrom24;
              }
            } else {
              _applySpo2FromPacketToRealtime(dicMapCopy, removeOnZero: false);
            }
          }
          if (type == 52 || type == 70) {
            final _t = DateTime.now().toString().substring(11, 19);
            braceletVerboseLog(
              '[Bracelet SDK] @ $_t dataType $type (ECG/ppg) -> keys: ${dicMapCopy.keys.join(', ')}',
            );
          }
          final bp = BraceletDataParser.parseBloodPressure(dicMapCopy);
          if (bp != null) {
            _bpSystolic = bp.$1;
            _bpDiastolic = bp.$2;
            final _t = DateTime.now().toString().substring(11, 19);
            braceletVerboseLog(
              '[Bracelet SDK] @ $_t Blood pressure -> systolic: ${bp.$1}, diastolic: ${bp.$2}',
            );
          }
          // Types 24/25/26 carry step/distance/calories; SpO₂ packets must not overwrite cache with 0.
          if (type != null && (type == 24 || type == 25 || type == 26)) {
            final progressMap = _progressLiveData();
            if (progressMap != null) {
              final step = _numToDouble(progressMap['step']) ?? 0.0;
              final distRaw =
                  _numToDouble(progressMap['distance'] ?? progressMap['Distance']);
              final distKm = distRaw != null
                  ? (distRaw > 100 ? distRaw / 1000.0 : distRaw)
                  : 0.0;
              final cal = _numToDouble(progressMap['calories']) ?? 0.0;
              _stepsHistory.add(step);
              if (_stepsHistory.length > _maxSessionHistory) _stepsHistory.removeAt(0);
              _distanceHistory.add(distKm);
              if (_distanceHistory.length > _maxSessionHistory) _distanceHistory.removeAt(0);
              _caloriesHistory.add(cal);
              if (_caloriesHistory.length > _maxSessionHistory) _caloriesHistory.removeAt(0);
              WeeklyDataStorage.updateTodayDistance(distKm, step.round());
              final stepsInt = step.round();
              BraceletMetricsCache.instance.recordTodayTotals(
                steps: stepsInt,
                distanceKm: distKm,
                calories: cal,
              );
              _cachedOfflineTotals = BraceletMetricsCache.instance.todayTotals;
              unawaited(BraceletMetricsCache.instance.scheduleFlushToDisk());
            }
            if (type == 24) {
              final r = _realtimeData;
              if (r != null) {
                final st = BraceletDataParser.intFrom(
                  BraceletDataParser.firstOf(r, ['step', 'Step']),
                );
                final dist = BraceletDataParser.toDouble(
                  BraceletDataParser.firstOf(r, ['distance', 'Distance']),
                );
                final cal = BraceletDataParser.toDouble(
                  BraceletDataParser.firstOf(r, ['calories', 'Calories']),
                );
                final empty = (st == null || st == 0) &&
                    (dist == null || dist < 1e-6) &&
                    (cal == null || cal < 1e-6);
                if (empty) _maybeNudgeTotalWhenType24TotalsEmpty();
              }
            }
          }
          if (type != null && (type == 24 || type == 25 || type == 26)) {
            final step24 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(_realtimeData, ['step', 'Step']));
            final step25 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(_totalActivityData, ['step', 'Step']));
            final currentStep =
                (step24 != null && step24 > 0) ? step24 : (step25 ?? step24);
            if (currentStep != null && currentStep > 0) {
              if (_lastSeenStepCount != null && currentStep > _lastSeenStepCount!) {
                _lastStepIncreaseTime = DateTime.now();
              }
              _lastSeenStepCount = currentStep;
            }
          }
          _syncLastKnownVitalsFromMerge();
          // Write fresh vitals + activity to daily history (30-min cooldown) so Weekly/Monthly charts populate.
          final uid = BraceletMetricsCache.instance.currentUid;
          if (uid != null) {
            final todayTotals = BraceletMetricsCache.instance.todayTotals;
            unawaited(BraceletFirestoreSync.writeVitalsToHistory(
              uid: uid,
              heartRateBpm: BraceletChannel.lastKnownHeartRate,
              hrvMs: BraceletChannel.lastKnownHrv,
              spo2Percent: BraceletChannel.lastKnownSpo2,
              stressIndex: BraceletChannel.lastKnownStress,
              temperatureC: BraceletChannel.lastKnownTemperature,
              steps: BraceletDataParser.intFrom(todayTotals?['step'] ?? todayTotals?['Step']),
              distanceKm: BraceletDataParser.toDouble(todayTotals?['distance'] ?? todayTotals?['Distance']),
              calories: BraceletDataParser.toDouble(todayTotals?['calories'] ?? todayTotals?['Calories']),
            ));
          }
          _dataVersion++;
        });
      }

      // Single setState per packet via [applyUpdate]. A second post-frame setState here doubled
      // rebuild/merge work ~1 Hz+ and correlated with DartWorker EXC_BAD_ACCESS on iOS debug.
      applyUpdate();
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
      braceletVerboseLog(
        '[Sleep 27 Batch] cycle=$cycleForThisBatch buffered=${list.length} deduped=$dedupedCount',
      );
      if (parsed != null) {
        final map = parsed.toMap();
        SleepStorage.updateFromMap(map);
        final nk = SleepStorage.nightKeyFromMap(map);
        if (nk != null) {
          BraceletMetricsCache.instance.recordSleepNight(nk, map);
        }
        unawaited(BraceletMetricsCache.instance.scheduleFlushToDisk());
        unawaited(
          BraceletMetricsCache.markSleepFetchedWallDay(
            BraceletMetricsCache.instance.currentUid,
          ),
        );
        _realtimeData = Map<String, dynamic>.from(_realtimeData ?? {});
        _realtimeData!['sleep'] = map;
        if (mounted) setState(() {});
      }
    });
  }

  /// Parse SpO₂ from the current BLE packet (structural extractors; no unbounded deep walk), then copy to [_realtimeData].
  /// [mergeLiveData] must not deep-scan accumulated state (DartWorker crashes on iOS debug).
  void _applySpo2FromPacketToRealtime(
    Map<String, dynamic> packet, {
    required bool removeOnZero,
  }) {
    final rt = _realtimeData;
    if (rt == null) return;
    final s = BraceletDataParser.extractSpo2FromDicData(
      packet,
      allowDeepScan: false,
    );
    if (s != null && s > 0 && s <= 100) {
      rt['spo2'] = s;
      rt['Blood_oxygen'] = s;
      BraceletChannel.lastKnownSpo2 = s;
    } else if (removeOnZero && s == 0) {
      rt.remove('spo2');
      rt.remove('Blood_oxygen');
      rt.remove('blood_oxygen');
    }
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

  /// Prefer positive type-24 value; else type 25; else cache. Literal `0` from type 24 must not block type 25.
  static int? _pickDailyInt(int? from24, int? from25, int? fromCache) {
    if (from24 != null && from24 > 0) return from24;
    if (from25 != null && from25 > 0) return from25;
    return from24 ?? from25 ?? fromCache;
  }

  static double? _pickDailyDouble(double? from24, double? from25, double? fromCache) {
    bool pos(double? x) => x != null && x > 1e-9;
    if (pos(from24)) return from24;
    if (pos(from25)) return from25;
    return from24 ?? from25 ?? fromCache;
  }

  void _maybeNudgeTotalWhenType24TotalsEmpty() {
    final now = DateTime.now();
    if (_lastTotalActivityNudgeForZeros != null &&
        now.difference(_lastTotalActivityNudgeForZeros!) < _totalActivityNudgeCooldown) {
      return;
    }
    _lastTotalActivityNudgeForZeros = now;
    unawaited(_nudgeTotalActivityAsync());
  }

  Future<void> _nudgeTotalActivityAsync() async {
    await _pauseNativeBraceletCmd();
    if (!mounted) return;
    await _channel.requestTotalActivityData();
    await _pauseNativeBraceletCmd();
    if (!mounted) return;
    await _channel.requestDetailActivityData();
  }

  /// Today's activity from type 24/25 when there is no type 30 (sport session).
  /// Shown as "Walking" / "Today's activity" with today's date so recent walks appear in Latest Activity
  /// even when the device doesn't send type 30 for auto-detected walks. Not "in progress" — date is today.
  Map<String, dynamic>? _buildTodayActivityFallback() {
    final r = _realtimeData;
    final t = _totalActivityData;
    final step = _pickDailyInt(
      BraceletDataParser.intFrom(BraceletDataParser.firstOf(r, ['step', 'Step'])),
      BraceletDataParser.intFrom(BraceletDataParser.firstOf(t, ['step', 'Step'])),
      null,
    );
    final distance = _pickDailyDouble(
      BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['distance', 'Distance'])),
      BraceletDataParser.toDouble(
        BraceletDataParser.firstOf(t, ['distance', 'Distance', 'totalDistance', 'TotalDistance']),
      ),
      null,
    );
    final calories = _pickDailyDouble(
      BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['calories', 'Calories'])),
      BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, ['calories', 'Calories'])),
      null,
    );
    final exerciseMin = BraceletDataParser.intFrom(
      r?['exerciseMinutes'] ?? r?['ExerciseMinutes'] ?? r?['activeMinutes'] ?? r?['ActiveMinutes'] ??
      t?['exerciseMinutes'] ?? t?['ExerciseMinutes'] ?? t?['activeMinutes'] ?? t?['ActiveMinutes'],
    );
    final hasActivity = (step != null && step > 0) ||
        (exerciseMin != null && exerciseMin > 0) ||
        (distance != null && distance > 0);
    if (!hasActivity) return null;
    // Only show the Walking fallback when the device reports >= 10 active minutes;
    // shorter bursts (a few steps, brief movement) are not counted as an activity.
    if (exerciseMin == null || exerciseMin < 10) return null;
    final now = DateTime.now();
    final dateStr = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    int activeMin = exerciseMin ?? 0;
    if (activeMin <= 0 && step != null && step > 0) {
      activeMin = (step / 100).clamp(1, 180).toInt();
    }
    return <String, dynamic>{
      'sportName': 'Walking',
      'date': dateStr,
      'activeMinutes': activeMin,
      'step': step,
      'distance': distance,
      'calories': calories,
      'pace': null,
    };
  }

  int _mergeInputTag() {
    final t = BraceletChannel.lastKnownTemperature;
    return Object.hash(
      _dataVersion,
      identityHashCode(_realtimeData),
      identityHashCode(_totalActivityData),
      _bpSystolic,
      _bpDiastolic,
      BraceletChannel.lastKnownSpo2,
      t != null ? (t * 1000).round() : 0,
    );
  }

  LiveHealthMetrics? _liveMetricsMerged() {
    final tag = _mergeInputTag();
    if (_mergeCacheTag != null && _mergeCacheTag == tag) return _mergeCache;
    _mergeCache = BraceletDataParser.mergeLiveData(
      _realtimeData,
      _totalActivityData,
      _bpSystolic,
      _bpDiastolic,
      fallbackSpo2: BraceletChannel.lastKnownSpo2,
      fallbackTemperature: BraceletChannel.lastKnownTemperature,
    );
    _mergeCacheTag = tag;
    return _mergeCache;
  }

  void _syncLastKnownVitalsFromMerge() {
    final m = _liveMetricsMerged();
    if (m == null) return;
    if (m.spo2 != null && m.spo2! > 0 && m.spo2! <= 100) {
      BraceletChannel.lastKnownSpo2 = m.spo2;
    }
    if (m.temperature != null) {
      BraceletChannel.lastKnownTemperature = m.temperature;
    }
    if (m.heartRate != null && m.heartRate! >= 35 && m.heartRate! <= 220) {
      BraceletChannel.lastKnownHeartRate = m.heartRate;
    }
    if (m.stress != null && m.stress! >= 0 && m.stress! <= 100) {
      BraceletChannel.lastKnownStress = m.stress;
    }
  }

  /// Merge total activity with realtime; delegates to parser. Returns same map shape for ProgressCard / _HealthGrid.
  Map<String, dynamic>? _mergedLiveData() {
    final base = _liveMetricsMerged()?.toDisplayMap();
    final out = <String, dynamic>{
      if (base != null) ...base,
      if (BraceletChannel.lastKnownSpo2 != null &&
          BraceletChannel.lastKnownSpo2! > 0 &&
          BraceletChannel.lastKnownSpo2! <= 100) ...{
        'spo2': BraceletChannel.lastKnownSpo2,
        'Blood_oxygen': BraceletChannel.lastKnownSpo2,
      },
      if (BraceletChannel.lastKnownTemperature != null)
        'temperature': BraceletChannel.lastKnownTemperature,
    };
    // [toDisplayMap] can omit fields; hydration needs active/exercise minutes from raw maps.
    _copyMissingBraceletKeysInto(out);
    if (out.isEmpty) return null;
    return out;
  }

  /// Fills canonical keys from [_realtimeData] / [_totalActivityData] when merge output skipped them.
  /// Progress-first overlay on merged map so type-24 steps/calories win; merged fills SpO₂/temp/HRV gaps.
  /// Finally copies any missing keys from raw [_realtimeData]/[_totalActivityData] so hydration sees
  /// `activeMinutes` / `exerciseMinutes` exactly as the band sent them.
  Map<String, dynamic>? _combinedHealthTileMap(
    Map<String, dynamic>? progress,
    Map<String, dynamic>? merged,
  ) {
    final tile = <String, dynamic>{};
    if (merged != null) tile.addAll(merged);
    if (progress != null) tile.addAll(progress);
    void mergeRaw(Map<String, dynamic>? src) {
      if (src == null) return;
      for (final e in src.entries) {
        final k = e.key.toString();
        if (k.isEmpty) continue;
        if (!tile.containsKey(k) || tile[k] == null) {
          if (e.value != null) tile[k] = e.value;
        }
      }
    }

    mergeRaw(_realtimeData);
    mergeRaw(_totalActivityData);
    if (tile.isEmpty) return null;
    return tile;
  }

  void _copyMissingBraceletKeysInto(Map<String, dynamic> out) {
    final r = _realtimeData;
    final t = _totalActivityData;
    void fill(List<String> keys, String canonical) {
      if (out[canonical] != null) return;
      final v = BraceletDataParser.firstOf(r, keys) ?? BraceletDataParser.firstOf(t, keys);
      if (v != null) out[canonical] = v;
    }

    fill(['step', 'Step', 'steps', 'Steps'], 'step');
    fill(['calories', 'Calories'], 'calories');
    fill(['distance', 'Distance', 'mileage'], 'distance');
    fill(['activeMinutes', 'ActiveMinutes'], 'activeMinutes');
    fill(['exerciseMinutes', 'ExerciseMinutes'], 'exerciseMinutes');
    fill(['heartRate', 'HeartRate', 'hr', 'HR'], 'heartRate');
  }

  /// Progress-only data: step/distance/calories from type 24 (_realtimeData) when present, else type 25 (_totalActivityData). Same as activity screen — no stale merge.
  Map<String, dynamic>? _progressLiveData() {
    final base = _mergedLiveData();
    final r = _realtimeData;
    final t = _totalActivityData;
    final step24 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(r, ['step', 'Step', 'steps', 'Steps']));
    final step25 = BraceletDataParser.intFrom(BraceletDataParser.firstOf(t, [
      'step',
      'Step',
      'steps',
      'Steps',
      'totalStep',
      'TotalStep',
    ]));
    final dist24 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['distance', 'Distance', 'mileage']));
    final dist25 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, [
      'distance',
      'Distance',
      'totalDistance',
      'TotalDistance',
      'mileage',
    ]));
    final cal24 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(r, ['calories', 'Calories']));
    final cal25 = BraceletDataParser.toDouble(BraceletDataParser.firstOf(t, ['calories', 'Calories']));
    final cache = _cachedOfflineTotals;
    final step = _pickDailyInt(
      step24,
      step25,
      BraceletDataParser.intFrom(cache?['step'] ?? cache?['Step']),
    );
    final distance = _pickDailyDouble(
      dist24,
      dist25,
      BraceletDataParser.toDouble(cache?['distance'] ?? cache?['Distance']),
    );
    final calories = _pickDailyDouble(
      cal24,
      cal25,
      BraceletDataParser.toDouble(cache?['calories'] ?? cache?['Calories']),
    );
    // When daily totals from the band are still 0/null but type 30 sessions exist, show those (common before type 25 arrives).
    var stepOut = step;
    var distanceOut = distance;
    var caloriesOut = calories;
    if (stepOut == null || stepOut <= 0) {
      final ss = ActivityStorage.totalSteps;
      if (ss > 0) stepOut = ss;
    }
    if (distanceOut == null || distanceOut <= 1e-9) {
      final sd = ActivityStorage.totalDistanceKm;
      if (sd > 1e-9) distanceOut = sd;
    }
    if (caloriesOut == null || caloriesOut <= 1e-9) {
      final sc = ActivityStorage.totalCalories;
      if (sc > 1e-9) caloriesOut = sc;
    }
    if (stepOut != _lastLoggedProgressStep) {
      _lastLoggedProgressStep = stepOut;
      braceletVerboseLog(
        '[Bracelet Progress] type24 step=$step24 type25 step=$step25 -> final step=$stepOut (ProgressCard source)',
      );
    }
    if (base == null &&
        stepOut == null &&
        distanceOut == null &&
        caloriesOut == null) {
      return null;
    }
    final out = Map<String, dynamic>.from(base ?? {});
    if (stepOut != null) out['step'] = stepOut;
    if (distanceOut != null) out['distance'] = distanceOut;
    if (caloriesOut != null) out['calories'] = caloriesOut;
    return out;
  }

  @override
  void dispose() {
    braceletVerboseLog(
      '[Bracelet Stream] dashboard: dispose unsubscribe channel=${_channel.hashCode}',
    );
    if (_routeObserverSubscribed) {
      app.braceletRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    _sleepBatchTimer?.cancel();
    _sleepBatchTimer = null;
    _pauseRealtime();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    _subscription = null;
    unawaited(
      BraceletMetricsCache.instance.flushNowForUser(
        BraceletMetricsCache.instance.currentUid,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    // Display data: _mergedLiveData() for health grid / other tiles. Progress uses _progressLiveData() so step/distance/calories come from type 24 when present (same as activity screen).
    final liveData = _mergedLiveData();
    final progressLiveData = _progressLiveData();
    final healthTileData = _combinedHealthTileMap(progressLiveData, liveData);
    // stepKey changes only when step count changes — NOT on every BLE packet.
    // Including _dataVersion here previously caused the entire _HealthGrid to be
    // destroyed every ~1 Hz, which disposed InkWell mid-tap and broke navigation.
    final stepKey = '${progressLiveData?['step'] ?? liveData?['step'] ?? 0}';
    // Sleep/hydration tiles read [SleepStorage] / [HydrationStorage], not only [liveData] —
    // include them in the key so the grid refreshes when those stores change even if step count does not.
    final sleepTotal = SleepStorage.totalSleepMinutes ?? 0;
    final deepKey = SleepStorage.lastSleepData?['deepMinutes'] ?? 'x';
    final remKey = SleepStorage.lastSleepData?['remMinutes'] ?? 'x';
    // Prefer type 30 (sport session). Else show today's activity fallback only when steps increased recently (~25 min) so we don't show "Walking" when sitting.
    final fallback = _buildTodayActivityFallback();
    final showFallback = fallback != null &&
        _lastStepIncreaseTime != null &&
        DateTime.now().difference(_lastStepIncreaseTime!).inMinutes < 25;
    final latestActivityToShow = _latestActivityData ?? (showFallback ? fallback : null);

    return BraceletScaffold(
      customTopBar: DigiPillHeader(
        showBack: true,
        onBack: () => context.read<NavigationProvider>().setIndex(2),
      ),
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
          SizedBox(height: 12 * s),

          // ── Progress card: type-24-first data so it updates like activity screen ──
          ProgressCard(
            key: ValueKey<String>('progress_$stepKey'),
            s: s,
            liveData: progressLiveData ?? liveData,
            onTap: () => Navigator.of(context, rootNavigator: true).push(
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
                  color: AppColors.labelDim.withValues(alpha: 0.8),
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

          // ── Live Activity card (real-time when ActivitiesScreen is open) ──
          ListenableBuilder(
            listenable: LiveActivityStorage.revision,
            builder: (context, _) {
              if (!LiveActivityStorage.isLive) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 16 * s),
                child: _LiveActivityCard(s: s),
              );
            },
          ),

          // ── Latest Activity label ─────────────────────────────
          Text(
            'Latest Activity',
            style: BraceletDashboardTypography.text(
              fontSize: 13 * s,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10 * s),

          // ── Latest Activity card ──────────────────────────────
          LatestActivityCard(
            s: s,
            latestActivity: latestActivityToShow,
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ActivitiesScreen(
                  channel: _channel,
                  liveData: healthTileData,
                ),
              ),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Recovery Data button ──────────────────────────────
          RecoveryDataButton(
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const GeneralRecoveryScreen()),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Health metrics grid (ListenableBuilder: hydration is persisted + revision bumps on log water) ──
          ListenableBuilder(
            listenable: HydrationStorage.revision,
            builder: (context, _) {
              final hydInner =
                  '${HydrationStorage.currentLiters.toStringAsFixed(3)}_${HydrationStorage.goalLiters.toStringAsFixed(3)}';
              final gridKey =
                  'health_${stepKey}_sl${sleepTotal}_d${deepKey}_r${remKey}_h$hydInner';
              return _HealthGrid(
                key: ValueKey<String>(gridKey),
                s: s,
                liveData: healthTileData,
                channel: _channel,
              );
            },
          ),
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
    final p = BraceletDataParser.spo2PercentFromDevice(v);
    return p;
  }

  static num? _validTemp(dynamic v) {
    if (v == null) return null;
    final n = v is num ? v : (v is String ? num.tryParse(v) : null);
    if (n == null) return null;
    final d = n.toDouble();
    // Wrist/skin readings are often 32–37 °C; allow 25–45 after parser normalization.
    return (d >= 25 && d <= 45) ? n : null;
  }

  /// Deep/REM minutes for the small footer line — only when plausible (avoids corrupt SDK / wrong units).
  static int? _sanitizedStageMinutes(dynamic raw, {required int? totalSleepMin}) {
    if (raw == null) return null;
    final int? n = raw is int
        ? raw
        : (raw is num
            ? raw.round()
            : num.tryParse(raw.toString().trim())?.round());
    if (n == null || n < 1) return null;
    const maxReasonableStage = 12 * 60;
    if (n > maxReasonableStage) return null;
    if (totalSleepMin != null && totalSleepMin > 0 && n > totalSleepMin) {
      return null;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    // Current values from SDK
    final hr = liveData?['heartRate'] ?? liveData?['HeartRate'];
    // HRV: prefer live map, then fall back to the last known value cached in
    // BraceletChannel.lastKnownHrv (set whenever type 38/56 arrives or HrvScreen
    // receives data). This means the tile is never blank after the first measurement.
    final hrv = liveData?['hrv'] ?? liveData?['HRV'] ?? BraceletChannel.lastKnownHrv;
    // Prefer lastKnownSpo2 so returning from SpO2 inner screen shows the latest value.
    final spo2 =
        BraceletChannel.lastKnownSpo2 ??
        liveData?['spo2'] ??
        liveData?['Blood_oxygen'] ??
        liveData?['blood_oxygen'] ??
        liveData?['oxygen'] ??
        liveData?['Oxygen'] ??
        liveData?['SPO2'];
    final systolic = liveData?['systolic'] ?? liveData?['Systolic'];
    final diastolic = liveData?['diastolic'] ?? liveData?['Diastolic'];
    final temp = liveData?['temperature'] ??
        liveData?['Temperature'] ??
        BraceletChannel.lastKnownTemperature;
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
    final num? stressN = switch (stress) {
      null => null,
      num n => n,
      final o => num.tryParse(o.toString()),
    };
    final bool stressTileValid;
    final String stressStr;
    if (stressN != null && stressN >= 0 && stressN <= 100) {
      stressTileValid = true;
      stressStr = '${stressN.round()}';
    } else {
      stressTileValid = false;
      stressStr = '--';
    }

    const ic = 'assets/BracletIcons';
    // Only show sleep data if it's from last night — stale data from previous
    // nights must not appear on today's dashboard tile.
    final sleepIsRecent = SleepStorage.isFromLastNight;
    final totalSleepMin = sleepIsRecent ? SleepStorage.totalSleepMinutes : null;
    final sleepDataNow  = sleepIsRecent ? SleepStorage.lastSleepData : null;
    final deepRaw  = sleepDataNow?['deepMinutes'];
    final remRaw   = sleepDataNow?['remMinutes'];
    final deepMin  = _sanitizedStageMinutes(deepRaw, totalSleepMin: totalSleepMin);
    final remMin   = _sanitizedStageMinutes(remRaw,  totalSleepMin: totalSleepMin);
    final sleepValue = sleepIsRecent ? (SleepStorage.displayString ?? '--') : '--';
    final sleepUnit  = (deepMin != null && deepMin > 0) ? 'Deep' : '';
    final String? sleepSecondary;
    final Color? sleepSecondaryColor;
    if (deepMin != null && deepMin > 0) {
      sleepSecondary = '${deepMin}m deep';
      sleepSecondaryColor = const Color(0xFFFF5252);
    } else if (remMin != null && remMin > 0) {
      sleepSecondary = '${remMin}m REM';
      sleepSecondaryColor = BraceletDashboardColors.labelGrey;
    } else if (!sleepIsRecent && SleepStorage.lastSleepData != null) {
      // Has old sleep data — nudge user to wear bracelet tonight
      sleepSecondary = 'Wear bracelet tonight';
      sleepSecondaryColor = BraceletDashboardColors.labelGrey;
    } else {
      sleepSecondary = null;
      sleepSecondaryColor = null;
    }

    // ── Hydration ────────────────────────────────────────────────────────────
    // If user has manually logged water today, show that (actual).
    // Otherwise estimate how much they likely have drunk based on:
    //   • body weight (WHO: 33 ml/kg/day)
    //   • today's steps (activity bonus)
    //   • fraction of waking hours elapsed (7 am – 10 pm)
    final goalL = HydrationStorage.goalLiters;
    final curL  = HydrationStorage.currentLiters;

    final double hydDisplayL;
    final bool   hydIsEstimate;

    if (curL > 0) {
      // User has logged real water — use it.
      hydDisplayL  = curL;
      hydIsEstimate = false;
    } else {
      // Estimate based on profile + activity + time of day.
      final weightKg =
          context.read<AuthProvider>().profile?.weightKg ?? 70.0;
      final rawSteps = liveData?['step'] ?? liveData?['Step'] ??
          liveData?['steps'] ?? liveData?['Steps'];
      final todaySteps = BraceletDataParser.intFrom(rawSteps) ?? 0;

      // Daily target adjusted for activity.
      final dailyTargetL = ((weightKg * 0.033) +
              (todaySteps > 8000 ? 0.4 : todaySteps > 4000 ? 0.2 : 0.0))
          .clamp(1.5, 4.5);

      // Fraction of waking day (7 am – 10 pm = 15 h) that has elapsed.
      const wakingStartH = 7;
      const wakingHours  = 15.0;
      final hourNow      = DateTime.now().hour + DateTime.now().minute / 60.0;
      final wakeProgress = ((hourNow - wakingStartH) / wakingHours).clamp(0.0, 1.0);

      hydDisplayL   = double.parse(
          (dailyTargetL * wakeProgress).toStringAsFixed(1));
      hydIsEstimate = true;

      // Also update the stored goal so the inner screen shows the right target.
      if ((dailyTargetL - goalL).abs() > 0.05) {
        HydrationStorage.goalLiters = double.parse(dailyTargetL.toStringAsFixed(1));
      }
    }

    final effectiveGoal = HydrationStorage.goalLiters;
    final hydPct = effectiveGoal > 0
        ? ((hydDisplayL / effectiveGoal) * 100).round().clamp(0, 100)
        : 0;

    final hydrationValueStr = '$hydPct';
    const hydrationUnitStr  = '%';
    final hydSecondary = hydIsEstimate
        ? '~${hydDisplayL.toStringAsFixed(1)} / ${effectiveGoal.toStringAsFixed(1)} L'
        : '${hydDisplayL.toStringAsFixed(1)} / ${effectiveGoal.toStringAsFixed(1)} L';
    // Green if meeting/exceeding 50% of goal, red if below 30%, grey otherwise
    final Color hydSecondaryColor = hydPct >= 50
        ? const Color(0xFF4CAF50)
        : hydPct < 30
            ? const Color(0xFFFF5252)
            : BraceletDashboardColors.labelGrey;

    // Stress secondary: show stress index as "X%" in red when high
    final String? stressSecondary = stressTileValid ? '${stressN!.round()}%' : null;
    final Color? stressSecondaryColor = stressTileValid
        ? (stressN! > 50 ? const Color(0xFFFF5252) : const Color(0xFFFF5252))
        : null;

    // SPO2 secondary: show how far from 100% normal saturation
    final String? spo2Secondary = spo2Val != null
        ? '${(100 - spo2Val.toInt())}%'
        : null;
    final Color? spo2SecondaryColor = spo2Val != null && spo2Val < 95
        ? const Color(0xFFFF5252)
        : const Color(0xFFFF5252);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: BraceletMetricTileSpec.gridGap(s),
      crossAxisSpacing: BraceletMetricTileSpec.gridGap(s),
      childAspectRatio: BraceletMetricTileSpec.gridAspectWidthOverHeight,
      children: [
        HealthMetricCard(
          s: s,
          title: 'SLEEP',
          iconAsset: '$ic/sleep.png',
          value: sleepValue,
          unit: sleepUnit,
          secondaryValue: sleepSecondary,
          secondaryColor: sleepSecondaryColor,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => SleepScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HYDRATION',
          iconAsset: '$ic/hydration.png',
          value: hydrationValueStr,
          unit: hydrationUnitStr,
          secondaryValue: hydSecondary,
          secondaryColor: hydSecondaryColor,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => HydrationScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HEART RATE',
          iconAsset: '$ic/heartrate.png',
          value: hrStr,
          unit: 'BPM',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => HeartScreen(channel: channel, liveData: liveData),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'HRV',
          iconAsset: '$ic/hrv.png',
          value: hrvStr,
          unit: 'MS',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => HrvScreen(channel: channel, liveData: liveData)),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'STRESS',
          iconAsset: '$ic/stress.png',
          value: stressStr,
          unit: stressTileValid ? (stressN! > 50 ? 'HIGH' : 'LOW') : null,
          secondaryValue: stressSecondary,
          secondaryColor: stressSecondaryColor,
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(builder: (_) => StressScreen(channel: channel)),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'SPO2',
          iconAsset: '$ic/spo2.png',
          value: spo2Str,
          unit: '%',
          secondaryValue: spo2Secondary,
          secondaryColor: spo2SecondaryColor,
          onTap: () {
            final spo2Num = liveData?['spo2'] ?? liveData?['Blood_oxygen'] ?? liveData?['oxygen'] ?? BraceletChannel.lastKnownSpo2;
            final initialSpO2 = spo2Num != null ? BraceletDataParser.intFrom(spo2Num) : BraceletChannel.lastKnownSpo2;
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => Spo2Screen(channel: channel, initialSpO2: initialSpO2),
              ),
            );
          },
        ),
        HealthMetricCard(
          s: s,
          title: 'TEMPERATURE',
          iconAsset: '$ic/Thermometer.png',
          value: tempStr,
          unit: '°C',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (_) => TemperatureScreen(channel: channel),
            ),
          ),
        ),
        HealthMetricCard(
          s: s,
          title: 'BLOOD PRESSURE',
          titleMaxLines: 2,
          iconAsset: '$ic/bloodpresure.png',
          value: bpStr,
          unit: 'mmHg',
          onTap: () => Navigator.of(context, rootNavigator: true).push(
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

// ── _LiveActivityCard ─────────────────────────────────────────────────────────
class _LiveActivityCard extends StatefulWidget {
  final double s;
  const _LiveActivityCard({required this.s});

  @override
  State<_LiveActivityCard> createState() => _LiveActivityCardState();
}

class _LiveActivityCardState extends State<_LiveActivityCard> {
  late final Timer _durationTimer;

  @override
  void initState() {
    super.initState();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _durationTimer.cancel();
    super.dispose();
  }

  static String _activityIcon(String a) {
    switch (a) {
      case 'walking':   return '🚶';
      case 'running':   return '🏃';
      case 'cycling':   return '🚴';
      case 'treadmill': return '🏋️';
      case 'sitting':   return '🪑';
      case 'standing':  return '🧍';
      default:          return '🟢';
    }
  }

  static Color _activityColor(String a) {
    switch (a) {
      case 'running':
      case 'treadmill': return const Color(0xFFFF6B35);
      case 'cycling':   return const Color(0xFF00C8B4);
      case 'walking':   return const Color(0xFF4FC3F7);
      default:          return const Color(0xFF9E9E9E);
    }
  }

  static String _durationLabel(int secs) {
    if (secs < 60) return '${secs}s';
    final m = secs ~/ 60;
    final sec = secs % 60;
    if (m < 60) return '${m}m ${sec.toString().padLeft(2, '0')}s';
    final h = m ~/ 60;
    final rem = m % 60;
    return '${h}h ${rem}m';
  }

  static Color _confidenceColor(double c) {
    if (c >= 0.85) return const Color(0xFF4CAF50);
    if (c >= 0.60) return const Color(0xFFFFC107);
    return const Color(0xFFFF5722);
  }

  static String _confidenceLabel(double c) {
    if (c >= 0.85) return 'High';
    if (c >= 0.60) return 'Med';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final activity = LiveActivityStorage.currentActivity;
    final confidence = LiveActivityStorage.confidenceScore;
    final duration = LiveActivityStorage.sessionDurationSeconds;
    final color = _activityColor(activity);
    final label = '${activity[0].toUpperCase()}${activity.substring(1)}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * s, vertical: 14 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20 * s),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 44 * s,
            height: 44 * s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
            ),
            child: Center(
              child: Text(
                _activityIcon(activity),
                style: TextStyle(fontSize: 22 * s),
              ),
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7 * s,
                      height: 7 * s,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                    SizedBox(width: 5 * s),
                    Text(
                      'LIVE',
                      style: BraceletDashboardTypography.text(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2 * s),
                Text(
                  label,
                  style: BraceletDashboardTypography.text(
                    fontSize: 15 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (duration > 0)
                  Text(
                    _durationLabel(duration),
                    style: BraceletDashboardTypography.text(fontSize: 12 * s, color: Colors.white54),
                  ),
              ],
            ),
          ),
          if (confidence > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
              decoration: BoxDecoration(
                color: _confidenceColor(confidence).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10 * s),
                border: Border.all(
                  color: _confidenceColor(confidence).withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(confidence * 100).toInt()}%',
                    style: BraceletDashboardTypography.text(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w700,
                      color: _confidenceColor(confidence),
                    ),
                  ),
                  Text(
                    _confidenceLabel(confidence),
                    style: BraceletDashboardTypography.text(
                      fontSize: 9 * s,
                      color: _confidenceColor(confidence).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── _ActivityTimelineCard ─────────────────────────────────────────────────────
class _ActivityTimelineCard extends StatefulWidget {
  final double s;
  final String uid;

  const _ActivityTimelineCard({required this.s, required this.uid});

  @override
  State<_ActivityTimelineCard> createState() => _ActivityTimelineCardState();
}

class _ActivityTimelineCardState extends State<_ActivityTimelineCard> {
  List<ActivitySession>? _sessions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await ActivityPredictionsService.fetchToday(widget.uid);
    if (mounted) setState(() { _sessions = sessions; _loading = false; });
  }

  static String _activityIcon(String a) {
    switch (a) {
      case 'walking':   return '🚶';
      case 'running':   return '🏃';
      case 'cycling':   return '🚴';
      case 'treadmill': return '🏋️';
      default:          return '💪';
    }
  }

  static Color _activityColor(String a) {
    switch (a) {
      case 'running':
      case 'treadmill': return const Color(0xFFFF6B35);
      case 'cycling':   return const Color(0xFF00C8B4);
      case 'walking':   return const Color(0xFF4FC3F7);
      default:          return const Color(0xFF9C27B0);
    }
  }

  static String _timeLabel(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;

    if (_loading) {
      return SizedBox(
        height: 60 * s,
        child: Center(
          child: SizedBox(
            width: 20 * s,
            height: 20 * s,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyan),
          ),
        ),
      );
    }

    final sessions = (_sessions ?? [])
        .where((sess) => (sess.durationSeconds ?? 0) >= 30)
        .toList();

    if (sessions.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20 * s),
        child: Center(
          child: Text(
            'No activity sessions today.\nStart a workout to see your timeline.',
            textAlign: TextAlign.center,
            style: BraceletDashboardTypography.text(fontSize: 12 * s, color: AppColors.labelDim),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(sessions.length, (i) {
        final session = sessions[i];
        final color = _activityColor(session.displayActivity);
        final actLabel = session.displayActivity;
        final capitalLabel = '${actLabel[0].toUpperCase()}${actLabel.substring(1)}';
        final isLast = i == sessions.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 10 * s),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 10 * s,
                    height: 10 * s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 1.5,
                      height: 36 * s,
                      color: color.withValues(alpha: 0.25),
                    ),
                ],
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12 * s),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _activityIcon(session.displayActivity),
                        style: TextStyle(fontSize: 18 * s),
                      ),
                      SizedBox(width: 8 * s),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              capitalLabel,
                              style: BraceletDashboardTypography.text(
                                fontSize: 13 * s,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              _timeLabel(session.startedAt),
                              style: BraceletDashboardTypography.text(
                                fontSize: 11 * s,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8 * s),
                        ),
                        child: Text(
                          session.durationLabel,
                          style: BraceletDashboardTypography.text(
                            fontSize: 11 * s,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      if (session.wasCorrected) ...[
                        SizedBox(width: 6 * s),
                        Icon(Icons.edit_rounded, size: 13 * s, color: Colors.white38),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
