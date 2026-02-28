import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../core/api_config.dart';

typedef TokenGetter = String? Function();
typedef TokenRefresher = Future<bool> Function();

/// Dio client for 24digiBackend API.
/// - baseUrl, timeouts from [ApiConfig].
/// - [ApiLoggingInterceptor] logs full request/response for debugging.
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
    _dio.interceptors.add(ApiLoggingInterceptor());
    _dio.interceptors.add(AuthInterceptor(
      dio: _dio,
      getAccessToken: _getAccessToken,
      refreshTokens: _refreshTokens,
    ));
  }

  final TokenGetter _getAccessToken;
  final TokenRefresher _refreshTokens;
  late final Dio _dio;

  Dio get dio => _dio;
}

/// Logs full request and response (status, headers, body) for debugging internal server errors.
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final uri = options.uri.toString();
      final headers = Map<String, dynamic>.from(options.headers);
      if (headers['Authorization'] != null) {
        headers['Authorization'] = 'Bearer ***';
      }
      debugPrint('[API REQUEST] ${options.method} $uri');
      debugPrint('[API REQUEST HEADERS] $headers');
      if (options.data != null) {
        debugPrint('[API REQUEST BODY] ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final status = response.statusCode;
      final uri = response.requestOptions.uri.toString();
      debugPrint('[API RESPONSE] $status ${response.requestOptions.method} $uri');
      debugPrint('[API RESPONSE HEADERS] ${response.headers.map}');
      debugPrint('[API RESPONSE BODY] ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final status = err.response?.statusCode;
      final uri = err.requestOptions.uri.toString();
      debugPrint('[API ERROR] $status ${err.requestOptions.method} $uri');
      debugPrint('[API ERROR MESSAGE] ${err.message}');
      debugPrint('[API ERROR RESPONSE BODY] ${err.response?.data}');
      debugPrint('[API ERROR RESPONSE HEADERS] ${err.response?.headers.map}');
    }
    handler.next(err);
  }
}

/// Attaches Authorization: Bearer token. On 401, calls refresh then retries once.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required TokenGetter getAccessToken,
    required TokenRefresher refreshTokens,
  })  : _dio = dio,
        _getAccessToken = getAccessToken,
        _refreshTokens = refreshTokens;

  final Dio _dio;
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
    if (err.requestOptions.extra['auth_retried'] == true) {
      return handler.next(err);
    }
    final refreshed = await _refreshTokens();
    if (!refreshed) {
      return handler.next(err);
    }
    final opts = err.requestOptions;
    opts.extra['auth_retried'] = true;
    final token = _getAccessToken();
    if (token != null) {
      opts.headers['Authorization'] = 'Bearer $token';
    }
    try {
      final response = await _dio.fetch(opts);
      handler.resolve(response);
    } catch (e) {
      handler.next(DioException(requestOptions: opts, error: e));
    }
  }
}
