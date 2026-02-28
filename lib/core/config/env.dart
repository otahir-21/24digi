/// App environment. Set via build flavor or kDebugMode for dev vs prod.
/// For flavors: use --dart-define=ENV=staging or read from flutter_dotenv.
enum AppEnv {
  development,
  staging,
  production,
}

abstract class Env {
  static AppEnv _current = AppEnv.production;

  static AppEnv get current => _current;

  static set current(AppEnv value) {
    _current = value;
  }

  /// Call from main() or flavor entry point, e.g.:
  /// void main() {
  ///   Env.current = kDebugMode ? AppEnv.development : AppEnv.production;
  ///   runApp(const DigiApp());
  /// }
  static bool get isProduction => _current == AppEnv.production;
  static bool get isStaging => _current == AppEnv.staging;
  static bool get isDevelopment => _current == AppEnv.development;
}
