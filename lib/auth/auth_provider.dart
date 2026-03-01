import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../api/models/profile_models.dart';
import '../firestore/profile_repository.dart';

/// Auth and profile using Firebase Auth + Firestore only. No REST API.
class AuthProvider with ChangeNotifier {
  AuthProvider() {
    _profileRepo = FirestoreProfileRepository();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  late final FirestoreProfileRepository _profileRepo;
  StreamSubscription<User?>? _authSubscription;

  User? _firebaseUser;
  Profile? _profile;
  String? _challengeId;
  String? _otpSentTo;
  String? _firebaseVerificationId;
  String? _firebasePhoneNumber;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get firebaseUser => _firebaseUser;
  Profile? get profile => _profile;
  String? get challengeId => _challengeId;
  String? get otpSentTo => _otpSentTo;
  String? get firebaseVerificationId => _firebaseVerificationId;
  bool get isFirebasePhoneFlow =>
      _firebaseVerificationId != null && _firebaseVerificationId!.isNotEmpty;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isProfileComplete => _profile?.isProfileComplete ?? false;

  FirestoreProfileRepository get profileRepo => _profileRepo;

  void applyProfileUpdate(Profile? profile, bool? isProfileComplete) {
    if (profile != null) _profile = profile;
    if (isProfileComplete != null) {
      _profile = Profile(
        name: _profile?.name,
        dateOfBirth: _profile?.dateOfBirth,
        age: _profile?.age,
        gender: _profile?.gender,
        heightCm: _profile?.heightCm,
        weightKg: _profile?.weightKg,
        bmi: _profile?.bmi,
        primaryGoal: _profile?.primaryGoal,
        dietaryGoal: _profile?.dietaryGoal,
        foodAllergies: _profile?.foodAllergies,
        otherAllergyText: _profile?.otherAllergyText,
        activityLevel: _profile?.activityLevel,
        preferredWorkouts: _profile?.preferredWorkouts,
        workoutsPerWeek: _profile?.workoutsPerWeek,
        daysOff: _profile?.daysOff,
        timezone: _profile?.timezone,
        currentBuild: _profile?.currentBuild,
        healthConsiderations: _profile?.healthConsiderations,
        isProfileComplete: isProfileComplete,
      );
    }
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      if (kDebugMode) debugPrint('[Auth] Token: no');
      _profile = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }
    final token = await user.getIdToken();
    if (kDebugMode) {
      debugPrint('[Auth] Token: ${token != null ? "yes (uid: ${user.uid})" : "no"}');
    }
    await loadProfile();
    _isInitialized = true;
    notifyListeners();
  }

  Future<String> startFirebasePhoneVerification(String phoneNumber) async {
    final completer = Completer<String>();
    final normalized =
        phoneNumber.trim().startsWith('+') ? phoneNumber.trim() : '+971$phoneNumber';
    _setLoading(true);
    _clearError();
    _firebaseVerificationId = null;
    _firebasePhoneNumber = normalized;

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: normalized,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final ok = await _signInWithFirebaseCredential(credential);
        if (!completer.isCompleted) completer.complete(ok ? 'auto_verified' : 'error');
      },
      verificationFailed: (FirebaseAuthException e) {
        _setError(e.message ?? 'Verification failed');
        _setLoading(false);
        if (!completer.isCompleted) completer.complete('error');
      },
      codeSent: (String verificationId, [int? resendToken]) {
        _firebaseVerificationId = verificationId;
        _otpSentTo = _maskPhone(normalized);
        _setLoading(false);
        notifyListeners();
        if (!completer.isCompleted) completer.complete('code_sent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _firebaseVerificationId = verificationId;
      },
      timeout: const Duration(seconds: 120),
    );

    return completer.future;
  }

  Future<bool> _signInWithFirebaseCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      _firebaseVerificationId = null;
      _firebasePhoneNumber = null;
      _otpSentTo = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  static String _maskPhone(String phone) {
    if (phone.length < 4) return '***';
    return '${phone.substring(0, phone.length - 4)}****';
  }

  Future<bool> verifyFirebasePhone(String smsCode) async {
    final verificationId = _firebaseVerificationId;
    if (verificationId == null || verificationId.isEmpty) {
      _setError('No verification in progress. Start login again.');
      return false;
    }
    _setLoading(true);
    _clearError();
    final credential =
        PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final ok = await _signInWithFirebaseCredential(credential);
    _firebaseVerificationId = null;
    _firebasePhoneNumber = null;
    _otpSentTo = null;
    _setLoading(false);
    notifyListeners();
    return ok;
  }

  Future<bool> resendFirebaseOtp() async {
    final phone = _firebasePhoneNumber;
    if (phone == null || phone.isEmpty) return false;
    final result = await startFirebasePhoneVerification(phone);
    return result == 'code_sent';
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _profile = null;
    _challengeId = null;
    _otpSentTo = null;
    _firebaseVerificationId = null;
    _firebasePhoneNumber = null;
    _clearError();
    notifyListeners();
  }

  /// Load profile from Firestore for current user.
  Future<bool> loadProfile() async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    _setLoading(true);
    _clearError();
    try {
      _profile = await _profileRepo.getProfile(uid);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Save basic profile to Firestore and refresh local profile.
  Future<bool> updateBasic(ProfileBasicPayload payload) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    try {
      await _profileRepo.updateBasic(uid, payload);
      await loadProfile();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateHealth(ProfileHealthPayload payload) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    try {
      await _profileRepo.updateHealth(uid, payload);
      await loadProfile();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNutrition(ProfileNutritionPayload payload) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    try {
      await _profileRepo.updateNutrition(uid, payload);
      await loadProfile();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateActivity(ProfileActivityPayload payload) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    try {
      await _profileRepo.updateActivity(uid, payload);
      await loadProfile();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateGoals(ProfileGoalsPayload payload) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    try {
      await _profileRepo.updateGoals(uid, payload);
      await loadProfile();
      return true;
    } catch (e) {
      _setError(e.toString());
      notifyListeners();
      return false;
    }
  }

  /// Mark profile complete and save consents to Firestore.
  Future<bool> finishProfile(ProfileConsents consents) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;
    _setLoading(true);
    _clearError();
    try {
      await _profileRepo.finishProfile(uid, consents);
      _profile = Profile(
        name: _profile?.name,
        dateOfBirth: _profile?.dateOfBirth,
        age: _profile?.age,
        gender: _profile?.gender,
        heightCm: _profile?.heightCm,
        weightKg: _profile?.weightKg,
        bmi: _profile?.bmi,
        primaryGoal: _profile?.primaryGoal,
        dietaryGoal: _profile?.dietaryGoal,
        foodAllergies: _profile?.foodAllergies,
        otherAllergyText: _profile?.otherAllergyText,
        activityLevel: _profile?.activityLevel,
        preferredWorkouts: _profile?.preferredWorkouts,
        workoutsPerWeek: _profile?.workoutsPerWeek,
        daysOff: _profile?.daysOff,
        timezone: _profile?.timezone,
        currentBuild: _profile?.currentBuild,
        healthConsiderations: _profile?.healthConsiderations,
        isProfileComplete: true,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool v) => _isLoading = v;
  void _setError(String msg) => _errorMessage = msg;
  void _clearError() => _errorMessage = null;
  void clearError() {
    _clearError();
    notifyListeners();
  }

  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
