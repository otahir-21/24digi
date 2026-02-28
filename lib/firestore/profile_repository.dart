import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/models/profile_models.dart';

const String _usersCollection = 'users';

/// Reads and writes user profile in Firestore `users/{uid}`.
/// No REST API; all data stored in Firestore.
class FirestoreProfileRepository {
  FirestoreProfileRepository() : _firestore = FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(_usersCollection);

  Future<Profile?> getProfile(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return Profile.fromJson(doc.data()!);
  }

  /// Merge [data] into existing profile doc. Creates doc if missing.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<void> updateBasic(String uid, ProfileBasicPayload payload) async {
    await updateProfile(uid, payload.toJson());
  }

  Future<void> updateHealth(String uid, ProfileHealthPayload payload) async {
    await updateProfile(uid, payload.toJson());
  }

  Future<void> updateNutrition(String uid, ProfileNutritionPayload payload) async {
    await updateProfile(uid, payload.toJson());
  }

  Future<void> updateActivity(String uid, ProfileActivityPayload payload) async {
    await updateProfile(uid, payload.toJson());
  }

  Future<void> updateGoals(String uid, ProfileGoalsPayload payload) async {
    await updateProfile(uid, payload.toJson());
  }

  /// Set profile complete and store consents.
  Future<void> finishProfile(String uid, ProfileConsents consents) async {
    await updateProfile(uid, {
      'is_profile_complete': true,
      'consents': {
        'terms_accepted': consents.termsAccepted,
        'privacy_accepted': consents.privacyAccepted,
        'health_disclaimer_accepted': consents.healthDisclaimerAccepted,
      },
    });
  }
}
