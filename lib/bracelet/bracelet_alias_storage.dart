import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-defined display names for bracelet devices, keyed by BLE identifier.
/// The hardware device name cannot be changed via the SDK; this stores a local alias instead.
class BraceletAliasStorage {
  BraceletAliasStorage._();

  static const String _keyPrefix = 'bracelet_alias_v1_';

  static String? _currentIdentifier;
  static String? _currentAlias;

  /// Bumps whenever an alias is set or loaded; listen to update UI.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String? get currentAlias => _currentAlias;
  static String? get currentIdentifier => _currentIdentifier;

  /// Returns the alias for [identifier] if loaded, otherwise [fallback].
  static String displayName(String? identifier, String fallback) {
    if (identifier != null &&
        identifier == _currentIdentifier &&
        _currentAlias != null &&
        _currentAlias!.isNotEmpty) {
      return _currentAlias!;
    }
    return fallback;
  }

  /// Persist an alias for [identifier] and update the in-memory cache.
  static void setAlias(String identifier, String alias) {
    final trimmed = alias.trim();
    if (_currentIdentifier == identifier) {
      _currentAlias = trimmed.isEmpty ? null : trimmed;
    }
    unawaited(_persist(identifier, trimmed.isEmpty ? null : trimmed));
    revision.value = revision.value + 1;
  }

  /// Load the alias for [identifier] from SharedPreferences.
  static Future<void> load(String? identifier) async {
    _currentIdentifier = identifier;
    if (identifier == null || identifier.isEmpty) {
      _currentAlias = null;
      return;
    }
    try {
      final p = await SharedPreferences.getInstance();
      _currentAlias = p.getString('$_keyPrefix$identifier');
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletAliasStorage] load error: $e');
      _currentAlias = null;
    }
    revision.value = revision.value + 1;
  }

  /// Remove the alias for [identifier].
  static Future<void> clear(String identifier) async {
    if (_currentIdentifier == identifier) _currentAlias = null;
    await _persist(identifier, null);
    revision.value = revision.value + 1;
  }

  static Future<void> _persist(String identifier, String? alias) async {
    try {
      final p = await SharedPreferences.getInstance();
      if (alias == null || alias.isEmpty) {
        await p.remove('$_keyPrefix$identifier');
      } else {
        await p.setString('$_keyPrefix$identifier', alias);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletAliasStorage] persist error: $e');
    }
  }
}
