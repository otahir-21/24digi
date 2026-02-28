/// 24digiBackend API base URL configuration.
/// Toggle [useLocal] or set via env for dev vs prod.
abstract class ApiConfig {
  static const bool useLocal = false;

  static const String prodBaseUrl =
      'http://24digi-backend-prod.eba-uixgxim5.eu-north-1.elasticbeanstalk.com';
  static const String localBaseUrl = 'http://localhost:4000';

  static String get baseUrl => useLocal ? localBaseUrl : prodBaseUrl;

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
}
