import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../../bracelet/activity_detail_fields.dart';
import '../../bracelet/activity_storage.dart';
import '../../bracelet/bracelet_channel.dart';
import '../../bracelet/bracelet_verbose_log.dart';
import '../../bracelet/live_activity_storage.dart';
import '../../bracelet/weekly_data_storage.dart';
import '../../painters/smooth_gradient_border.dart';
import '../../services/activity_predictions_service.dart';
import 'bracelet_scaffold.dart';
import 'share_activity_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ActivitiesInfoScreen – activity detail with optional real-time bracelet data
// ─────────────────────────────────────────────────────────────────────────────
class ActivitiesInfoScreen extends StatefulWidget {
  const ActivitiesInfoScreen({
    super.key,
    this.channel,
    this.activityLabel,
    this.dashboardLiveData,
  });

  final BraceletChannel? channel;
  final String? activityLabel;
  /// Type-24 snapshot from bracelet home (optional) to fill metrics before the stream updates.
  final Map<String, dynamic>? dashboardLiveData;

  @override
  State<ActivitiesInfoScreen> createState() => _ActivitiesInfoScreenState();
}

class _ActivitiesInfoScreenState extends State<ActivitiesInfoScreen> {
  StreamSubscription<BraceletEvent>? _subscription;
  Map<String, dynamic>? _realtimeData;
  int? _lastStep;
  DateTime? _lastStepTime;
  double? _cadence; // steps per minute
  String _activityState = 'idle'; // idle | sitting | standing | walking | running | cycling | treadmill
  bool _isTreadmill = false;
  DateTime? _runningStateStart; // When state first became 'running'

  // ── Smoothing: confirm activity only after 3 consecutive same predictions ──
  final List<String> _predictionBuffer = [];
  static const int _smoothingWindow = 3;

  // ── Confidence score (0.0 – 1.0) rule-based ──
  double _confidenceScore = 0.0;

  // ── Idle-state timing for sitting vs standing detection ──
  DateTime? _idleStart; // When cadence last dropped to zero/low

  // ── Session tracking for Firestore + correction ──
  DateTime? _activeSessionStart; // Non-null for walk/run/cycle/treadmill
  String? _activeSessionId;      // Firestore document ID for the current session
  String? _lastConfirmedActivity; // Previous state before current one

  static const _cadenceRunningMin = 140;
  static const _cadenceWalkingMin = 80;
  static const _cadenceWalkingMax = 130;
  static const _hrRunningMin = 100;
  static const _hrWalkingMin = 80;
  static const _hrWalkingMax = 115;
  // Cycling: low/zero step cadence (wrist doesn't register pedalling as steps)
  // but heart rate is elevated — distinguishes it from sitting/idle.
  static const _hrCyclingMin = 90;
  static const _cadenceCyclingMax = 60; // spm — above this it's walking, not cycling

  BraceletChannel? get _channel => widget.channel;

  /// Running map: start position, current position, and route points (from phone GPS).
  LatLng? _runStartPosition;
  LatLng? _runCurrentPosition;
  final List<LatLng> _runRoutePoints = [];
  StreamSubscription<Position>? _positionSubscription;
  bool _locationPermissionDenied = false;
  GoogleMapController? _runMapController;

  bool get _isRunningActivity {
    final label = widget.activityLabel?.toLowerCase() ?? '';
    return label == 'running' || label == 'run';
  }

  bool get _isCyclingActivity {
    final label = widget.activityLabel?.toLowerCase() ?? '';
    return label == 'cycling' || label == 'cycle' || label == 'bike';
  }

  /// True when GPS route map should be shown (running or cycling).
  bool get _isGpsActivity => _isRunningActivity || _isCyclingActivity;

  int? get _heartRateFromRealtime {
    final r = _realtimeData;
    if (r == null) return null;
    final hr = r['heartRate'] ?? r['HeartRate'];
    if (hr is int) return hr;
    if (hr is num) return hr.toInt();
    return null;
  }

  static const int _maxHeartRateForZones = 190;

  List<Widget> _last7DayLabels(double s) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return Text(
        days[d.weekday % 7],
        style: GoogleFonts.inter(fontSize: 8 * s, color: AppColors.labelDim),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (_channel != null) {
      braceletVerboseLog(
        '[Bracelet Stream] activity: initState channel=${_channel.hashCode} subscribe',
      );
      _subscription = _channel!.events.listen(_onBraceletEvent);
      braceletVerboseLog(
        '[Bracelet Stream] activity: startRealtime(1) caller=initState channel=${_channel.hashCode}',
      );
      _channel!.startRealtime(RealtimeType.step);
    }
    if (_isGpsActivity) _startRunLocationTracking();
  }

  Future<void> _startRunLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _locationPermissionDenied = true);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationPermissionDenied = true);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _runStartPosition = LatLng(pos.latitude, pos.longitude);
        _runCurrentPosition = LatLng(pos.latitude, pos.longitude);
        _runRoutePoints.add(_runStartPosition!);
      });
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        if (!mounted) return;
        final latLng = LatLng(position.latitude, position.longitude);
        setState(() {
          _runCurrentPosition = latLng;
          _runRoutePoints.add(latLng);
        });
        _runMapController?.animateCamera(
          CameraUpdate.newLatLng(latLng),
        );
      });
    } on MissingPluginException catch (_) {
      if (mounted) {
        setState(() => _locationPermissionDenied = true);
      }
    } on PlatformException catch (_) {
      if (mounted) {
        setState(() => _locationPermissionDenied = true);
      }
    }
  }

  @override
  void dispose() {
    if (_channel != null) {
      braceletVerboseLog(
        '[Bracelet Stream] activity: dispose unsubscribe channel=${_channel.hashCode}',
      );
    }
    _positionSubscription?.cancel();
    _runMapController?.dispose();
    BraceletChannel.cancelBraceletSubscription(_subscription);
    _subscription = null;
    // End any open Firestore session and mark shared state offline.
    _endActiveSession();
    LiveActivityStorage.markOffline();
    super.dispose();
  }

  void _onBraceletEvent(BraceletEvent e) {
    if (!mounted) return;
    if (e.event == 'connectionState') {
      if (BraceletChannel.isDisconnectedState(e.data['state']?.toString())) {
        setState(() {
          _realtimeData = null;
          _lastStep = null;
          _lastStepTime = null;
          _cadence = null;
          _activityState = 'idle';
        });
      }
      return;
    }
    if (e.event != 'realtimeData') return;
    final dataType = e.data['dataType'];
    final type = dataType is int
        ? dataType
        : (dataType is num ? dataType.toInt() : null);
    if (type != 24) return;
    if (_channel != null) {
      final step = _intFrom((e.data['dicData'] as Map?)?['step'] ?? (e.data['dicData'] as Map?)?['Step']);
      braceletVerboseLog(
        '[Bracelet Stream] activity received type 24 channel=${_channel.hashCode} step=$step',
      );
    }
    final dic = e.data['dicData'];
    if (dic == null || dic is! Map) return;
    final dicMap = Map<String, dynamic>.from(
      (dic as Map<Object?, Object?>).map(
        (k, v) => MapEntry(k?.toString() ?? '', v),
      ),
    );
    final step = _intFrom(dicMap['step'] ?? dicMap['Step']);
    final hr = _intFrom(dicMap['heartRate'] ?? dicMap['HeartRate']);
    final now = DateTime.now();
    double? cadence;
    if (step != null && _lastStep != null && _lastStepTime != null) {
      final stepDelta = step - _lastStep!;
      final secDelta = now.difference(_lastStepTime!).inMilliseconds / 1000.0;
      if (secDelta > 0 && stepDelta >= 0) {
        cadence = stepDelta * (60.0 / secDelta);
      }
    }
    // ── Raw prediction ──────────────────────────────────────────────────────
    String rawState = _activityState;
    if (cadence != null && hr != null) {
      if (cadence >= _cadenceRunningMin && hr >= _hrRunningMin) {
        rawState = 'running';
      } else if (cadence >= _cadenceWalkingMin &&
          cadence <= _cadenceWalkingMax &&
          hr >= _hrWalkingMin &&
          hr <= _hrWalkingMax) {
        rawState = 'walking';
      } else if (cadence < _cadenceCyclingMax && hr >= _hrCyclingMin) {
        // Near-zero step cadence + elevated HR → cycling
        rawState = 'cycling';
      } else {
        rawState = 'idle';
      }
    }

    // ── Smoothing: 3-consecutive-same confirms a state change (spec §7.2) ──
    _predictionBuffer.add(rawState);
    if (_predictionBuffer.length > _smoothingWindow) {
      _predictionBuffer.removeAt(0);
    }
    final String smoothedState;
    if (_predictionBuffer.length == _smoothingWindow &&
        _predictionBuffer.every((p) => p == _predictionBuffer.first)) {
      smoothedState = _predictionBuffer.first;
    } else {
      smoothedState = _activityState; // hold previous until confirmed
    }

    // ── Sitting / Standing from idle + heart rate (spec §4.1) ──────────────
    String state = smoothedState;
    if (state == 'idle' && hr != null) {
      if (hr < 72) {
        state = 'sitting';
      } else if (hr <= 88) {
        state = 'standing';
      }
    }

    // ── Idle start timer for sitting/standing hysteresis ───────────────────
    DateTime? idleStart = _idleStart;
    if (state == 'sitting' || state == 'standing') {
      idleStart ??= now;
    } else {
      idleStart = null;
    }

    // ── Treadmill detection (30 s running, GPS stationary) ─────────────────
    DateTime? runningStateStart = _runningStateStart;
    if (state == 'running' && _activityState != 'running') {
      runningStateStart = now;
    } else if (state != 'running') {
      runningStateStart = null;
    }

    bool isTreadmill = _isTreadmill;
    if (state == 'running' && runningStateStart != null) {
      if (now.difference(runningStateStart).inSeconds >= 30 &&
          _runRoutePoints.length <= 1) {
        isTreadmill = true;
        state = 'treadmill';
      }
    } else if (state != 'running') {
      isTreadmill = false;
    }

    // ── Confidence score (spec §7.3) ───────────────────────────────────────
    final confidence = _computeConfidence(state, cadence, hr);

    // ── Session lifecycle: start / end active sessions ─────────────────────
    final wasActive = _isActiveState(_activityState);
    final nowActive = _isActiveState(state);

    if (!wasActive && nowActive) {
      unawaited(_startActiveSession(state, confidence));
    } else if (wasActive && !nowActive) {
      final prev = _lastConfirmedActivity;
      unawaited(_endActiveSession(showCorrection: true));
      _lastConfirmedActivity = prev;
    }

    // ── Publish to LiveActivityStorage so bracelet main screen can read it ──
    LiveActivityStorage.update(
      activity: state,
      confidence: confidence,
      sessionStart: nowActive ? (_activeSessionStart ?? now) : null,
    );

    setState(() {
      _realtimeData = dicMap;
      _lastStep = step;
      _lastStepTime = now;
      if (cadence != null) _cadence = cadence;
      _activityState = state;
      _runningStateStart = runningStateStart;
      _isTreadmill = isTreadmill;
      _idleStart = idleStart;
      _confidenceScore = confidence;
      if (nowActive) _lastConfirmedActivity = state;
    });
  }

  static int? _intFrom(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  // ── Confidence ────────────────────────────────────────────────────────────

  /// Compute a rule-based confidence for the raw predicted state.
  double _computeConfidence(
    String state,
    double? cadence,
    int? hr,
  ) {
    if (state == 'idle' || state == 'sitting' || state == 'standing') {
      return 0.80;
    }
    if (state == 'treadmill') return 0.85;

    bool cadenceOk = false;
    bool hrOk = false;

    if (state == 'running' && cadence != null && hr != null) {
      // Both signals agree strongly → high confidence
      cadenceOk = cadence >= _cadenceRunningMin + 10;
      hrOk = hr >= _hrRunningMin + 15;
    } else if (state == 'walking' && cadence != null && hr != null) {
      cadenceOk = cadence >= _cadenceWalkingMin + 5 &&
          cadence <= _cadenceWalkingMax - 5;
      hrOk = hr >= _hrWalkingMin + 5 && hr <= _hrWalkingMax - 5;
    } else if (state == 'cycling' && hr != null) {
      hrOk = hr >= _hrCyclingMin + 10;
      cadenceOk = true; // cadence is intentionally low for cycling
    }

    if (cadenceOk && hrOk) return 0.92;
    if (cadenceOk || hrOk) return 0.70;
    return 0.60;
  }

  // ── Session management ─────────────────────────────────────────────────────

  static bool _isActiveState(String state) =>
      state == 'walking' ||
      state == 'running' ||
      state == 'cycling' ||
      state == 'treadmill';

  /// Start a Firestore session record for a new active state.
  Future<void> _startActiveSession(String activity, double confidence) async {
    final uid =
        context.mounted ? context.read<AuthProvider>().firebaseUser?.uid : null;
    if (uid == null) return;
    final now = DateTime.now();
    _activeSessionStart = now;
    _activeSessionId = await ActivityPredictionsService.saveSession(
      uid: uid,
      predictedActivity: activity,
      confidenceScore: confidence,
      startedAt: now,
    );
  }

  /// Close the open Firestore session and optionally show the correction dialog.
  Future<void> _endActiveSession({bool showCorrection = false}) async {
    final sessionId = _activeSessionId;
    final sessionStart = _activeSessionStart;
    final lastActivity = _lastConfirmedActivity;
    _activeSessionId = null;
    _activeSessionStart = null;

    if (sessionId == null || sessionStart == null || lastActivity == null) {
      return;
    }

    final uid =
        context.mounted ? context.read<AuthProvider>().firebaseUser?.uid : null;
    if (uid == null) return;

    final endedAt = DateTime.now();
    final durationSecs = endedAt.difference(sessionStart).inSeconds;

    // Only bother recording sessions longer than 30 seconds.
    if (durationSecs < 30) return;

    await ActivityPredictionsService.updateSession(
      uid: uid,
      sessionId: sessionId,
      endedAt: endedAt,
      durationSeconds: durationSecs,
    );

    if (showCorrection && context.mounted && durationSecs >= 60) {
      _showCorrectionSheet(
        uid: uid,
        sessionId: sessionId,
        detectedActivity: lastActivity,
      );
    }
  }

  // ── Correction bottom sheet ───────────────────────────────────────────────

  static const List<String> _activityChoices = [
    'walking',
    'running',
    'cycling',
    'treadmill',
    'workout',
    'other',
  ];

  static String _activityIcon(String a) {
    switch (a) {
      case 'walking':   return '🚶';
      case 'running':   return '🏃';
      case 'cycling':   return '🚴';
      case 'treadmill': return '🏋️';
      case 'workout':   return '💪';
      default:          return '❓';
    }
  }

  void _showCorrectionSheet({
    required String uid,
    required String sessionId,
    required String detectedActivity,
  }) {
    final s = AppConstants.scale(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * s)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20 * s, 16 * s, 20 * s, 32 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40 * s,
                  height: 4 * s,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2 * s),
                  ),
                ),
              ),
              SizedBox(height: 16 * s),
              Text(
                'Was this correct?',
                style: GoogleFonts.inter(
                  fontSize: 16 * s,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4 * s),
              Text(
                'We detected: ${_activityIcon(detectedActivity)} '
                '${detectedActivity[0].toUpperCase()}${detectedActivity.substring(1)}',
                style: GoogleFonts.inter(
                  fontSize: 13 * s,
                  color: Colors.white60,
                ),
              ),
              SizedBox(height: 16 * s),
              Wrap(
                spacing: 10 * s,
                runSpacing: 10 * s,
                children: _activityChoices.map((choice) {
                  final isDetected = choice == detectedActivity;
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      if (choice != detectedActivity) {
                        await ActivityPredictionsService.updateSession(
                          uid: uid,
                          sessionId: sessionId,
                          correctedActivity: choice,
                          wasCorrected: true,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * s,
                        vertical: 10 * s,
                      ),
                      decoration: BoxDecoration(
                        color: isDetected
                            ? AppColors.cyan.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14 * s),
                        border: Border.all(
                          color: isDetected
                              ? AppColors.cyan
                              : Colors.white24,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _activityIcon(choice),
                            style: TextStyle(fontSize: 16 * s),
                          ),
                          SizedBox(width: 6 * s),
                          Text(
                            '${choice[0].toUpperCase()}${choice.substring(1)}',
                            style: GoogleFonts.inter(
                              fontSize: 13 * s,
                              fontWeight: FontWeight.w600,
                              color: isDetected ? AppColors.cyan : Colors.white,
                            ),
                          ),
                          if (isDetected) ...[
                            SizedBox(width: 4 * s),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14 * s,
                              color: AppColors.cyan,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12 * s),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      color: Colors.white38,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTreadmillDisplay(double s) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C8B4).withValues(alpha: 0.15),
            const Color(0xFF1A8C7E).withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Treadmill icon using fitness-related icons
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 88 * s,
                  height: 88 * s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                ),
                Icon(
                  Icons.directions_run_rounded,
                  size: 48 * s,
                  color: AppColors.cyan,
                ),
              ],
            ),
            SizedBox(height: 16 * s),
            Text(
              'Treadmill Running',
              style: GoogleFonts.inter(
                fontSize: 18 * s,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6 * s),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 4 * s),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    size: 13 * s,
                    color: AppColors.cyan,
                  ),
                  SizedBox(width: 4 * s),
                  Text(
                    'Indoor · No GPS',
                    style: GoogleFonts.inter(
                      fontSize: 12 * s,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cyan,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20 * s),
            Text(
              'Route tracking unavailable indoors.',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: AppColors.labelDim,
              ),
            ),
            Text(
              'Steps, HR & calories are still tracked.',
              style: GoogleFonts.inter(
                fontSize: 12 * s,
                color: AppColors.labelDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder(double s) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E6FBD).withOpacity(0.15),
            const Color(0xFF1E6FBD).withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_rounded,
              size: 56 * s,
              color: const Color(0xFF1E6FBD).withOpacity(0.6),
            ),
            SizedBox(height: 12 * s),
            Text(
              'Route',
              style: TextStyle(
                fontSize: 18 * s,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E6FBD).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLoading(double s) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E6FBD).withOpacity(0.15),
            const Color(0xFF1E6FBD).withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36 * s,
              height: 36 * s,
              child: CircularProgressIndicator(
                strokeWidth: 2 * s,
                color: const Color(0xFF1E6FBD),
              ),
            ),
            SizedBox(height: 12 * s),
            Text(
              'Getting your location…',
              style: AppStyles.reg12(s).copyWith(color: AppColors.labelDim),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPermissionDenied(double s) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E6FBD).withOpacity(0.15),
            const Color(0xFF1E6FBD).withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24 * s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 48 * s,
                color: const Color(0xFF1E6FBD).withOpacity(0.6),
              ),
              SizedBox(height: 12 * s),
              Text(
                'Location access is needed to show your run on the map. Enable it in Settings.',
                textAlign: TextAlign.center,
                style: AppStyles.reg12(s).copyWith(color: AppColors.labelDim),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRunningMap(double s) {
    final start = _runStartPosition!;
    final current = _runCurrentPosition ?? start;
    final cameraTarget = current;
    final zoom = 15.0;
    final Set<Marker> markers = {};
    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: start,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start'),
      ),
    );
    if (_runCurrentPosition != null &&
        (_runCurrentPosition!.latitude != start.latitude ||
            _runCurrentPosition!.longitude != start.longitude)) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: current,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }
    final Set<Polyline> polylines = {};
    if (_runRoutePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: _runRoutePoints,
          color: AppColors.cyan,
          width: 4,
        ),
      );
    }
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: cameraTarget,
        zoom: zoom,
      ),
      markers: markers,
      polylines: polylines,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      onMapCreated: (controller) {
        _runMapController = controller;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);

    return BraceletScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Title: activity label or HI, name ─────────────────
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final String title = _isTreadmill
                  ? 'TREADMILL'
                  : widget.activityLabel != null
                      ? widget.activityLabel!.toUpperCase()
                      : (() {
                          final name = auth.profile?.name?.trim();
                          return (name != null && name.isNotEmpty)
                              ? 'HI, ${name.toUpperCase()}'
                              : 'HI';
                        })();
              return Center(
                child: Text(
                  title,
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
          SizedBox(height: 14 * s),

          // ── Map + Stats Overlay ──────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              _BorderCard(
                s: s,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30 * s),
                  child: SizedBox(
                    height: 480 * s,
                  child: _isTreadmill
                      ? _buildTreadmillDisplay(s)
                      : _isGpsActivity && _locationPermissionDenied
                          ? _buildMapPermissionDenied(s)
                          : _isGpsActivity && _runStartPosition != null
                              ? _buildRunningMap(s)
                              : _isGpsActivity
                                  ? _buildMapLoading(s)
                                  : _buildMapPlaceholder(s),
                  ),
                ),
              ),
              // Expand Icon overlay
              Positioned(
                top: 260 * s,
                right: 20 * s,
                child: Container(
                  width: 54 * s,
                  height: 52 * s,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(240),
                    borderRadius: BorderRadius.circular(10 * s),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Icon(
                        Icons.unfold_more_rounded,
                        color: const Color(0xFFEF5350),
                        size: 26 * s,
                      ),
                    ),
                  ),
                ),
              ),
              // Statistics Overlay Card (real-time when channel connected)
              Positioned(
                bottom: -2 * s,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: ActivityStorage.versionNotifier,
                  builder: (context, version, _) {
                    assert(version >= 0);
                    return _ActivityDetailMetricsCard(
                      s: s,
                      activityLabel: widget.activityLabel,
                      liveData:
                          _realtimeData ?? widget.dashboardLiveData,
                      showLiveBadge: _realtimeData != null,
                      cadence: _cadence,
                      activityState: _activityState,
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * s),

          // ── Performance Over Time ─────────────────────────────
          _BorderCard(
            s: s,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Over Time',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  SizedBox(
                    height: 130 * s,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _PerformancePainter(
                        s: s,
                        values: WeeklyDataStorage.last7DaysDistanceKm,
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  // Days X-Axis (last 7 days: oldest first)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _last7DayLabels(s),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14 * s),

          // ── Heart Rate Zones ──────────────────────────────────
          _BorderCard(
            s: s,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14 * s, 14 * s, 14 * s, 10 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Heart Rate Zones',
                    style: GoogleFonts.inter(
                      fontSize: 13 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  SizedBox(
                    height: 130 * s,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _HrZonePainter(
                        s: s,
                        currentHeartRate: _heartRateFromRealtime,
                        maxHeartRate: _maxHeartRateForZones,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * s),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ZoneLabel(
                        s: s,
                        label: 'Light',
                        color: const Color(0xFF4CAF50),
                      ),
                      _ZoneLabel(
                        s: s,
                        label: 'Moderate',
                        color: const Color(0xFFFFD600),
                      ),
                      _ZoneLabel(
                        s: s,
                        label: 'Hard',
                        color: const Color(0xFFFF9800),
                      ),
                      _ZoneLabel(
                        s: s,
                        label: 'Maximum',
                        color: const Color(0xFFEF5350),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14 * s),

          // ── Weekly Distance Goal (real data from WeeklyDataStorage) ───────
          _BorderCard(
            s: s,
            child: Padding(
              padding: EdgeInsets.all(16 * s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekly Distance Goal: ${WeeklyDataStorage.weeklyDistanceGoalKm.toInt()} km',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        WeeklyDataStorage.weeklyTotalDistanceKm > 0
                            ? '${(WeeklyDataStorage.weeklyGoalProgress * 100).round()}%'
                            : '0%',
                        style: GoogleFonts.inter(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cyan,
                        ),
                      ),
                    ],
                  ),
                  if (WeeklyDataStorage.weeklyTotalDistanceKm > 0) ...[
                    SizedBox(height: 4 * s),
                    Text(
                      '${WeeklyDataStorage.weeklyTotalDistanceKm.toStringAsFixed(1)} km this week',
                      style: GoogleFonts.inter(
                        fontSize: 10 * s,
                        color: AppColors.labelDim,
                      ),
                    ),
                  ],
                  SizedBox(height: 8 * s),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6 * s),
                    child: Container(
                      height: 8 * s,
                      color: Colors.white.withAlpha(20),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: WeeklyDataStorage.weeklyGoalProgress.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6 * s),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43C6E4), Color(0xFF9F56F5)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.cyan.withAlpha(80),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * s),
                  Text(
                    '32.5 km / 50 km (65%)',
                    style: GoogleFonts.inter(
                      fontSize: 10 * s,
                      color: AppColors.labelDim,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14 * s),

          // ── AI Insight ────────────────────────────────────────
          _BorderCard(
            s: s,
            child: Padding(
              padding: EdgeInsets.all(18 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.cyan,
                    size: 24 * s,
                  ),
                  SizedBox(width: 12 * s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI INSIGHT',
                          style: TextStyle(
                            fontFamily: 'LemonMilk',
                            fontSize: 10 * s,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyan,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(height: 8 * s),
                        Text(
                          'Your stress levels have remained elevated for extended periods. The AI recommends a short recovery window — deep breathing, a brief walk, or disengaging from screens — to help reset your system.',
                          style: GoogleFonts.inter(
                            fontSize: 11 * s,
                            color: Colors.white.withAlpha(220),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20 * s),

          // ── Share Activity button (pass real activity data) ────
          GestureDetector(
            onTap: () {
              final agg = aggregateSessionsForUiLabel(widget.activityLabel);
              final r = _realtimeData ?? widget.dashboardLiveData;
              int? dur = agg.totalActiveMinutes > 0 ? agg.totalActiveMinutes : null;
              double? distKm =
                  agg.totalDistanceKm > 0 ? agg.totalDistanceKm : null;
              double? cal =
                  agg.totalCalories > 0 ? agg.totalCalories : null;
              if (r != null) {
                final em = r['exerciseMinutes'] ??
                    r['ExerciseMinutes'] ??
                    r['activeMinutes'] ??
                    r['ActiveMinutes'];
                if (em is int && em > 0) dur = em;
                if (em is num && em.toInt() > 0) dur = em.toInt();
                final d = r['distance'] ?? r['Distance'];
                if (d is num) {
                  final dk = d.toDouble();
                  distKm = dk > 100 ? dk / 1000 : dk;
                }
                final c = r['calories'] ?? r['Calories'];
                if (c is num && c.toDouble() > 0) cal = c.toDouble();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShareActivityScreen(
                    activityLabel: widget.activityLabel,
                    durationMinutes: dur,
                    distanceKm: distKm,
                    calories: cal,
                    routePoints: _runRoutePoints.isEmpty ? null : List<LatLng>.from(_runRoutePoints),
                    dateTime: DateTime.now(),
                  ),
                ),
              );
            },
            child: CustomPaint(
              painter: SmoothGradientBorder(radius: 28 * s),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28 * s),
                child: Container(
                  height: 52 * s,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cyan.withAlpha(40),
                        const Color(0xFF9F56F5).withAlpha(40),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Share Activity',
                    style: GoogleFonts.inter(
                      fontSize: 14 * s,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24 * s),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityDetailMetricsCard extends StatelessWidget {
  final double s;
  final String? activityLabel;
  final Map<String, dynamic>? liveData;
  final bool showLiveBadge;
  final double? cadence;
  final String? activityState;

  const _ActivityDetailMetricsCard({
    required this.s,
    this.activityLabel,
    this.liveData,
    this.showLiveBadge = false,
    this.cadence,
    this.activityState,
  });

  static (IconData, Color) _iconForLabel(String label) {
    switch (label) {
      case 'Duration':
        return (Icons.schedule_rounded, AppColors.cyan);
      case 'Distance':
        return (Icons.pin_drop_outlined, const Color(0xFFD81B60));
      case 'Cadence / pace':
        return (Icons.speed_outlined, const Color(0xFF4CAF50));
      case 'Steps':
        return (Icons.directions_walk_rounded, AppColors.cyan);
      case 'Calories':
        return (Icons.local_fire_department_outlined, Colors.orange);
      case 'Heart rate':
        return (Icons.monitor_heart_outlined, const Color(0xFFEF5350));
      case 'Sessions today':
        return (Icons.event_repeat_rounded, const Color(0xFFAB47BC));
      default:
        return (Icons.analytics_outlined, AppColors.labelDim);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = metricProfileForUiLabel(activityLabel);
    final stored = aggregateSessionsForUiLabel(activityLabel);
    final fields = buildMetricFields(
      profile: profile,
      stored: stored,
      live: liveData,
      cadenceSpm: cadence,
    );

    Widget metricCell(ActivityMetricField f) {
      final ic = _iconForLabel(f.label);
      return _StatCell(
        s: s,
        icon: ic.$1,
        iconColor: ic.$2,
        label: f.label,
        value: f.value,
      );
    }

    return CustomPaint(
      painter: SmoothGradientBorder(radius: 30 * s),
      child: Container(
        padding: EdgeInsets.fromLTRB(16 * s, 20 * s, 16 * s, 24 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30 * s),
          color: const Color(0xFF060E16).withAlpha(240),
        ),
        child: Column(
          children: [
            if (activityLabel != null && activityLabel!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 8 * s),
                child: Text(
                  'Today · ${activityLabel!}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w600,
                    color: AppColors.labelDim,
                    letterSpacing: 0.3,
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(bottom: 8 * s),
                child: Text(
                  'Today · all activities',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w600,
                    color: AppColors.labelDim,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            if (showLiveBadge)
              Padding(
                padding: EdgeInsets.only(bottom: 10 * s),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * s,
                        vertical: 4 * s,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withAlpha(60),
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6 * s,
                            color: AppColors.cyan,
                          ),
                          SizedBox(width: 6 * s),
                          Text(
                            'LIVE',
                            style: GoogleFonts.inter(
                              fontSize: 10 * s,
                              fontWeight: FontWeight.w600,
                              color: AppColors.cyan,
                            ),
                          ),
                          if (activityState != null &&
                              activityState!.isNotEmpty) ...[
                            SizedBox(width: 8 * s),
                            Text(
                              activityState!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9 * s,
                                color: AppColors.labelDim,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (stored.sessionCount == 0 &&
                liveData == null &&
                !showLiveBadge)
              Padding(
                padding: EdgeInsets.only(bottom: 10 * s),
                child: Text(
                  'No sessions for this activity today yet. Live stats appear when the band sends data.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 9 * s,
                    color: AppColors.labelDim,
                    height: 1.35,
                  ),
                ),
              ),
            for (var i = 0; i < fields.length; i += 3) ...[
              if (i > 0) SizedBox(height: 16 * s),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var j = 0; j < 3; j++)
                    Expanded(
                      child: i + j < fields.length
                          ? metricCell(fields[i + j])
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final double s;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _StatCell({
    required this.s,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 14 * s),
            SizedBox(width: 4 * s),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9 * s,
                color: AppColors.labelDim,
              ),
            ),
          ],
        ),
        SizedBox(height: 4 * s),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15 * s,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ZoneLabel extends StatelessWidget {
  final double s;
  final String label;
  final Color color;
  const _ZoneLabel({required this.s, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8 * s,
          height: 8 * s,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4 * s),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 9 * s, color: AppColors.labelDim),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Over Time painter – real 7-day distance (km) area chart
// ─────────────────────────────────────────────────────────────────────────────
class _PerformancePainter extends CustomPainter {
  final double s;
  final List<double> values;

  const _PerformancePainter({required this.s, this.values = const []});

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 38.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    final list = values.length >= 7 ? values.sublist(0, 7) : [...values, ...List.filled(7 - values.length, 0.0)];
    final maxVal = list.isEmpty ? 1.0 : (list.reduce((a, b) => a > b ? a : b) > 0 ? list.reduce((a, b) => a > b ? a : b) : 1.0);
    final normalized = list.map((v) => maxVal > 0 ? (v / maxVal).clamp(0.0, 1.0) : 0.0).toList();
    // Y = 0 at bottom, 1 at top → chart y = chartH * (1 - normalized)
    final pts = normalized.map((v) => 1.0 - v).toList();

    final yLabelMax = maxVal >= 10 ? maxVal.roundToDouble() : (maxVal * 10).round() / 10;
    final yLabels = [
      '0',
      '${(yLabelMax * 0.25).toStringAsFixed(1)}',
      '${(yLabelMax * 0.5).toStringAsFixed(1)}',
      '${(yLabelMax * 0.75).toStringAsFixed(1)}',
      '${yLabelMax.toStringAsFixed(1)} km',
    ];

    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(25)
      ..strokeWidth = 1.2;

    for (int i = 0; i < yLabels.length; i++) {
      final y = chartH * (i / (yLabels.length - 1));
      tp
        ..text = TextSpan(
          text: yLabels[i],
          style: TextStyle(fontSize: 7 * s, color: AppColors.labelDim),
        )
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    if (pts.isEmpty) return;

    final n = pts.length;
    final stepX = n > 1 ? chartW / (n - 1) : chartW;

    Path buildLine() {
      final p = Path();
      p.moveTo(yLabelW, chartH * pts[0]);
      for (int i = 1; i < n; i++) {
        final x0 = yLabelW + (i - 1) * stepX;
        final y0 = chartH * pts[i - 1];
        final x1 = yLabelW + i * stepX;
        final y1 = chartH * pts[i];
        final cx = (x0 + x1) / 2;
        p.cubicTo(cx, y0, cx, y1, x1, y1);
      }
      return p;
    }

    final linePath = buildLine();
    final areaPath = Path.from(linePath)
      ..lineTo(yLabelW + chartW, chartH)
      ..lineTo(yLabelW, chartH)
      ..close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cyan.withAlpha(120), AppColors.cyan.withAlpha(0)],
        ).createShader(Rect.fromLTWH(yLabelW, 0, chartW, chartH)),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4 * s
        ..strokeJoin = StrokeJoin.round,
    );

    final dotPaint = Paint()..color = Colors.white;
    final glowPaint = Paint()
      ..color = Colors.white.withAlpha(100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (int i = 0; i < n; i++) {
      final x = yLabelW + i * stepX;
      final y = chartH * pts[i];
      canvas.drawCircle(Offset(x, y), 3.5 * s, glowPaint);
      canvas.drawCircle(Offset(x, y), 2 * s, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PerformancePainter old) =>
      old.values != values || old.s != s;
}

// ─────────────────────────────────────────────────────────────────────────────
// Heart Rate Zones bar chart – real data: highlight zone where current HR falls
// Zones: Light 50–60% maxHR, Moderate 60–70%, Hard 70–80%, Maximum 80–100%
// ─────────────────────────────────────────────────────────────────────────────
class _HrZonePainter extends CustomPainter {
  final double s;
  final int? currentHeartRate;
  final int maxHeartRate;

  const _HrZonePainter({
    required this.s,
    this.currentHeartRate,
    this.maxHeartRate = 190,
  });

  static const _zoneColors = [
    Color(0xFF4CAF50), // Light
    Color(0xFFFFD600), // Moderate
    Color(0xFFFF9800), // Hard
    Color(0xFFEF5350), // Maximum
  ];

  int _zoneIndexFor(int? hr, int maxHR) {
    if (hr == null || hr <= 0 || maxHR <= 0) return -1;
    final pct = hr / maxHR;
    if (pct < 0.60) return 0;
    if (pct < 0.70) return 1;
    if (pct < 0.80) return 2;
    return 3;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final yLabelW = 34.0 * s;
    final chartW = size.width - yLabelW;
    final chartH = size.height;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    final currentZone = _zoneIndexFor(currentHeartRate, maxHeartRate);
    final barHeights = List.generate(4, (i) => i == currentZone ? 0.85 : 0.18);

    final yLabels = ['100%', '75%', '50%', '25%', '0'];
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..strokeWidth = 1;

    for (int i = 0; i < yLabels.length; i++) {
      final y = chartH * (i / (yLabels.length - 1));
      tp
        ..text = TextSpan(
          text: yLabels[i],
          style: TextStyle(fontSize: 7 * s, color: AppColors.labelDim),
        )
        ..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
      double dx = yLabelW;
      while (dx < size.width) {
        canvas.drawLine(Offset(dx, y), Offset(dx + 5, y), dashPaint);
        dx += 9;
      }
    }

    const groupGap = 10.0;
    final barW = (chartW - groupGap * 5) / 4;

    for (int i = 0; i < 4; i++) {
      final bH = chartH * barHeights[i];
      final x = yLabelW + groupGap + i * (barW + groupGap);
      final top = chartH - bH;
      final rr = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, top, barW, bH),
        topLeft: Radius.circular(10 * s),
        topRight: Radius.circular(10 * s),
      );
      final color = _zoneColors[i];
      canvas.drawRRect(
        rr,
        Paint()
          ..color = color.withAlpha(i == currentZone ? 80 : 40)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withAlpha(200)],
          ).createShader(Rect.fromLTWH(x, top, barW, bH)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HrZonePainter old) =>
      old.currentHeartRate != currentHeartRate || old.maxHeartRate != maxHeartRate || old.s != s;
}

class _BarDef {
  final double heightFactor;
  final Color color;
  const _BarDef(this.heightFactor, this.color);
}

class _BorderCard extends StatelessWidget {
  final double s;
  final Widget child;
  const _BorderCard({required this.s, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SmoothGradientBorder(radius: 16 * s),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * s),
        child: ColoredBox(color: const Color(0xFF060E16), child: child),
      ),
    );
  }
}
