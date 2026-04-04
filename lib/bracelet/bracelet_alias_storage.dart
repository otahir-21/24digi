import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-defined display names for bracelet devices, keyed by BLE identifier.
class BraceletAliasStorage {
  BraceletAliasStorage._();

  static const String _keyPrefix = 'bracelet_alias_v1_';

  static String? _currentIdentifier;
  static String? _currentAlias;

  /// Full multi-device alias cache so scan lists can show aliases for any device,
  /// not just the currently connected one.
  static final Map<String, String> _cache = {};

  /// Bumps whenever an alias is set or loaded; listen to update UI.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String? get currentAlias => _currentAlias;
  static String? get currentIdentifier => _currentIdentifier;

  /// Returns the display name for [identifier].
  /// Checks the full multi-device cache first, then falls back to [fallback].
  static String displayName(String? identifier, String fallback) {
    if (identifier != null) {
      final cached = _cache[identifier];
      if (cached != null && cached.isNotEmpty) return cached;
    }
    return fallback;
  }

  /// Persist an alias for [identifier] and update the in-memory cache.
  static void setAlias(String identifier, String alias) {
    final trimmed = alias.trim();
    if (_currentIdentifier == identifier) {
      _currentAlias = trimmed.isEmpty ? null : trimmed;
    }
    if (trimmed.isEmpty) {
      _cache.remove(identifier);
    } else {
      _cache[identifier] = trimmed;
    }
    unawaited(_persist(identifier, trimmed.isEmpty ? null : trimmed));
    revision.value = revision.value + 1;
  }

  /// Load the alias for [identifier] from SharedPreferences into the cache.
  /// Idempotent — safe to call multiple times; re-reads if [force] is true.
  static Future<void> load(String? identifier, {bool force = false}) async {
    _currentIdentifier = identifier;
    if (identifier == null || identifier.isEmpty) {
      _currentAlias = null;
      return;
    }
    if (!force && _cache.containsKey(identifier)) {
      _currentAlias = _cache[identifier];
      revision.value = revision.value + 1;
      return;
    }
    try {
      final p = await SharedPreferences.getInstance();
      final alias = p.getString('$_keyPrefix$identifier');
      if (alias != null && alias.isNotEmpty) {
        _cache[identifier] = alias;
      } else {
        _cache.remove(identifier);
      }
      _currentAlias = alias;
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletAliasStorage] load error: $e');
      _currentAlias = null;
    }
    revision.value = revision.value + 1;
  }

  /// Eagerly loads aliases for a list of identifiers (e.g. from a scan result list).
  /// Already-cached identifiers are skipped.
  static Future<void> loadMany(Iterable<String> identifiers) async {
    final toLoad = identifiers.where((id) => id.isNotEmpty && !_cache.containsKey(id)).toList();
    if (toLoad.isEmpty) return;
    try {
      final p = await SharedPreferences.getInstance();
      for (final id in toLoad) {
        final alias = p.getString('$_keyPrefix$id');
        if (alias != null && alias.isNotEmpty) {
          _cache[id] = alias;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[BraceletAliasStorage] loadMany error: $e');
    }
    revision.value = revision.value + 1;
  }

  /// Remove the alias for [identifier].
  static Future<void> clear(String identifier) async {
    if (_currentIdentifier == identifier) _currentAlias = null;
    _cache.remove(identifier);
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
