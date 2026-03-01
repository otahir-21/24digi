import 'dart:async';
import 'package:flutter/services.dart';

/// Method channel name for bracelet commands (scan, connect, startRealtime, etc.)
const String braceletMethodChannelName = 'com.24digi/bracelet';

/// Event channel name for streaming (realtime data, scan results, connection state)
const String braceletEventChannelName = 'com.24digi/bracelet/events';

/// Realtime type: 0 = off, 1 = step (on change), 2 = step with temperature (1 sec)
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

  /// Request sleep data from the device. Responses arrive as realtimeData with dataType 27 (DetailSleepData).
  Future<void> requestSleepData() async {
    await _methodChannel.invokeMethod<void>('requestSleepData');
  }

  /// Request HRV (and stress) data from the device. Responses arrive as realtimeData with dataType 38 (HRVData).
  Future<void> requestHRVData() async {
    try {
      await _methodChannel.invokeMethod<void>('requestHRVData');
    } on PlatformException catch (_) {
      // Optional: not implemented on all platforms
    }
  }

  /// Start PPG measurement on the device. Device may respond with ppgResult (type 70) or ECG result (type 52) containing blood pressure.
  Future<void> startPpgMeasurement() async {
    try {
      await _methodChannel.invokeMethod<void>('startPpgMeasurement');
    } on PlatformException catch (_) {}
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
