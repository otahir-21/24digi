import 'api_error.dart';

/// Standard API envelope: { "success": bool, "data": T?, "error": ApiError? }
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final dataJson = json['data'];
    final errorJson = json['error'];

    T? data;
    if (dataJson != null && fromJsonT != null) {
      data = fromJsonT(dataJson);
    } else if (dataJson != null && dataJson is T) {
      data = dataJson;
    }

    ApiError? error;
    if (errorJson != null && errorJson is Map<String, dynamic>) {
      error = ApiError.fromJson(errorJson);
    }

    return ApiResponse(success: success, data: data, error: error);
  }
}
