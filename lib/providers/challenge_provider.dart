import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/challenge_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ChallengeService _service = ChallengeService();
  
  Map<String, bool> _locks = {
    'private_zone_locked': true,
    'ai_challenge_locked': true,
    'adventure_zone_locked': true,
  };
  
  Map<String, bool> get locks => _locks;
  bool get privateZoneLocked => _locks['private_zone_locked'] ?? true;
  bool get aiChallengeLocked => _locks['ai_challenge_locked'] ?? true;
  bool get adventureZoneLocked => _locks['adventure_zone_locked'] ?? true;

  bool _isEnrolled = false;
  bool get isEnrolled => _isEnrolled;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ChallengeProvider() {
    _initLocks();
    checkEnrollment();
  }

  Future<void> checkEnrollment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _isEnrolled = await _service.checkEnrollment(uid);
    } catch (e) {
      _isEnrolled = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initLocks() {
    _service.getLocksStream().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _locks = {
          'private_zone_locked': data['private_zone_locked'] ?? true,
          'ai_challenge_locked': data['ai_challenge_locked'] ?? true,
          'adventure_zone_locked': data['adventure_zone_locked'] ?? true,
        };
        notifyListeners();
      }
    });
  }

  Future<void> ensureLocksInitialized() async {
    await _service.initializeLocks();
  }
}
