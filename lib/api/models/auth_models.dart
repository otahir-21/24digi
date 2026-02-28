/// Request: POST /auth/login/start
class LoginStartRequest {
  final String loginMethod; // "phone" | "email"
  final String? phoneNumber;
  final String? email;
  final String? countryCode;
  final String? language; // "en" | "ar"
  final LoginDevice? device;

  const LoginStartRequest({
    required this.loginMethod,
    this.phoneNumber,
    this.email,
    this.countryCode,
    this.language,
    this.device,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'login_method': loginMethod,
    };
    if (phoneNumber != null) map['phone_number'] = phoneNumber;
    if (email != null) map['email'] = email;
    if (countryCode != null) map['country_code'] = countryCode;
    if (language != null) map['language'] = language;
    if (device != null) map['device'] = device!.toJson();
    return map;
  }
}

class LoginDevice {
  final String? deviceId;
  final String platform; // "ios" | "android" | "web"
  final String? appVersion;
  final String? pushToken;

  const LoginDevice({
    this.deviceId,
    required this.platform,
    this.appVersion,
    this.pushToken,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'platform': platform};
    if (deviceId != null) map['device_id'] = deviceId;
    if (appVersion != null) map['app_version'] = appVersion;
    if (pushToken != null) map['push_token'] = pushToken;
    return map;
  }
}

/// Response data: login/start
class LoginStartData {
  final String challengeId;
  final String? otpSentTo;
  final int? expiresInSec;

  const LoginStartData({
    required this.challengeId,
    this.otpSentTo,
    this.expiresInSec,
  });

  factory LoginStartData.fromJson(Map<String, dynamic> json) {
    return LoginStartData(
      challengeId: json['challenge_id'] as String,
      otpSentTo: json['otp_sent_to'] as String?,
      expiresInSec: json['expires_in_sec'] as int?,
    );
  }
}

/// Request: POST /auth/login/verify-otp
class VerifyOtpRequest {
  final String challengeId;
  final String otpCode;
  final LoginDevice? device;

  const VerifyOtpRequest({
    required this.challengeId,
    required this.otpCode,
    this.device,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'challenge_id': challengeId,
      'otp_code': otpCode,
    };
    if (device != null) map['device'] = device!.toJson();
    return map;
  }
}

/// Response data: verify-otp
class VerifyOtpData {
  final String accessToken;
  final String refreshToken;
  final AuthUser user;

  const VerifyOtpData({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthUser {
  final String userId;
  final bool isProfileComplete;

  const AuthUser({
    required this.userId,
    required this.isProfileComplete,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['user_id'] as String? ?? '',
      isProfileComplete: json['is_profile_complete'] as bool? ?? false,
    );
  }
}

/// Request: POST /auth/login/resend-otp
class ResendOtpRequest {
  final String challengeId;

  const ResendOtpRequest({required this.challengeId});

  Map<String, dynamic> toJson() => {'challenge_id': challengeId};
}

/// Response data: resend-otp
class ResendOtpData {
  final int? expiresInSec;

  const ResendOtpData({this.expiresInSec});

  factory ResendOtpData.fromJson(Map<String, dynamic> json) {
    return ResendOtpData(expiresInSec: json['expires_in_sec'] as int?);
  }
}

/// Request: POST /auth/token/refresh
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

/// Response data: token/refresh
class RefreshTokenData {
  final String accessToken;
  final String refreshToken;

  const RefreshTokenData({
    required this.accessToken,
    required this.refreshToken,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    return RefreshTokenData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

/// Request: POST /auth/logout
class LogoutRequest {
  final String refreshToken;

  const LogoutRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

/// Request: POST /auth/login/verify-firebase (Firebase Phone Auth)
class VerifyFirebaseRequest {
  final String firebaseIdToken;
  final LoginDevice? device;

  const VerifyFirebaseRequest({
    required this.firebaseIdToken,
    this.device,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'firebase_id_token': firebaseIdToken};
    if (device != null) map['device'] = device!.toJson();
    return map;
  }
}
