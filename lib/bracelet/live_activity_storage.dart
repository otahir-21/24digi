import 'package:flutter/foundation.dart';

/// Shared in-memory state for the currently detected live activity.
/// Written by [ActivitiesInfoScreen] and read by [BraceletScreen]
/// to drive the Live Activity card without prop-drilling.
class LiveActivityStorage {
  LiveActivityStorage._();

  static String _activity = 'idle';
  static double _confidence = 0.0;
  static DateTime? _sessionStartedAt;
  static bool _isLive = false;

  /// Reactive notifier — incremented whenever any field changes.
  static final ValueNotifier<int> revision = ValueNotifier(0);

  // ── Read ────────────────────────────────────────────────────────────────

  /// Current detected activity: idle | sitting | standing | walking |
  /// running | treadmill | cycling.
  static String get currentActivity => _activity;

  /// Rule-based confidence score 0.0–1.0.
  static double get confidenceScore => _confidence;

  /// When the current session started (null when idle/sitting/standing).
  static DateTime? get sessionStartedAt => _sessionStartedAt;

  /// True only while the ActivitiesInfoScreen is open and streaming data.
  static bool get isLive => _isLive;

  /// Elapsed seconds in the current activity session (0 if no active session).
  static int get sessionDurationSeconds {
    final start = _sessionStartedAt;
    if (start == null) return 0;
    return DateTime.now().difference(start).inSeconds;
  }

  // ── Write (called from ActivitiesInfoScreen) ────────────────────────────

  static void update({
    required String activity,
    required double confidence,
    required DateTime? sessionStart,
  }) {
    _activity = activity;
    _confidence = confidence;
    _sessionStartedAt = sessionStart;
    _isLive = true;
    revision.value++;
  }

  /// Called from [ActivitiesInfoScreen.dispose] so the main screen can
  /// show a "session ended" state rather than stale data.
  static void markOffline() {
    _isLive = false;
    revision.value++;
  }

  static void clear() {
    _activity = 'idle';
    _confidence = 0.0;
    _sessionStartedAt = null;
    _isLive = false;
    revision.value++;
  }
}
