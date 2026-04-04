import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/api_config.dart';
import 'revenuecat_service.dart';

/// C BY AI access flag stored in Firestore (updated by your backend / Cloud
/// Function after App Store or Google Play confirms a purchase — do not trust
/// client-only writes in production).
///
/// Document: `user_entitlements/{uid}`
///
/// Suggested fields:
/// - `c_by_ai_active` (bool) — subscription is active
/// - `c_by_ai_expires_at` (Timestamp?, optional) — omit or null for non-expiring
///
/// Suggested security rules: allow read if `request.auth.uid == resource.id`;
/// deny client writes (only admin SDK / Cloud Functions).
class CByAiEntitlement {
  CByAiEntitlement._();

  static const String collection = 'user_entitlements';

  static Future<bool> userHasAccess(String? uid) async {
    if (!ApiConfig.cByAiPaywallEnabled) return true;
    if (uid == null || uid.isEmpty) return false;

    if (await RevenueCatService.hasActiveCByAiEntitlement()) {
      return true;
    }

    final snap =
        await FirebaseFirestore.instance.collection(collection).doc(uid).get();
    if (!snap.exists) return false;
    final data = snap.data();
    if (data == null) return false;

    final active = data['c_by_ai_active'] as bool? ?? false;
    if (!active) return false;

    final exp = data['c_by_ai_expires_at'];
    if (exp == null) return true;
    if (exp is Timestamp) {
      return exp.toDate().isAfter(DateTime.now());
    }
    return false;
  }
}
