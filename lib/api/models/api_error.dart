/// Error payload from API envelope: { "message": "...", "code": "...", "details": [...] }
class ApiError {
  final String message;
  final String? code;
  final List<dynamic>? details;

  const ApiError({
    required this.message,
    this.code,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as String?,
      details: json['details'] as List<dynamic>?,
    );
  }
}
