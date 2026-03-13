import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/models/profile_models.dart';

const String _profileCollection = 'profile';
const String _settingsCollection = 'profile-setting';

/// Reads and writes user profile in Firestore.
/// Data is split into 'profile' and 'profile-setting' collections.
class FirestoreProfileRepository {
  FirestoreProfileRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _firestore.collection(_profileCollection);
  CollectionReference<Map<String, dynamic>> get _settings =>
      _firestore.collection(_settingsCollection);

  Future<Profile?> getProfile(String uid) async {
    final profileDoc = await _profiles.doc(uid).get();
    final settingsDoc = await _settings.doc(uid).get();

    final Map<String, dynamic> data = {};
    if (profileDoc.exists && profileDoc.data() != null) {
      data.addAll(profileDoc.data()!);
    }
    if (settingsDoc.exists && settingsDoc.data() != null) {
      data.addAll(settingsDoc.data()!);
    }

    if (data.isEmpty) return null;
    return Profile.fromJson(data);
  }

  /// Merge [data] into existing profile doc.
  Future<void> updateProfileData(String uid, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    await _profiles.doc(uid).set(data, SetOptions(merge: true));
  }

  /// Merge [data] into existing settings doc.
  Future<void> updateSettingsData(String uid, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    await _settings.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateBasic(String uid, ProfileBasicPayload payload) async {
    await updateProfileData(uid, payload.toJson());
  }

  Future<void> updateHealth(String uid, ProfileHealthPayload payload) async {
    // Health data usually goes to profile
    await updateProfileData(uid, payload.toJson());
  }

  Future<void> updateNutrition(
    String uid,
    ProfileNutritionPayload payload,
  ) async {
    await updateProfileData(uid, payload.toJson());
  }

  Future<void> updateActivity(
    String uid,
    ProfileActivityPayload payload,
  ) async {
    await updateProfileData(uid, payload.toJson());
  }

  Future<void> updateGoals(String uid, ProfileGoalsPayload payload) async {
    await updateProfileData(uid, payload.toJson());
  }

  /// Set profile complete and store consents.
  Future<void> finishProfile(String uid, ProfileConsents consents) async {
    await updateProfileData(uid, {
      'is_profile_complete': true,
      'consents': {
        'terms_accepted': consents.termsAccepted,
        'privacy_accepted': consents.privacyAccepted,
        'health_disclaimer_accepted': consents.healthDisclaimerAccepted,
      },
    });
  }
}
