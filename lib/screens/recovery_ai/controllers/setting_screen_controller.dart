import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kivi_24/api/models/profile_models.dart';

class SettingScreenController extends GetxController {
  final selectedGender = ''.obs;

  // Basic profile fields used for the AI model payload
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController(); // Expected format: YYYY-MM-DD
  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();

  bool _initializedFromProfile = false;

  /// Prefill from existing Profile when available (only once per controller life).
  void maybeInitFromProfile(Profile? profile) {
    if (_initializedFromProfile || profile == null) return;
    _initializedFromProfile = true;

    if (profile.name != null && profile.name!.isNotEmpty) {
      nameCtrl.text = profile.name!;
    }
    if (profile.dateOfBirth != null && profile.dateOfBirth!.isNotEmpty) {
      // Backend already stores YYYY-MM-DD
      dobCtrl.text = profile.dateOfBirth!;
    }
    if (profile.heightCm != null) {
      heightCtrl.text = profile.heightCm!.toStringAsFixed(0);
    }
    if (profile.weightKg != null) {
      weightCtrl.text = profile.weightKg!.toStringAsFixed(0);
    }
    if (profile.gender != null && profile.gender!.isNotEmpty) {
      selectedGender.value = profile.gender!;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    dobCtrl.dispose();
    heightCtrl.dispose();
    weightCtrl.dispose();
    super.onClose();
  }
}


