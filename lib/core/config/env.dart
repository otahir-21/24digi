/// App environment. Set via build flavor or kDebugMode for dev vs prod.
/// For flavors: use --dart-define=ENV=staging or read from flutter_dotenv.
enum AppEnv {
  development,
  staging,
  production,
}

abstract class Env {
  /// Set from main() or flavor entry point, e.g.:
  /// void main() {
  ///   Env.current = kDebugMode ? AppEnv.development : AppEnv.production;
  ///   runApp(const DigiApp());
  /// }
  static AppEnv current = AppEnv.production;

  static bool get isProduction => current == AppEnv.production;
  static bool get isStaging => current == AppEnv.staging;
  static bool get isDevelopment => current == AppEnv.development;
}
