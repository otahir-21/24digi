import 'package:dio/dio.dart';

import '../core/api_config.dart';

typedef TokenGetter = String? Function();
typedef TokenRefresher = Future<bool> Function();

/// Dio client for 24digiBackend API.
/// - baseUrl, timeouts from [ApiConfig].
/// - [AuthInterceptor] attaches Bearer token and on 401 tries refresh then retry.
class ApiClient {
  ApiClient({
    TokenGetter? getAccessToken,
    TokenRefresher? refreshTokens,
  })  : _getAccessToken = getAccessToken ?? (() => null),
        _refreshTokens = refreshTokens ?? (() async => false) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.add(AuthInterceptor(
      getAccessToken: _getAccessToken,
      refreshTokens: _refreshTokens,
    ));
  }

  final TokenGetter _getAccessToken;
  final TokenRefresher _refreshTokens;
  late final Dio _dio;

  Dio get dio => _dio;
}

/// Attaches Authorization: Bearer <access_token>. On 401, calls refresh then retries once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenGetter getAccessToken,
    required TokenRefresher refreshTokens,
  })  : _getAccessToken = getAccessToken,
        _refreshTokens = refreshTokens;

  final TokenGetter _getAccessToken;
  final TokenRefresher _refreshTokens;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final refreshed = await _refreshTokens();
    if (!refreshed) {
      return handler.next(err);
    }
    // Retry the request with new token
    final opts = err.requestOptions;
    final token = _getAccessToken();
    if (token != null) {
      opts.headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await Dio().fetch(opts);
      handler.resolve(response);
    } catch (e) {
      handler.next(err is DioException ? err : DioException(requestOptions: opts, error: e));
    }
  }
}
