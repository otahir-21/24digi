import 'config/env.dart';

/// 24digiBackend API base URL configuration.
/// Uses [Env.current] when [useEnv] is true; otherwise [useLocal] for quick toggle.
abstract class ApiConfig {
  /// Set to true to use [Env.current] for base URL (dev/staging/prod).
  static const bool useEnv = false;

  /// When [useEnv] is false, set to true for local backend.
  static const bool useLocal = false;

  static const String prodBaseUrl =
      'http://24digi-backend-prod.eba-uixgxim5.eu-north-1.elasticbeanstalk.com';
  static const String stagingBaseUrl =
      prodBaseUrl; // Replace with staging URL when you have it
  static const String localBaseUrl = 'http://localhost:4000';

  static String get baseUrl {
    if (useEnv) {
      switch (Env.current) {
        case AppEnv.development:
          return localBaseUrl;
        case AppEnv.staging:
          return stagingBaseUrl;
        case AppEnv.production:
          return prodBaseUrl;
      }
    }
    return useLocal ? localBaseUrl : prodBaseUrl;
  }

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  /// When true, LOGIN skips OTP and goes straight to onboarding (setup2).
  /// Set to false so user goes to OTP screen (Firebase + backend flow).
  static const bool bypassOtpForDev = false;

  /// When true, phone login uses Firebase Phone Auth; when false, uses backend OTP.
  static const bool useFirebasePhoneAuth = true;

  /// Set to true to skip Firebase.initializeApp() (e.g. to debug iOS SIGKILL / launch issues).
  static const bool skipFirebaseInit = false;

  /// When true, C BY AI requires a Firestore entitlement (`user_entitlements/{uid}`)
  /// before continuing past the welcome screen or recovering a session into the tracker.
  /// Set to false until IAP + Cloud Function (or admin) writes that document.
  static const bool cByAiPaywallEnabled = false;

  /// RevenueCat dashboard → Entitlements → identifier (must match exactly).
  static const String revenueCatCByAiEntitlementId = 'c_by_ai';

  /// Optional: RevenueCat package identifier on the **current** offering (e.g. `$rc_monthly`).
  /// Empty = use [Offering.monthly] or first package.
  static const String revenueCatCByAiPackageIdentifier = '';

  /// C BY AI `POST .../generate-meals/start`: which backend pipeline to use.
  /// Default **`standard`** = your rules-based / standard plan generator (not LLM).
  /// Override if your API expects another value, e.g. `--dart-define=C_BY_AI_PLAN_GENERATOR=ai`
  static const String cByAiPlanGenerator = String.fromEnvironment(
    'C_BY_AI_PLAN_GENERATOR',
    defaultValue: 'standard',
  );
}
