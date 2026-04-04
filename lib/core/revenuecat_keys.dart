/// Public SDK keys only (safe in client builds). Get them from RevenueCat
/// Project settings → API keys → **public** app-specific keys.
///
/// Prefer passing at build time (CI / local):
/// `flutter run --dart-define=REVENUECAT_IOS_KEY=appl_xxx --dart-define=REVENUECAT_ANDROID_KEY=goog_xxx`
abstract class RevenueCatKeys {
  static const String ios = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
    defaultValue: '',
  );
  static const String android = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
    defaultValue: '',
  );

  static bool get hasConfiguredPlatformKey {
    return ios.isNotEmpty || android.isNotEmpty;
  }
}
