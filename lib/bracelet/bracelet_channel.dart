import 'dart:async';
import 'package:flutter/services.dart';

import 'bracelet_verbose_log.dart';

/// Method channel name for bracelet commands (scan, connect, startRealtime, etc.)
const String braceletMethodChannelName = 'com.24digi/bracelet';

/// Event channel name for streaming (realtime data, scan results, connection state)
const String braceletEventChannelName = 'com.24digi/bracelet/events';

/// Realtime type: 0 = off, 1 = step (on change), 2 = step with temperature (1 sec).
/// Prefer [step] for daily totals in type 24; many devices zero step/distance/cal in mode 2.
enum RealtimeType {
  off(0),
  step(1),
  stepWithTemp(2);

  const RealtimeType(this.raw);
  final int raw;
}

/// Envelope for all events from native
class BraceletEvent {
  BraceletEvent({
    required this.event,
    required this.timestamp,
    required this.data,
  });

  factory BraceletEvent.fromMap(Map<Object?, Object?> map) {
    return BraceletEvent(
      event: map['event'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? '',
      data: map['data'] as Map<Object?, Object?>? ?? {},
    );
  }

  final String event;
  final String timestamp;
  final Map<Object?, Object?> data;
}

/// Dart API for the native bracelet SDK (iOS only).
class BraceletChannel {
  /// Last HRV (ms) received from device or returned from HRV screen. Dashboard uses this when device hasn't sent type 38/56 yet.
  static int? lastKnownHrv;

  /// Last SpO2 (%) received from device (type 42/43/57). Dashboard uses this as fallback.
  static int? lastKnownSpo2;

  /// Last temperature (°C) shown on dashboard; survives sparse type-24 updates.
  static double? lastKnownTemperature;

  /// Last heart rate (BPM) from merged realtime / activity (recovery & dashboards).
  static int? lastKnownHeartRate;

  /// Last stress index 0–100 from band or derived from HR/HRV in merge.
  static int? lastKnownStress;

  /// True when [state] indicates the bracelet is disconnected (clear UI data).
  static bool isDisconnectedState(String? state) {
    if (state == null || state.isEmpty) return true;
    final lower = state.toLowerCase();
    return lower.contains('disconnect') || state == '0' || lower == 'failed';
  }

  /// Cancels the subscription and swallows "No active stream to cancel" (e.g. on hot restart).
  static void cancelBraceletSubscription(StreamSubscription<BraceletEvent>? sub) {
    sub?.cancel().catchError((Object e) {
      if (e is PlatformException &&
          (e.message?.contains('No active stream') ?? false)) {
        return;
      }
      throw e;
    });
  }

  BraceletChannel() {
    _methodChannel = const MethodChannel(braceletMethodChannelName);
    _eventChannel = const EventChannel(braceletEventChannelName);
  }

  late final MethodChannel _methodChannel;
  late final EventChannel _eventChannel;

  /// Stream of bracelet events (realtimeData, scanResult, connectionState).
  Stream<BraceletEvent> get events {
    return _eventChannel
        .receiveBroadcastStream()
        .map((dynamic e) => BraceletEvent.fromMap(Map<Object?, Object?>.from(e as Map)));
  }

  /// Start BLE scan. Results arrive via [events] with event == 'scanResult'.
  Future<void> scan() async {
    await _methodChannel.invokeMethod<void>('scan');
  }

  /// Stop BLE scan.
  Future<void> stopScan() async {
    await _methodChannel.invokeMethod<void>('stopScan');
  }

  /// Get already-connected peripherals (service FFF0). Alternative discovery to scanning.
  Future<List<Map<Object?, Object?>>> getRetrievedDevices() async {
    final List<dynamic>? list = await _methodChannel.invokeMethod<List<dynamic>>('getRetrievedDevices');
    if (list == null) return [];
    return list.map((e) => Map<Object?, Object?>.from(e as Map)).toList();
  }

  /// Current bracelet connection state. Use on app start/resume to restore UI without reconnecting.
  /// Returns { connected: bool, identifier?: string, name?: string }.
  Future<Map<Object?, Object?>> getConnectionState() async {
    final Map<Object?, Object?>? map = await _methodChannel.invokeMethod<Map<Object?, Object?>>('getConnectionState');
    return map ?? <Object?, Object?>{'connected': false};
  }

  /// Connect to device by [identifier] (peripheral UUID string).
  Future<void> connect(String identifier) async {
    await _methodChannel.invokeMethod<void>('connect', {'identifier': identifier});
  }

  /// Start realtime streaming. [type]: 0=off, 1=step, 2=stepWithTemp.
  Future<void> startRealtime(RealtimeType type) async {
    braceletVerboseLog(
      '[Bracelet Stream] BraceletChannel.startRealtime(${type.raw}) instance=$hashCode',
    );
    await _methodChannel.invokeMethod<void>('startRealtime', {'type': type.raw});
  }

  /// Stop realtime (sends type 0).
  Future<void> stopRealtime() async {
    await _methodChannel.invokeMethod<void>('stopRealtime');
  }

  /// Request today's total activity (steps, distance, calories) from the device.
  /// Responses arrive as realtimeData with dataType 25 (TotalActivityData).
  Future<void> requestTotalActivityData() async {
    await _methodChannel.invokeMethod<void>('requestTotalActivityData');
  }

  /// Detail activity intervals (type 26). Fallback when type 24 shows zeros and type 25 is slow/missing.
  Future<void> requestDetailActivityData() async {
    try {
      await _methodChannel.invokeMethod<void>('requestDetailActivityData');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  /// Request sleep data from the device. Responses arrive as realtimeData with dataType 27 (DetailSleepData).
  Future<void> requestSleepData() async {
    await _methodChannel.invokeMethod<void>('requestSleepData');
  }

  /// Request activity mode (sport sessions) data. Responses arrive as realtimeData with dataType 30 (ActivityModeData).
  Future<void> requestActivityModeData() async {
    try {
      await _methodChannel.invokeMethod<void>('requestActivityModeData');
    } on PlatformException catch (_) {
      // Optional: not implemented on all platforms
    }
  }

  /// Request HRV (and stress) data from the device. Responses arrive as realtimeData with dataType 38 (HRVData).
  Future<void> requestHRVData() async {
    try {
      final t = DateTime.now().toString().substring(11, 19);
      braceletVerboseLog('[Bracelet] requestHRVData @ $t');
      await _methodChannel.invokeMethod<void>('requestHRVData');
    } on PlatformException catch (_) {
      // Optional: not implemented on all platforms
    } on MissingPluginException catch (_) {}
  }

  /// J2208A: SDK `StartDeviceMeasurementWithType(2, true)` — continuous HR; readings often in type 24 or 55.
  Future<void> startHeartRateMonitoring() async {
    try {
      await _methodChannel.invokeMethod<void>('startHeartRateMonitoring');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  /// Start PPG measurement on the device. Device may respond with ppgResult (type 70) or ECG result (type 52) containing blood pressure.
  Future<void> startPpgMeasurement() async {
    try {
      await _methodChannel.invokeMethod<void>('startPpgMeasurement');
    } on PlatformException catch (_) {}
  }

  /// Start SpO2 measurement (live). Results as dataType 57 and often in type 24.
  Future<void> startSpo2Monitoring() async {
    try {
      await _methodChannel.invokeMethod<void>('startSpo2Monitoring');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  /// Stop SpO2 measurement. Prefer when leaving the whole bracelet section (saves battery).
  Future<void> stopSpo2Monitoring() async {
    try {
      await _methodChannel.invokeMethod<void>('stopSpo2Monitoring');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {
      braceletVerboseLog(
        '[Bracelet SpO2] stopSpo2Monitoring not implemented (do full iOS rebuild)',
      );
    }
  }

  /// J2208A: `StartDeviceMeasurementWithType(4, true)` — temperature stream (types 24 / 58 / 45).
  Future<void> startTemperatureMonitoring() async {
    try {
      await _methodChannel.invokeMethod<void>('startTemperatureMonitoring');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  Future<void> stopTemperatureMonitoring() async {
    try {
      await _methodChannel.invokeMethod<void>('stopTemperatureMonitoring');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  /// Pull temperature history (dataType 45). Light request; complements realtime type 24.
  Future<void> requestTemperatureData() async {
    try {
      await _methodChannel.invokeMethod<void>('requestTemperatureData');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {}
  }

  /// Request manual SpO2 history. Responses as dataType 43.
  Future<void> requestManualSpo2History() async {
    try {
      await _methodChannel.invokeMethod<void>('requestManualSpo2History');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {
      braceletVerboseLog(
        '[Bracelet SpO2] requestManualSpo2History not implemented (do full iOS rebuild)',
      );
    }
  }

  /// Request automatic SpO2 history. Responses as dataType 42.
  Future<void> requestAutomaticSpo2History() async {
    try {
      await _methodChannel.invokeMethod<void>('requestAutomaticSpo2History');
    } on PlatformException catch (_) {
    } on MissingPluginException catch (_) {
      braceletVerboseLog(
        '[Bracelet SpO2] requestAutomaticSpo2History not implemented (do full iOS rebuild)',
      );
    }
  }

  /// Disconnect from the current device.
  Future<void> disconnect() async {
    await _methodChannel.invokeMethod<void>('disconnect');
  }

  /// Optional: stub for future QR/other discovery. Returns "not implemented" if no such API in SDK.
  Future<String> discoveryByQROrOther() async {
    try {
      final String? result = await _methodChannel.invokeMethod<String>('discoveryByQROrOther');
      return result ?? 'not implemented';
    } on PlatformException catch (e) {
      return 'not implemented: ${e.message}';
    }
  }
}
