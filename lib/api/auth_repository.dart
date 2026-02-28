import 'package:dio/dio.dart';

import 'api_client.dart';
import 'models/api_response.dart';
import 'models/auth_models.dart';
import 'token_storage.dart';

class AuthRepository {
  AuthRepository({
    required TokenStorage tokenStorage,
    required ApiClient apiClient,
  })  : _storage = tokenStorage,
        _client = apiClient;

  final TokenStorage _storage;
  final ApiClient _client;

  /// POST /auth/login/start
  Future<ApiResponse<LoginStartData>> loginStart(LoginStartRequest request) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login/start',
        data: request.toJson(),
      );
      final body = response.data;
      if (body == null) {
        return const ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(body, (d) => LoginStartData.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  /// POST /auth/login/verify-otp
  Future<ApiResponse<VerifyOtpData>> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login/verify-otp',
        data: request.toJson(),
      );
      final body = response.data;
      if (body == null) {
        return const ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(body, (d) => VerifyOtpData.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  /// POST /auth/login/resend-otp
  Future<ApiResponse<ResendOtpData>> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/login/resend-otp',
        data: request.toJson(),
      );
      final body = response.data;
      if (body == null) {
        return const ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(body, (d) => ResendOtpData.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  /// POST /auth/token/refresh
  Future<ApiResponse<RefreshTokenData>> refreshTokens(String refreshToken) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/token/refresh',
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );
      final body = response.data;
      if (body == null) {
        return const ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(body, (d) => RefreshTokenData.fromJson(d as Map<String, dynamic>));
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  /// POST /auth/logout
  Future<ApiResponse<Map<String, dynamic>>> logout(String refreshToken) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/auth/logout',
        data: LogoutRequest(refreshToken: refreshToken).toJson(),
      );
      final body = response.data;
      if (body == null) {
        return const ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(body, (d) => d as Map<String, dynamic>);
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  ApiResponse<T> _dioErrorResponse<T>(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final resp = ApiResponse<Never>.fromJson(data, null);
      return ApiResponse(success: false, error: resp.error);
    }
    return ApiResponse(
      success: false,
      error: ApiError(message: e.message ?? 'Network error'),
    );
  }
}
