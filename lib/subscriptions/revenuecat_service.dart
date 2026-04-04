import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../core/api_config.dart';
import '../core/revenuecat_keys.dart';

/// RevenueCat: identifies users with Firebase Auth [uid], purchases, restore.
class RevenueCatService {
  RevenueCatService._();

  static bool _configured = false;

  static bool get isConfigured => _configured;

  /// Call once after [Firebase.initializeApp].
  static Future<void> initialize() async {
    if (kIsWeb) return;

    String? key;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        key = RevenueCatKeys.ios.isNotEmpty ? RevenueCatKeys.ios : null;
        break;
      case TargetPlatform.android:
        key = RevenueCatKeys.android.isNotEmpty ? RevenueCatKeys.android : null;
        break;
      default:
        return;
    }

    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[RevenueCat] Skipped: no REVENUECAT_* dart-define for this platform.',
        );
      }
      return;
    }

    await Purchases.configure(PurchasesConfiguration(key));
    _configured = true;
    if (kDebugMode) {
      debugPrint('[RevenueCat] Configured for $defaultTargetPlatform');
    }
  }

  /// Links purchases to Firebase Auth user (call after sign-in).
  static Future<void> identifyUser(String uid) async {
    if (!_configured || uid.isEmpty) return;
    try {
      await Purchases.logIn(uid);
      if (kDebugMode) {
        final p = uid.length > 8 ? '${uid.substring(0, 8)}…' : uid;
        debugPrint('[RevenueCat] logIn ok ($p)');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] logIn failed: $e\n$st');
      }
    }
  }

  static Future<void> logOutUser() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      if (kDebugMode) debugPrint('[RevenueCat] logOut: $e');
    }
  }

  static Future<bool> hasActiveCByAiEntitlement() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active
          .containsKey(ApiConfig.revenueCatCByAiEntitlementId);
    } catch (e) {
      if (kDebugMode) debugPrint('[RevenueCat] getCustomerInfo: $e');
      return false;
    }
  }

  /// Picks a package from the **current** offering: optional [revenueCatCByAiPackageIdentifier],
  /// else monthly, else first available.
  static Future<PurchaseResult?> purchaseCByAiPackage() async {
    if (!_configured) return null;

    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      throw StateError(
        'No current offering in RevenueCat. Set a "current" offering in the dashboard.',
      );
    }

    Package? pkg;
    final hint = ApiConfig.revenueCatCByAiPackageIdentifier.trim();
    if (hint.isNotEmpty) {
      for (final p in current.availablePackages) {
        if (p.identifier == hint) {
          pkg = p;
          break;
        }
      }
    }
    pkg ??= current.monthly;
    if (pkg == null && current.availablePackages.isNotEmpty) {
      pkg = current.availablePackages.first;
    }
    if (pkg == null) {
      throw StateError(
        'No packages in current offering. Attach products to the offering in RevenueCat.',
      );
    }

    try {
      return await Purchases.purchase(PurchaseParams.package(pkg));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return null;
      }
      rethrow;
    }
  }

  static Future<CustomerInfo> restorePurchases() async {
    return Purchases.restorePurchases();
  }
}
