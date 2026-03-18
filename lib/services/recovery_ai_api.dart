import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:kivi_24/screens/recovery_ai/controllers/setting_screen_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_health_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_nutrition_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_activity_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/today_goal_controller.dart';

/// Service that sends the Recovery AI profile payload to the backend AI model.
class RecoveryAiApi {
  static const String _baseUrl =
      'https://dcfqazp2gr.ap-south-1.awsapprunner.com';

  /// Collects data from Recovery AI onboarding controllers and sends the profile.
  static Future<void> sendProfileToAiModel() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) {
        log('[RecoveryAI] No Firebase ID token; aborting AI call');
        return;
      }

      // Controllers (must already be created in the flow via Get.put).
      final setting = Get.find<SettingScreenController>();
      final health = Get.find<OnboardingHealthController>();
      final nutrition = Get.find<OnboardingNutritionController>();
      final activity = Get.find<OnboardingActivityController>();
      final goals = Get.find<RecoveryGoalController>();
      final today = Get.find<TodayGoalController>();

      // Basic info
      final fullName = setting.nameCtrl.text.trim();
      final dobRaw = setting.dobCtrl.text.trim(); // expected YYYY-MM-DD by backend
      final height =
          double.tryParse(setting.heightCtrl.text.trim()) ?? 0.0;
      final weight =
          double.tryParse(setting.weightCtrl.text.trim()) ?? 0.0;
      final gender = setting.selectedGender.value.isEmpty
          ? null
          : setting.selectedGender.value;

      // Health concerns from onboarding_health
      final healthConcerns = health.options
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      // Allergies & dietary restrictions from onboarding_nutrition
      final allergies = nutrition.allergiesOptions
          .where((o) => o.isSelected.value && o.title != 'None')
          .map((o) => o.title)
          .toList();

      final dietaryRestrictions = nutrition.dietaryOptions
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      // Mobility & activity from onboarding_activity
      final mobilityLevel = activity.activeLevelOptions
              .firstWhereOrNull((o) => o.isSelected.value)
              ?.title ??
          'Fully Mobile';
      final dailyActivityLevel = activity.activities
              .firstWhereOrNull((o) => o.isSelected.value)
              ?.title ??
          'Moderate Activity';

      // Primary goal & concerns from recovery_goals
      final primaryGoal = goals.plansOptions
          .firstWhereOrNull((o) => o.isSelected.value)
          ?.title;

      final concernAreas = goals.mainConcernOptions
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      // Current pain level from recovery_goals / today_goal
      final currentPainLevel =
          today.painLevel.value != 0 ? today.painLevel.value : goals.currentPainLevel.value;

      final body = <String, dynamic>{
        'full_name': fullName,
        'date_of_birth': dobRaw,
        'height_cm': height,
        'weight_kg': weight,
        'gender': gender,
        'health_concerns': healthConcerns,
        'medications': null,
        'allergies': allergies,
        'dietary_restrictions': dietaryRestrictions,
        'mobility_level': mobilityLevel,
        'daily_activity_level': dailyActivityLevel,
        'physical_limitations': <String>[],
        'primary_goal': primaryGoal,
        'current_pain_level': currentPainLevel,
        'concern_areas': concernAreas,
      };

      log('[RecoveryAI] Sending profile payload: $body');

      final resp = await http.post(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(body),
      );

      log('[RecoveryAI] AI model response code: ${resp.statusCode}');
      log('[RecoveryAI] AI model response body: ${resp.body}');
    } catch (e, st) {
      log('[RecoveryAI] Failed to send profile to AI model: $e');
      log(st.toString());
    }
  }
}

