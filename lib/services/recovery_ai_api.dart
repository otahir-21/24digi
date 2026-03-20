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
import 'package:kivi_24/screens/recovery_ai/controllers/calibrating_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_health_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_nutrition_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_activity_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/today_goal_controller.dart';

/// Service that sends the Recovery AI profile payload to the backend AI model.
class RecoveryAiApi {
  static const String _baseUrl =
      'https://dcfqazp2gr.ap-south-1.awsapprunner.com';

  static String? _mapGenderToEnum(String? raw) {
    final v = (raw ?? '').trim().toLowerCase();
    if (v.isEmpty) return null;
    if (v == 'male') return 'Male';
    if (v == 'female') return 'Female';
    return 'Other';
  }

  static String? _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map<String, dynamic>) {
            return first['msg']?.toString() ?? first['type']?.toString();
          }
        }
      }
    } catch (_) {
      // ignore parse errors
    }
    return null;
  }

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
      final calibrating = Get.isRegistered<CalibratingController>()
          ? Get.find<CalibratingController>()
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
      final dobRaw = setting?.dobCtrl.text.trim() ?? '';
      final dobNormalized = (() {
        // Backend prompt expects: YYYY-MM-DD
        // Your UI may save DD/MM/YYYY depending on input/formatting.
        final v = dobRaw;
        final m = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$').firstMatch(v);
        if (m == null) return v;
        final dd = m.group(1);
        final mm = m.group(2);
        final yyyy = m.group(3);
        if (dd == null || mm == null || yyyy == null) return v;
        return '$yyyy-$mm-$dd';
      })();
      final height = double.tryParse(setting?.heightCtrl.text.trim() ?? '') ??
          0.0;
      final weight = double.tryParse(setting?.weightCtrl.text.trim() ?? '') ??
          0.0;
      final gender = _mapGenderToEnum(setting?.selectedGender.value);

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

      // Mobility & activity from Calibrating (preferred) / onboarding_activity (fallback)
      String mobilityLevel = 'Fully Mobile';
      if (calibrating != null) {
        final selectedMobility = calibrating.mobilityOptions
            .firstWhereOrNull((o) => o.isSelected.value)
            ?.title;
        // Align with your onboarding JSON examples.
        mobilityLevel = (selectedMobility == 'Fully Active')
            ? 'Fully Mobile'
            : (selectedMobility ?? mobilityLevel);
      } else if (activity != null) {
        mobilityLevel = activity!.activeLevelOptions
                .firstWhereOrNull((o) => o.isSelected.value)
                ?.title ??
            mobilityLevel;
      }

      String dailyActivityLevel = 'Moderate Activity';
      if (calibrating != null) {
        final selectedDaily = calibrating.dailyActivityOptions
            .firstWhereOrNull((o) => o.isSelected.value)
            ?.title;

        // Align with backend examples: Sedentary/Light Activity/Moderate Activity/Active
        dailyActivityLevel = switch (selectedDaily) {
          'Mostly Active' => 'Sedentary',
          'Lightly Active' => 'Light Activity',
          'Moderately Active' => 'Moderate Activity',
          'Very Active' => 'Active',
          _ => dailyActivityLevel,
        };
      } else if (activity != null) {
        dailyActivityLevel = activity!.activities
                .firstWhereOrNull((o) => o.isSelected.value)
                ?.title ??
            dailyActivityLevel;
      }

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
        'date_of_birth': dobNormalized,
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
        // Important: don't feed error JSON into the UI as if it was a plan.
        return null;
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

  /// Create an issue selection and then create a recovery plan for it.
  ///
  /// Backend endpoints (from your Postman collection):
  /// - `POST /issues`  -> returns `selection_id`
  /// - `POST /plans`   -> returns plan details (including daily plan)
  static Future<Map<String, dynamic>?> createPlanFromUserFlow({
    required String planType, // "temporary" | "permanent"
    int planDurationDays = 5,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) return null;

      final recoveryAi = Get.isRegistered<RecoveryAiController>()
          ? Get.find<RecoveryAiController>()
          : null;
      final goals = Get.isRegistered<RecoveryGoalController>()
          ? Get.find<RecoveryGoalController>()
          : null;
      final front = Get.isRegistered<DataFrontController>()
          ? Get.find<DataFrontController>()
          : null;
      final back = Get.isRegistered<DataBackController>()
          ? Get.find<DataBackController>()
          : null;

      if (recoveryAi == null || front == null || back == null) {
        return null;
      }

      final category = _mapRecoveryOptionToCategory(
        recoveryAi.selectedRecoveryOption.value,
      ).toLowerCase();

      // Extract chosen issue + onset + severity from DataFront/DataBack.
      String? frontIssue;
      String? frontOnset;
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

      String? backIssue;
      String? backOnset;
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

      final issueType = (backIssue ?? frontIssue ?? 'Pain').trim();
      final onsetTime = (backOnset ?? frontOnset ?? 'Unknown').trim();

      final severityVal = back.severity.value;
      final severityInt =
          (severityVal is num ? severityVal.toInt() : int.tryParse(severityVal.toString()) ?? 0);

      final concernAreas = (goals?.mainConcernOptions ?? [])
          .where((o) => o.isSelected.value)
          .map((o) => o.title)
          .toList();

      final primaryGoal = goals?.plansOptions
          .firstWhereOrNull((o) => o.isSelected.value)
          ?.title;

      final issueBody = <String, dynamic>{
        'category': category,
        'issue_type': issueType,
        'affected_areas': [issueType],
        'onset_time': onsetTime,
        'severity_level': severityInt,
        'additional_answers': {
          'pain_level': goals?.currentPainLevel.value ?? 0,
          'primary_goal': primaryGoal,
          'concern_areas': concernAreas,
        },
      };

      final issueResp = await http.post(
        Uri.parse('$_baseUrl/issues'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(issueBody),
      );

      if (issueResp.statusCode < 200 || issueResp.statusCode >= 300) {
        log('[RecoveryAI] /issues failed: ${issueResp.statusCode} ${issueResp.body}');
        throw Exception(
          _extractErrorMessage(issueResp.body) ??
              'Failed to create issue (status ${issueResp.statusCode}).',
        );
      }

      log(
        '[RecoveryAI] /issues response code=${issueResp.statusCode} body=${issueResp.body}',
      );

      final issueDecoded = jsonDecode(issueResp.body);
      if (issueDecoded is! Map<String, dynamic>) return null;

      final selectionIdRaw = issueDecoded['selection_id'];
      final selectionId = selectionIdRaw is int
          ? selectionIdRaw
          : int.tryParse(selectionIdRaw?.toString() ?? '');
      if (selectionId == null) return null;

      // Backend requires an active subscription before plan generation.
      // Your Postman flow uses:
      // POST /subscriptions
      // { "plan_type": "<temporary|permanent>", "payment_method_id": "pm_test" }
      final subscriptionResp = await http.post(
        Uri.parse('$_baseUrl/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'plan_type': planType,
          'payment_method_id': 'pm_test',
        }),
      );

      if (subscriptionResp.statusCode < 200 ||
          subscriptionResp.statusCode >= 300) {
        final msg = _extractErrorMessage(subscriptionResp.body) ??
            'Subscription failed with status ${subscriptionResp.statusCode}';

        // If user already has an active subscription, we can still create a plan.
        if (subscriptionResp.statusCode == 400 &&
            msg.toLowerCase().contains('already have an active subscription')) {
          log(
            '[RecoveryAI] /subscriptions skipped (already active): ${subscriptionResp.statusCode} $msg',
          );
        } else {
          log(
            '[RecoveryAI] /subscriptions failed: ${subscriptionResp.statusCode} ${subscriptionResp.body}',
          );
          throw Exception(msg);
        }
      }

      log(
        '[RecoveryAI] /subscriptions response code=${subscriptionResp.statusCode} body=${subscriptionResp.body}',
      );

      final planBody = <String, dynamic>{
        'issue_selection_id': selectionId,
        'plan_type': planType,
        'plan_duration_days': planDurationDays,
      };

      final planResp = await http.post(
        Uri.parse('$_baseUrl/plans'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(planBody),
      );

      if (planResp.statusCode < 200 || planResp.statusCode >= 300) {
        log('[RecoveryAI] /plans failed: ${planResp.statusCode} ${planResp.body}');
        throw Exception(
          _extractErrorMessage(planResp.body) ??
              'Failed to generate plan (status ${planResp.statusCode}).',
        );
      }

      log(
        '[RecoveryAI] /plans response code=${planResp.statusCode} body=${planResp.body}',
      );

      final planDecoded = jsonDecode(planResp.body);
      if (planDecoded is Map<String, dynamic>) return planDecoded;
    } catch (e, st) {
      log('[RecoveryAI] Failed to create plan: $e');
      log(st.toString());
    }

    return null;
  }
}

