import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:kivi_24/screens/recovery_ai/controllers/choose_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/data_back_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/data_front_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_ai_controller.dart';
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

  static String _mapRecoveryOptionToCategory(String? raw) {
    final v = (raw ?? '').toUpperCase().trim();
    if (v == 'HEALTH') return 'Medical';
    if (v == 'MENTAL') return 'Psychological';
    if (v == 'PHYSICAL') return 'Sport';
    return 'Sport';
  }

  static String _safeGetSelectedIssueDescription({
    DataFrontController? front,
    DataBackController? back,
    required int severityFallback,
  }) {
    String? frontIssue;
    String? frontOnset;
    if (front != null) {
      for (final t in front.issueType) {
        if (t.isSelected.value) {
          frontIssue = t.issue.trim();
          break;
        }
      }
      for (final d in front.issueDuration) {
        if (d.isSelected.value) {
          frontOnset = d.title.trim();
          break;
        }
      }
    }

    String? backIssue;
    String? backOnset;
    final backSeverity = back?.severity.value ?? severityFallback;
    if (back != null) {
      for (final t in back.issueType) {
        if (t.isSelected.value) {
          backIssue = t.issue.trim();
          break;
        }
      }
      for (final d in back.issueDuration) {
        if (d.isSelected.value) {
          backOnset = d.title.trim();
          break;
        }
      }
    }

    final issue = backIssue ?? frontIssue ?? 'Not provided';
    final onset = backOnset ?? frontOnset ?? 'Not provided';
    final severity = backSeverity;
    final desc = 'Issue: $issue; Onset: $onset; Severity: $severity/10';
    return desc.length <= 200 ? desc : desc.substring(0, 200);
  }

  /// Collects data from Recovery AI onboarding controllers and sends the profile.
  static Future<Map<String, dynamic>?> sendProfileToAiModel({
    bool includeDailyCheckin = false,
    int dayNumber = 1,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) {
        log('[RecoveryAI] No Firebase ID token; aborting AI call');
        return null;
      }

      log('[RecoveryAI] Firebase token available: YES');

      // Controllers (must already be created in the flow via Get.put).
      final setting = Get.isRegistered<SettingScreenController>()
          ? Get.find<SettingScreenController>()
          : null;
      final health = Get.isRegistered<OnboardingHealthController>()
          ? Get.find<OnboardingHealthController>()
          : null;
      final nutrition = Get.isRegistered<OnboardingNutritionController>()
          ? Get.find<OnboardingNutritionController>()
          : null;
      final activity = Get.isRegistered<OnboardingActivityController>()
          ? Get.find<OnboardingActivityController>()
          : null;
      final goals = Get.isRegistered<RecoveryGoalController>()
          ? Get.find<RecoveryGoalController>()
          : null;
      final today = Get.isRegistered<TodayGoalController>()
          ? Get.find<TodayGoalController>()
          : null;

      final recoveryAi = Get.isRegistered<RecoveryAiController>()
          ? Get.find<RecoveryAiController>()
          : null;
      final choosePlan = Get.isRegistered<ChoosePlanController>()
          ? Get.find<ChoosePlanController>()
          : null;
      final front = Get.isRegistered<DataFrontController>()
          ? Get.find<DataFrontController>()
          : null;
      final back = Get.isRegistered<DataBackController>()
          ? Get.find<DataBackController>()
          : null;

      // Basic info
      final fullName = setting?.nameCtrl.text.trim() ?? '';
      final dobRaw = setting?.dobCtrl.text.trim() ?? ''; // expected YYYY-MM-DD by backend
      final height = double.tryParse(setting?.heightCtrl.text.trim() ?? '') ??
          0.0;
      final weight = double.tryParse(setting?.weightCtrl.text.trim() ?? '') ??
          0.0;
      final gender = (setting?.selectedGender.value ?? '').isEmpty
          ? null
          : setting!.selectedGender.value;

      // Health concerns from onboarding_health
      final healthConcerns = (health?.options ?? [])
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      // Allergies & dietary restrictions from onboarding_nutrition
      final allergies = (nutrition?.allergiesOptions ?? [])
          .where((o) => o.isSelected.value && o.title != 'None')
          .map((o) => o.title)
          .toList();

      final dietaryRestrictions = (nutrition?.dietaryOptions ?? [])
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      // Mobility & activity from onboarding_activity
      final mobilityLevel = activity?.activeLevelOptions
              .firstWhereOrNull((o) => o.isSelected.value)
              ?.title ??
          'Fully Mobile';
      final dailyActivityLevel = activity?.activities
              .firstWhereOrNull((o) => o.isSelected.value)
              ?.title ??
          'Moderate Activity';

      // Primary goal & concerns from recovery_goals
      final primaryGoal = goals?.plansOptions
          .firstWhereOrNull((o) => o.isSelected.value)
          ?.title;

      final concernAreas = (goals?.mainConcernOptions ?? [])
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      // Current pain level from recovery_goals / today_goal
      final currentPainLevel =
          today?.painLevel.value ?? (goals?.currentPainLevel.value ?? 0);

      final selectedCategory = _mapRecoveryOptionToCategory(
        recoveryAi?.selectedRecoveryOption.value,
      );

      final selectedPlanType = choosePlan?.selectedPlanType ?? 'temp';

      final issueSeverityFallback =
          front?.severity.value ?? back?.severity.value ?? 0;
      final userDescription = _safeGetSelectedIssueDescription(
        front: front,
        back: back,
        severityFallback: issueSeverityFallback,
      );

      log('[RecoveryAI] selected_category=$selectedCategory');
      log('[RecoveryAI] plan_type=$selectedPlanType');
      log('[RecoveryAI] user_description=$userDescription');

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
        // Added for Recovery Plan backend:
        'selected_category': selectedCategory,
        'plan_type': selectedPlanType, // "temp" | "permanent"
        'user_description': userDescription, // CURRENT ISSUE text (<=200 chars)
      };

      if (includeDailyCheckin && today != null) {
        log('[RecoveryAI] includeDailyCheckin day_number=$dayNumber');
        log('[RecoveryAI] includeDailyCheckin pain_level=${today.painLevel.value}');
        log('[RecoveryAI] includeDailyCheckin how_feeling=${today.selectedFeeling.value}');
        log('[RecoveryAI] includeDailyCheckin notes=${today.notesCtrl.text.trim()}');
        body.addAll({
          'day_number': dayNumber,
          'pain_level': today.painLevel.value,
          'energy_level': today.energyLevel.value,
          'how_feeling': today.selectedFeeling.value.toLowerCase(),
          'notes': today.notesCtrl.text.trim(),
          'activities_completed': <String>[],
        });
      }

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
      log('[RecoveryAI] AI model response headers: ${resp.headers}');

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        log('[RecoveryAI] Non-2xx response from AI backend; response above is expected to contain validation errors.');
      }

      // Parse JSON response when possible so UI/controller can consume it later.
      try {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // Not JSON or invalid JSON; return null.
      }
    } catch (e, st) {
      log('[RecoveryAI] Failed to send profile to AI model: $e');
      log(st.toString());
    }
    return null;
  }
}

