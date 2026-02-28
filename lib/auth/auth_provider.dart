import 'dart:io';

import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/auth_repository.dart';
import '../api/models/auth_models.dart';
import '../api/models/profile_models.dart';
import '../api/profile_repository.dart';
import '../api/token_storage.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    _apiClient = ApiClient(
      getAccessToken: () => _accessToken,
      refreshTokens: () => refreshTokens(),
    );
    _authRepo = AuthRepository(tokenStorage: _tokenStorage, apiClient: _apiClient);
    _profileRepo = ProfileRepository(apiClient: _apiClient);
    _init();
  }

  final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepo;
  late final ProfileRepository _profileRepo;

  String? _accessToken;
  String? _refreshToken;
  AuthUser? _user;
  Profile? _profile;
  String? _challengeId;
  String? _otpSentTo;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  AuthUser? get user => _user;
  Profile? get profile => _profile;
  String? get challengeId => _challengeId;
  String? get otpSentTo => _otpSentTo;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isProfileComplete => _user?.isProfileComplete ?? false;

  ProfileRepository get profileRepo => _profileRepo;

  Future<void> _init() async {
    _accessToken = await _tokenStorage.getAccessToken();
    _refreshToken = await _tokenStorage.getRefreshToken();
    _isInitialized = true;
    notifyListeners();
  }

  /// Called by API client interceptor on 401. Returns true if tokens were refreshed.
  Future<bool> refreshTokens() async {
    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty) return false;
    final result = await _authRepo.refreshTokens(refresh);
    if (!result.success || result.data == null) return false;
    _accessToken = result.data!.accessToken;
    _refreshToken = result.data!.refreshToken;
    await _tokenStorage.saveTokens(
      accessToken: _accessToken!,
      refreshToken: _refreshToken!,
    );
    notifyListeners();
    return true;
  }

  /// POST /auth/login/start. On success sets challengeId and otpSentTo.
  Future<bool> loginStart({
    required bool usePhone,
    String? phoneNumber,
    String? email,
    String countryCode = 'AE',
    String language = 'en',
  }) async {
    _setLoading(true);
    _clearError();
    final request = LoginStartRequest(
      loginMethod: usePhone ? 'phone' : 'email',
      phoneNumber: usePhone ? (phoneNumber ?? '') : null,
      email: !usePhone ? (email ?? '') : null,
      countryCode: countryCode,
      language: language,
      device: LoginDevice(
        platform: _platform(),
        appVersion: '1.0.0',
      ),
    );
    final response = await _authRepo.loginStart(request);
    _setLoading(false);
    if (!response.success || response.data == null) {
      _setError(response.error?.message ?? 'Login failed');
      return false;
    }
    _challengeId = response.data!.challengeId;
    _otpSentTo = response.data!.otpSentTo;
    notifyListeners();
    return true;
  }

  /// POST /auth/login/verify-otp. On success saves tokens, sets user, fetches profile.
  Future<bool> verifyOtp(String otpCode) async {
    final cid = _challengeId;
    if (cid == null || cid.isEmpty) {
      _setError('No login session. Please start login again.');
      return false;
    }
    _setLoading(true);
    _clearError();
    final request = VerifyOtpRequest(
      challengeId: cid,
      otpCode: otpCode,
      device: LoginDevice(platform: _platform()),
    );
    final response = await _authRepo.verifyOtp(request);
    if (!response.success || response.data == null) {
      _setLoading(false);
      _setError(response.error?.message ?? 'Verification failed');
      return false;
    }
    _accessToken = response.data!.accessToken;
    _refreshToken = response.data!.refreshToken;
    _user = response.data!.user;
    _challengeId = null;
    _otpSentTo = null;
    await _tokenStorage.saveTokens(
      accessToken: _accessToken!,
      refreshToken: _refreshToken!,
    );
    await loadProfile();
    _setLoading(false);
    notifyListeners();
    return true;
  }

  /// POST /auth/login/resend-otp
  Future<bool> resendOtp() async {
    final cid = _challengeId;
    if (cid == null || cid.isEmpty) return false;
    _setLoading(true);
    _clearError();
    final response = await _authRepo.resendOtp(ResendOtpRequest(challengeId: cid));
    _setLoading(false);
    if (!response.success) {
      _setError(response.error?.message ?? 'Resend failed');
      return false;
    }
    notifyListeners();
    return true;
  }

  /// POST /auth/logout then clear state.
  Future<void> logout() async {
    final refresh = _refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      await _authRepo.logout(refresh);
    }
    await _tokenStorage.clearTokens();
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _profile = null;
    _challengeId = null;
    _otpSentTo = null;
    _clearError();
    notifyListeners();
  }

  /// GET /profile/me. Call after login or when opening profile.
  Future<bool> loadProfile() async {
    if (!isLoggedIn) return false;
    _setLoading(true);
    _clearError();
    final response = await _profileRepo.getMe();
    _setLoading(false);
    if (!response.success || response.data == null) {
      _setError(response.error?.message ?? 'Failed to load profile');
      return false;
    }
    _profile = response.data;
    if (_user != null && response.data!.isProfileComplete != null) {
      _user = AuthUser(
        userId: _user!.userId,
        isProfileComplete: response.data!.isProfileComplete!,
      );
    }
    notifyListeners();
    return true;
  }

  void _setLoading(bool v) {
    _isLoading = v;
  }

  void _setError(String msg) {
    _errorMessage = msg;
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  static String _platform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}
