import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../api/models/profile_models.dart';
import '../firestore/profile_repository.dart';
import '../bracelet/activity_storage.dart';
import '../bracelet/bracelet_channel.dart';
import '../bracelet/hydration_storage.dart';
import '../bracelet/recovery/recovery_storage.dart';
import '../bracelet/sleep_storage.dart';
import '../bracelet/weekly_data_storage.dart';
import '../bracelet/bracelet_metrics_cache.dart';
import '../services/bracelet_firestore_sync.dart';

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
        bio: _profile?.bio,
        profileImage: _profile?.profileImage,
        notificationsEnabled: _profile?.notificationsEnabled,
        emailNotificationsEnabled: _profile?.emailNotificationsEnabled,
        activityRemindersEnabled: _profile?.activityRemindersEnabled,
        hydrationRemindersEnabled: _profile?.hydrationRemindersEnabled,
        sleepRemindersEnabled: _profile?.sleepRemindersEnabled,
        weeklySummaryEnabled: _profile?.weeklySummaryEnabled,
        quietHoursEnabled: _profile?.quietHoursEnabled,
        theme: _profile?.theme,
        preferredDistanceUnit: _profile?.preferredDistanceUnit,
        preferredWeightUnit: _profile?.preferredWeightUnit,
        preferredTempUnit: _profile?.preferredTempUnit,
        alarmEnabled: _profile?.alarmEnabled,
        reminderEnabled: _profile?.reminderEnabled,
        targetWeight: _profile?.targetWeight,
        bloodType: _profile?.bloodType,
        faceIdEnabled: _profile?.faceIdEnabled,
        appLockEnabled: _profile?.appLockEnabled,
      );
    }
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user == null) {
      if (kDebugMode) debugPrint('[Auth] Token: no');
      _profile = null;
      // Clear bracelet-related in-memory caches so the next user does not see stale data.
      SleepStorage.clear();
      ActivityStorage.clear();
      WeeklyDataStorage.clear();
      await HydrationStorage.clear();
      RecoveryStorage.clear();
      BraceletChannel.lastKnownHrv = null;
      BraceletChannel.lastKnownSpo2 = null;
      BraceletChannel.lastKnownTemperature = null;
      BraceletChannel.lastKnownHeartRate = null;
      BraceletChannel.lastKnownStress = null;
      _isInitialized = true;
      notifyListeners();
      return;
    }
    await user.getIdToken();
    if (kDebugMode) {
      debugPrint('[Auth] Token: yes (uid: ${user.uid})');
    }
    await loadProfile();
    _isInitialized = true;
    notifyListeners();
  }

  Future<String> startFirebasePhoneVerification(String phoneNumber) async {
    final completer = Completer<String>();
    _setLoading(true);
    _clearError();
    _firebaseVerificationId = null;
    try {
      final normalized =
          phoneNumber.trim().startsWith('+') ? phoneNumber.trim() : '+971$phoneNumber';
      _firebasePhoneNumber = normalized;
      debugPrint('PHONE_AUTH: starting verification for $normalized');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: normalized,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('PHONE_AUTH: verificationCompleted');
          final ok = await _signInWithFirebaseCredential(credential);
          if (!completer.isCompleted) completer.complete(ok ? 'auto_verified' : 'error');
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint(
            'PHONE_AUTH: verificationFailed code=${e.code} message=${e.message}',
          );
          _setError(e.message ?? 'Verification failed');
          _setLoading(false);
          if (!completer.isCompleted) completer.complete('error');
        },
        codeSent: (String verificationId, [int? resendToken]) {
          debugPrint(
            'PHONE_AUTH: codeSent verificationId=$verificationId resendToken=$resendToken',
          );
          _firebaseVerificationId = verificationId;
          _otpSentTo = _maskPhone(normalized);
          _setLoading(false);
          notifyListeners();
          if (!completer.isCompleted) completer.complete('code_sent');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
            'PHONE_AUTH: codeAutoRetrievalTimeout verificationId=$verificationId',
          );
          _firebaseVerificationId = verificationId;
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e, st) {
      debugPrint('PHONE_AUTH: unexpected error: $e');
      debugPrintStack(stackTrace: st);
      _setError('Phone verification failed. Please try again.');
      _setLoading(false);
      if (!completer.isCompleted) completer.complete('error');
    }

    return completer.future;
  }

  Future<bool> _signInWithFirebaseCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      _firebaseUser = userCredential.user;
      await loadProfile();

      _firebaseVerificationId = null;
      _firebasePhoneNumber = null;
      _otpSentTo = null;
      _setLoading(false);
      notifyListeners();
      debugPrint('PHONE_AUTH: OTP verification success');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'PHONE_AUTH: OTP verification failed code=${e.code} message=${e.message}',
      );
      _setError(e.message ?? 'OTP verification failed');
      _setLoading(false);
      notifyListeners();
      return false;
    } catch (e, st) {
      debugPrint('PHONE_AUTH: OTP unexpected error: $e');
      debugPrintStack(stackTrace: st);
      _setError('OTP verification failed. Please try again.');
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
    debugPrint('PHONE_AUTH: verifyFirebasePhone starting for verificationId=$verificationId');
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
    // Clear bracelet-related in-memory caches so the next user does not see stale data.
    SleepStorage.clear();
    ActivityStorage.clear();
    WeeklyDataStorage.clear();
    await HydrationStorage.clear();
    RecoveryStorage.clear();
    BraceletChannel.lastKnownHrv = null;
    BraceletChannel.lastKnownSpo2 = null;
    BraceletChannel.lastKnownTemperature = null;
    BraceletChannel.lastKnownHeartRate = null;
    BraceletChannel.lastKnownStress = null;
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
      // Bracelet disk + jsonDecode after the first frame: reduces overlap with Firebase / engine on
      // iOS debug where some devices hit EXC_BAD_ACCESS on DartWorker during login bursts.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_loadBraceletDiskCacheAfterFrame(uid));
      });
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> _loadBraceletDiskCacheAfterFrame(String uid) async {
    try {
      await BraceletMetricsCache.instance.load(uid);
      await HydrationStorage.load(uid);
      BraceletMetricsCache.instance.applyToMemoryStores();
      scheduleMicrotask(
        () => unawaited(BraceletFirestoreSync.syncFromLocalCache(uid)),
      );
      notifyListeners();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[Auth] bracelet disk cache failed: $e');
        debugPrintStack(stackTrace: st);
      }
      _setError(e.toString());
      notifyListeners();
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

  Future<bool> updateSettings(Map<String, dynamic> data) async {
    final uid = _firebaseUser?.uid;
    if (uid == null) return false;

    // Split data into profile and settings collections
    final settingsKeys = {
      'notifications_enabled',
      'email_notifications_enabled',
      'activity_reminders_enabled',
      'hydration_reminders_enabled',
      'sleep_reminders_enabled',
      'weekly_summary_enabled',
      'quiet_hours_enabled',
      'theme',
      'preferred_distance_unit',
      'preferred_weight_unit',
      'preferred_temp_unit',
      'alarm_enabled',
      'reminder_enabled',
      'face_id_enabled',
      'app_lock_enabled',
      'haptic_enabled',
      'animations_enabled',
      'date_format',
      'time_format',
      'language',
    };

    final settingsMap = <String, dynamic>{};
    final profileMap = <String, dynamic>{};

    data.forEach((key, value) {
      if (settingsKeys.contains(key)) {
        settingsMap[key] = value;
      } else {
        profileMap[key] = value;
      }
    });

    try {
      if (profileMap.isNotEmpty) {
        await _profileRepo.updateProfileData(uid, profileMap);
      }
      if (settingsMap.isNotEmpty) {
        await _profileRepo.updateSettingsData(uid, settingsMap);
      }
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
        bio: _profile?.bio,
        profileImage: _profile?.profileImage,
        notificationsEnabled: _profile?.notificationsEnabled,
        emailNotificationsEnabled: _profile?.emailNotificationsEnabled,
        activityRemindersEnabled: _profile?.activityRemindersEnabled,
        hydrationRemindersEnabled: _profile?.hydrationRemindersEnabled,
        sleepRemindersEnabled: _profile?.sleepRemindersEnabled,
        weeklySummaryEnabled: _profile?.weeklySummaryEnabled,
        quietHoursEnabled: _profile?.quietHoursEnabled,
        theme: _profile?.theme,
        preferredDistanceUnit: _profile?.preferredDistanceUnit,
        preferredWeightUnit: _profile?.preferredWeightUnit,
        preferredTempUnit: _profile?.preferredTempUnit,
        alarmEnabled: _profile?.alarmEnabled,
        reminderEnabled: _profile?.reminderEnabled,
        targetWeight: _profile?.targetWeight,
        bloodType: _profile?.bloodType,
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
