import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last successfully connected bracelet so the app can
/// auto-reconnect on startup without requiring the user to scan again.
class BraceletDeviceStorage {
  BraceletDeviceStorage._();

  static const String _keyIdentifier = 'bracelet_last_identifier';
  static const String _keyName = 'bracelet_last_name';
  static const String _keyLastSyncMs = 'bracelet_last_sync_ms';

  static String? _identifier;
  static String? _name;
  static DateTime? _lastSyncTime;

  static DateTime? get lastSyncTime => _lastSyncTime;

  /// Call whenever fresh bracelet data arrives so Settings can show "Last sync".
  static Future<void> saveLastSync() async {
    _lastSyncTime = DateTime.now();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_keyLastSyncMs, _lastSyncTime!.millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletDeviceStorage] saveLastSync error: $e');
    }
  }

  static String? get lastIdentifier => _identifier;
  static String? get lastName => _name;

  /// Persists [identifier] and [name] as the last connected device.
  /// Call this whenever a connection is confirmed successful.
  static Future<void> save(String identifier, String name) async {
    _identifier = identifier;
    _name = name;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_keyIdentifier, identifier);
      await p.setString(_keyName, name);
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletDeviceStorage] save error: $e');
    }
  }

  /// Loads the last device from SharedPreferences into memory.
  /// Call once on app start / bracelet module open before attempting auto-reconnect.
  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _identifier = p.getString(_keyIdentifier);
      _name = p.getString(_keyName);
      final ms = p.getInt(_keyLastSyncMs);
      if (ms != null) _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletDeviceStorage] load error: $e');
    }
  }

  /// Clears the saved device (e.g. when user explicitly unpairs/forgets).
  static Future<void> clear() async {
    _identifier = null;
    _name = null;
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_keyIdentifier);
      await p.remove(_keyName);
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletDeviceStorage] clear error: $e');
    }
  }
}
