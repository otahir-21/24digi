import 'package:dio/dio.dart';

import 'api_client.dart';
import 'models/api_error.dart';
import 'models/api_response.dart';
import 'models/profile_models.dart';

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _client = apiClient;

  final ApiClient _client;

  /// GET /profile/me — Bearer required
  Future<ApiResponse<Profile>> getMe() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/profile/me');
      final body = response.data;
      if (body == null) {
        return ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(
        body,
        (d) => d is Map<String, dynamic> ? Profile.fromJson(d) : null,
      );
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  /// PATCH /profile/basic
  Future<ApiResponse<ProfileUpdateData>> updateBasic(ProfileBasicPayload payload) async {
    return _profilePatch('/profile/basic', payload.toJson());
  }

  /// PATCH /profile/health
  Future<ApiResponse<ProfileUpdateData>> updateHealth(ProfileHealthPayload payload) async {
    return _profilePatch('/profile/health', payload.toJson());
  }

  /// PATCH /profile/nutrition
  Future<ApiResponse<ProfileUpdateData>> updateNutrition(ProfileNutritionPayload payload) async {
    return _profilePatch('/profile/nutrition', payload.toJson());
  }

  /// PATCH /profile/activity
  Future<ApiResponse<ProfileUpdateData>> updateActivity(ProfileActivityPayload payload) async {
    return _profilePatch('/profile/activity', payload.toJson());
  }

  /// PATCH /profile/goals
  Future<ApiResponse<ProfileUpdateData>> updateGoals(ProfileGoalsPayload payload) async {
    return _profilePatch('/profile/goals', payload.toJson());
  }

  /// POST /profile/finish
  Future<ApiResponse<ProfileUpdateData>> finishProfile(ProfileFinishPayload payload) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        '/profile/finish',
        data: payload.toJson(),
      );
      final body = response.data;
      if (body == null) {
        return ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(
        body,
        (d) => d is Map<String, dynamic> ? ProfileUpdateData.fromJson(d) : null,
      );
    } on DioException catch (e) {
      return _dioErrorResponse(e);
    }
  }

  Future<ApiResponse<ProfileUpdateData>> _profilePatch(String path, Map<String, dynamic> data) async {
    try {
      final response = await _client.dio.patch<Map<String, dynamic>>(path, data: data);
      final body = response.data;
      if (body == null) {
        return ApiResponse(success: false, error: ApiError(message: 'Empty response'));
      }
      return ApiResponse.fromJson(
        body,
        (d) => d is Map<String, dynamic> ? ProfileUpdateData.fromJson(d) : null,
      );
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
