import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/api_config.dart';
import '../c_by_ai_pdf_service.dart';
import '../models/c_by_ai_models.dart';

double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

/// The meal API derives body fat with formulas that use log10 of circumference
/// differences (US Navy–style). Non-positive differences yield -infinity and
/// break MySQL decimal columns.
String? validateBodyFatCircumferences({
  required String gender,
  required double neckCm,
  required double waistCm,
  required double hipCm,
}) {
  final g = gender.toLowerCase().trim();
  const eps = 1e-6;
  if (g == 'female' || g == 'f') {
    if (waistCm + hipCm - neckCm <= eps) {
      return 'Waist plus hip must be greater than neck (these values are used for body fat %).';
    }
  } else {
    if (waistCm - neckCm <= eps) {
      return 'Waist must be greater than neck (these values are used for body fat %).';
    }
  }
  return null;
}

/// Local-date Monday `YYYY-MM-DD` (device timezone) for weekly meal-generation quota.
String cByAiCurrentWeekMondayId() {
  final n = DateTime.now();
  final day = DateTime(n.year, n.month, n.day);
  final monday = day.subtract(Duration(days: day.weekday - DateTime.monday));
  return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
}

class CByAiProvider extends ChangeNotifier {
  final _baseUrl = 'http://16.170.207.64/api/v1/mobile';

  /// Max successful `generate-meals/start` calls per user per week (Mon–Sun, local).
  static const int maxWeeklyMealGenerations = 2;

  /// Cached count for signed-in user this week; refresh with [loadWeeklyMealGenerationQuota].
  int weeklyMealGenerationsUsed = 0;

  bool isLoadingUserData = false;
  bool isGenerating = false;
  double generationProgress = 0.0;
  String progressMessage = '';
  int currentGeneratingDay = 0;

  Map<int, List<MealModel>> mealData = {};
  Map<int, DailyTotalModel> dailyTotals = {};
  MealSummaryModel? summary;
  int selectedDay = 1;
  FitnessMetricsModel? fitnessMetrics;
  String? deliveryBuilding;
  String? deliveryAddress;
  String? deliveryFloor;
  String? deliveryLandmark;
  String? deliveryFullName;
  String? deliveryAddressTitle;
  String? deliveryCity;
  double? deliveryLatitude;
  double? deliveryLongitude;
  int deliveryFrequency = 3;
  bool isNotifying = false;

  /// Last PDF uploaded for CRM (Storage download URL).
  String? lastMealPlanPdfUrl;
  String? error;

  String? _sessionId;
  Timer? _pollingTimer;
  http.Client? _httpClient;
  bool _isCuratedMode = false;

  bool get isCuratedMode => _isCuratedMode;

  void toggleMealMode(bool isCurated) {
    _isCuratedMode = isCurated;
    notifyListeners();
  }

  void setSelectedDay(int day) {
    selectedDay = day;
    notifyListeners();
  }

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      // Per-user key — prevents User A's device_id bleeding into User B's session
      final userKey = 'c_by_ai_device_id_$uid';
      String? deviceId = prefs.getString(userKey);
      if (deviceId == null) {
        // One-time migration: if an old shared device_id exists and no other user has
        // claimed it yet, let the first logged-in user inherit it so they keep their plan.
        final legacy = prefs.getString('c_by_ai_device_id');
        if (legacy != null) {
          deviceId = legacy;
          await prefs.setString(userKey, deviceId);
          await prefs.remove('c_by_ai_device_id'); // prevent next user from claiming it
        } else {
          deviceId = const Uuid().v4();
          await prefs.setString(userKey, deviceId);
        }
      }
      return deviceId;
    }

    // No signed-in user (edge case): fall back to shared key
    String? deviceId = prefs.getString('c_by_ai_device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('c_by_ai_device_id', deviceId);
    }
    return deviceId;
  }

  /// Returns the SharedPreferences key for the session_id scoped to the
  /// current Firebase user. Prevents session bleed between accounts.
  String get _sessionIdKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null ? 'c_by_ai_session_id_$uid' : 'c_by_ai_session_id';
  }

  Future<void> loadWeeklyMealGenerationQuota() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      weeklyMealGenerationsUsed = 0;
      notifyListeners();
      return;
    }
    weeklyMealGenerationsUsed = await _readWeeklyGenerationCount(uid);
    notifyListeners();
  }

  bool get canGenerateMealsThisWeek =>
      weeklyMealGenerationsUsed < maxWeeklyMealGenerations;

  Future<int> _readWeeklyGenerationCount(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('c_by_ai_wk_gen_$uid');
    final wk = cByAiCurrentWeekMondayId();
    if (raw == null) return 0;
    final parts = raw.split('|');
    if (parts.length != 2 || parts[0] != wk) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  Future<void> _incrementWeeklyGenerationCount(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'c_by_ai_wk_gen_$uid';
    final wk = cByAiCurrentWeekMondayId();
    final raw = prefs.getString(key);
    var c = 0;
    if (raw != null) {
      final p = raw.split('|');
      if (p.length == 2 && p[0] == wk) {
        c = int.tryParse(p[1]) ?? 0;
      }
    }
    c++;
    await prefs.setString(key, '$wk|$c');
    weeklyMealGenerationsUsed = c;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    isLoadingUserData = true;
    error = null;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      Map<String, dynamic> data = {};
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('profile')
            .doc(uid)
            .get();
        if (doc.exists) {
          data = doc.data() ?? {};
        }
      }

      isLoadingUserData = false;
      notifyListeners();

      return {
        'age': data['age'] ?? 25,
        'height': data['height_cm'] ?? data['height'] ?? 175,
        'weight': data['weight_kg'] ?? data['weight'] ?? 70,
        'gender': data['gender'] ?? 'male',
        'activity_level':
            data['activity_level'] ?? 'Moderately active (3–5 days/week)',
        'neck_circumference': data['neck_circumference'] ?? 38,
        'waist_circumference': data['waist_circumference'] ?? 80,
        'hip_circumference': data['hip_circumference'] ?? 95,
      };
    } catch (e) {
      isLoadingUserData = false;
      error = e.toString();
      notifyListeners();
      return {
        'age': 25,
        'height': 175,
        'weight': 70,
        'gender': 'male',
        'activity_level': 'Moderately active (3–5 days/week)',
        'neck_circumference': 38,
        'waist_circumference': 80,
        'hip_circumference': 95,
      };
    }
  }

  Future<bool> generateMeals(Map<String, dynamic> userInfo) async {
    isGenerating = true;
    error = null;
    notifyListeners();

    try {
      final neck = _toDouble(userInfo['neck_circumference']);
      final waist = _toDouble(userInfo['waist_circumference']);
      final hip = _toDouble(userInfo['hip_circumference']);
      final gender = userInfo['gender']?.toString() ?? 'male';
      final measurementError = validateBodyFatCircumferences(
        gender: gender,
        neckCm: neck,
        waistCm: waist,
        hipCm: hip,
      );
      if (measurementError != null) {
        error = measurementError;
        isGenerating = false;
        notifyListeners();
        return false;
      }

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final used = await _readWeeklyGenerationCount(uid);
        weeklyMealGenerationsUsed = used;
        if (used >= maxWeeklyMealGenerations) {
          error =
              'You can generate meals at most $maxWeeklyMealGenerations times per week. '
              'Your limit resets next Monday (local time).';
          isGenerating = false;
          notifyListeners();
          return false;
        }
      }

      final deviceId = await _getDeviceId();
      final int planPeriod = (userInfo['plan_period'] as int?) ?? 7;
      final body = <String, dynamic>{
        "device_id": deviceId,
        "age": userInfo['age'],
        "height": userInfo['height'],
        "weight": userInfo['weight'],
        "gender": userInfo['gender'],
        "activity_level": userInfo['activity_level'],
        "neck_circumference": userInfo['neck_circumference'],
        "waist_circumference": userInfo['waist_circumference'],
        "hip_circumference": userInfo['hip_circumference'],
        "plan_period": planPeriod,
        // Backend: use your standard/rules-based pipeline (not LLM) unless overridden.
        "plan_generator": ApiConfig.cByAiPlanGenerator,
      };
      // Add optional target/goal fields when present
      if (userInfo['goal'] != null) body['goal'] = userInfo['goal'];
      if (userInfo['dietary_preference'] != null) body['dietary_preference'] = userInfo['dietary_preference'];
      if ((userInfo['target_weight'] as double?) != null && (userInfo['target_weight'] as double) > 0) body['target_weight'] = userInfo['target_weight'];
      if ((userInfo['target_waist_circumference'] as double?) != null && (userInfo['target_waist_circumference'] as double) > 0) body['target_waist_circumference'] = userInfo['target_waist_circumference'];
      if ((userInfo['target_hip_circumference'] as double?) != null && (userInfo['target_hip_circumference'] as double) > 0) body['target_hip_circumference'] = userInfo['target_hip_circumference'];
      if ((userInfo['target_neck_circumference'] as double?) != null && (userInfo['target_neck_circumference'] as double) > 0) body['target_neck_circumference'] = userInfo['target_neck_circumference'];

      log("body: $body");
      final response = await http
          .post(
            Uri.parse('$_baseUrl/generate-meals/start'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      log("response:: code: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Fix: check root or nested 'data' key
          _sessionId =
              data['session_id']?.toString() ??
              data['data']?['session_id']?.toString();

          // Initialize summary with plan period to avoid UI defaults
          summary = MealSummaryModel(
            totalDays: planPeriod,
            totalMeals: 0,
            totalCalories: 0,
            totalProtein: 0,
            totalCarbs: 0,
            totalFat: 0,
            totalPrice: 0,
          );

          if (_sessionId == null) {
            error = "Server did not return a session_id";
            isGenerating = false;
            notifyListeners();
            return false;
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_sessionIdKey, _sessionId!);

          if (uid != null) {
            await _incrementWeeklyGenerationCount(uid);
          }

          // Fitness metrics are populated later by _fetchMealPlan (GET /meal-plan)
          // which returns user_info: { bmi, bmi_overview, bmr, tdee, body_fat }
          isGenerating = true;
          notifyListeners();
          return true;
        } else {
          error = data['message'] ?? 'Failed to start generation';
          isGenerating = false;
          notifyListeners();
          return false;
        }
      } else {
        final data = jsonDecode(response.body);
        error = data['message'] ?? "Server error ${response.statusCode}";
        isGenerating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      log("error: $e");
      error = e.toString();
      isGenerating = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> connectToStream({int retries = 3}) async {
    if (_sessionId == null) return;

    isGenerating = true;
    error = null;
    notifyListeners();

    _pollingTimer?.cancel();
    int errorCount = 0;
    final DateTime startTime = DateTime.now();
    const Duration maxWait = Duration(minutes: 20);
    final completer = Completer<void>();

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/generate-meals/status'),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({"session_id": _sessionId}),
        );

        // Debug: log raw status response so we can see why it's stuck.
        log('C_BY_AI_STATUS response: ${response.statusCode} ${response.body}');

        if (DateTime.now().difference(startTime) > maxWait) {
          timer.cancel();
          error =
              "Generating your meal plan is taking longer than expected. Please try again in a few minutes.";
          isGenerating = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete();
          return;
        }

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Handle root level or nested 'data'
          final resData = data['data'] ?? data;

          // Debug: show parsed status payload.
          log('C_BY_AI_STATUS parsed: $resData');

          // Normalize completion & progress fields from backend
          final String status = resData['status']?.toString() ?? 'processing';
          final bool completedFlag =
              resData['completed'] == true ||
              status == 'completed' ||
              status == 'partially_completed';

          generationProgress = _toDouble(resData['progress']);
          currentGeneratingDay = resData['day_completed'] ?? 0;
          int totalDays = resData['total_days'] ?? 7;
          if (totalDays < 1) totalDays = 7; // ensure valid

          int currentDay = resData['current_day'] ?? (currentGeneratingDay + 1);
          if (currentDay > totalDays) {
            currentDay = totalDays; // Fix "Generating day 8 of 7"
          }

          // If backend doesn't send explicit progress, approximate it from day/totalDays.
          if (generationProgress <= 0 && totalDays > 0) {
            generationProgress =
                (currentDay.clamp(0, totalDays) / totalDays) * 100.0;
          }

          // Force update summary totalDays to keep UI in sync
          if (summary == null || summary!.totalDays != totalDays) {
            summary = MealSummaryModel(
              totalDays: totalDays,
              totalMeals: summary?.totalMeals ?? 0,
              totalCalories: summary?.totalCalories ?? 0,
              totalProtein: summary?.totalProtein ?? 0,
              totalCarbs: summary?.totalCarbs ?? 0,
              totalFat: summary?.totalFat ?? 0,
              totalPrice: summary?.totalPrice ?? 0,
            );
          }

          progressMessage =
              resData['message'] ??
              "Generating day $currentDay of $totalDays (${generationProgress.toStringAsFixed(1)}%)";

          // Parse incremental meal data if present
          if (resData['meal_data'] != null && resData['meal_data'] is Map) {
            _parseDayMap(resData['meal_data'] as Map);
          }

          // How many full days of data have we actually received?
          int generatedDays = currentGeneratingDay;
          if (resData['meal_data'] is Map) {
            generatedDays = (resData['meal_data'] as Map).length;
          }

          final bool shouldFinish =
              completedFlag ||
              status == 'completed' ||
              (generatedDays >= totalDays && totalDays > 0) ||
              generationProgress >= 99.5;

          if (shouldFinish) {
            timer.cancel();
            generationProgress = 100.0;
            progressMessage = "Meal plan completed!";
            isGenerating = false;
            notifyListeners(); // Notify immediately so UI shows completed

            // Fetch final plan but don't let it hang the completion logic
            try {
              await _fetchMealPlan().timeout(const Duration(seconds: 5));
            } catch (e) {
              log("Fetch meal plan finalization error: $e");
            }

            notifyListeners();
            if (!completer.isCompleted) completer.complete();
          } else if (status == 'failed') {
            timer.cancel();
            error = resData['message'] ?? "Generation failed";
            isGenerating = false;
            notifyListeners();
            if (!completer.isCompleted) completer.complete();
          } else {
            notifyListeners();
          }
        } else {
          errorCount++;
          if (errorCount > retries) {
            timer.cancel();
            error = "Failed to get status after several retries";
            isGenerating = false;
            notifyListeners();
            if (!completer.isCompleted) completer.complete();
          }
        }
      } catch (e) {
        log("Polling error: $e");
        errorCount++;
        if (errorCount > retries) {
          timer.cancel();
          error = "Connection lost: ${e.toString()}";
          isGenerating = false;
          notifyListeners();
          if (!completer.isCompleted) completer.complete();
        }
      }
    });

    return completer.future;
  }

  /// Parses a `{ "1": { daily_total_cal, daily_total_cost, meals: [...] } }` Map
  /// into [mealData] and [dailyTotals]. Used by both _fetchMealPlan and the
  /// polling handler so the logic lives in one place.
  void _parseDayMap(Map<dynamic, dynamic> rawMap) {
    final keys = rawMap.keys.map((k) => int.tryParse(k.toString())).whereType<int>().toList();
    // Remap 0-indexed keys (0..6) → 1-indexed (1..7)
    final offset = (keys.isNotEmpty && keys.every((k) => k < keys.length)) ? 1 : 0;

    rawMap.forEach((dayStr, dayContent) {
      final rawDay = int.tryParse(dayStr.toString());
      if (rawDay == null || dayContent is! Map) return;
      final dayNum = rawDay + offset;

      final mealsList = (dayContent['meals'] as List<dynamic>? ?? []);
      final meals = mealsList
          .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
          .toList();
      // Don't overwrite an existing populated day with empty data from the server
      if (meals.isEmpty) return;
      mealData[dayNum] = meals;

      double dCal = 0, dPro = 0, dCar = 0, dFat = 0, dPrice = 0;
      for (final m in meals) {
        dCal += m.totalCal;
        dPro += m.totalProtein;
        dCar += m.totalCarbs;
        dFat += m.totalFat;
        dPrice += m.totalPrice;
      }
      final serverDayCal = _toDouble(dayContent['daily_total_cal']);
      final serverDayPrice = _toDouble(dayContent['daily_total_cost']);
      dailyTotals[dayNum] = DailyTotalModel(
        calories: dCal > 0 ? dCal : serverDayCal,
        protein: dPro,
        carbs: dCar,
        fat: dFat,
        price: dPrice > 0 ? dPrice : serverDayPrice,
      );
    });
  }

  /// `GET /meal-plan/{device_id}`
  /// Loads the complete plan, fitness metrics, and session_id into the provider.
  Future<void> _fetchMealPlan() async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.get(
        Uri.parse('$_baseUrl/meal-plan/$deviceId'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body);
      if (data['success'] != true) return;

      final resData = (data['data'] is Map) ? data['data'] as Map<String, dynamic> : data as Map<String, dynamic>;

      // Save session_id from plan response so approve/delivery calls work after cold restart
      final planSessionId = resData['session_id']?.toString();
      if (planSessionId != null && planSessionId.isNotEmpty) {
        _sessionId = planSessionId;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_sessionIdKey, planSessionId);
      }

      // Snapshot incremental data built by polling so we never regress day count
      final mealDataBackup = <int, List<MealModel>>{
        for (final e in mealData.entries) e.key: List<MealModel>.from(e.value),
      };

      // meal_plan is a Map { "1": {...}, "2": {...} } per the API spec
      final mealPlanRaw = resData['meal_plan'];
      final hasNewPlan = mealPlanRaw is Map && mealPlanRaw.isNotEmpty;

      if (hasNewPlan) {
        mealData.clear();
        dailyTotals.clear();
        _parseDayMap(mealPlanRaw);
      }

      // Restore any days that polling had but the plan endpoint omitted
      int apiTotalDays = (resData['total_days'] as num?)?.toInt() ??
          int.tryParse(resData['total_days']?.toString() ?? '') ?? 0;

      // Always restore backup for any day that is missing or came back empty from the server.
      // putIfAbsent alone is insufficient — it won't override an existing empty list.
      for (final e in mealDataBackup.entries) {
        if (e.value.isEmpty) continue; // backup itself has no useful data
        final current = mealData[e.key];
        if (current == null || current.isEmpty) {
          mealData[e.key] = e.value;
        }
      }

      // Recompute summary from actual meal data
      final summaryData = (resData['summary'] is Map)
          ? resData['summary'] as Map<String, dynamic>
          : <String, dynamic>{};

      int sTotalDays = apiTotalDays > 0 ? apiTotalDays : 7;
      if (mealData.keys.isNotEmpty) {
        final maxKey = mealData.keys.reduce((a, b) => a > b ? a : b);
        if (maxKey > sTotalDays) sTotalDays = maxKey;
      }
      if (sTotalDays < 1) sTotalDays = 7;

      double sTotalCal = 0, sTotalPro = 0, sTotalCar = 0, sTotalFat = 0, sTotalPrice = 0;
      int sTotalMeals = 0;
      mealData.forEach((day, meals) {
        sTotalMeals += meals.length;
        for (final m in meals) {
          sTotalCal += m.totalCal;
          sTotalPro += m.totalProtein;
          sTotalCar += m.totalCarbs;
          sTotalFat += m.totalFat;
          sTotalPrice += m.totalPrice;
        }
      });
      // Fallback to server summary when meal macros are missing
      if (sTotalCal == 0) {
        sTotalCal = _toDouble(summaryData['total_calories']);
        sTotalPro = _toDouble(summaryData['total_protein']);
        sTotalCar = _toDouble(summaryData['total_carbs']);
        sTotalFat = _toDouble(summaryData['total_fat']);
        sTotalPrice = _toDouble(summaryData['total_price']);
        if (sTotalMeals == 0) {
          sTotalMeals = (summaryData['total_meals'] as num?)?.toInt() ?? 0;
        }
      }

      // Rebuild dailyTotals from final mealData for consistency
      dailyTotals.clear();
      mealData.forEach((day, meals) {
        double dCal = 0, dPro = 0, dCar = 0, dFat = 0, dPrice = 0;
        for (final m in meals) {
          dCal += m.totalCal;
          dPro += m.totalProtein;
          dCar += m.totalCarbs;
          dFat += m.totalFat;
          dPrice += m.totalPrice;
        }
        dailyTotals[day] = DailyTotalModel(
          calories: dCal,
          protein: dPro,
          carbs: dCar,
          fat: dFat,
          price: dPrice,
        );
      });

      summary = MealSummaryModel(
        totalDays: sTotalDays,
        totalMeals: sTotalMeals,
        totalCalories: sTotalCal,
        totalProtein: sTotalPro,
        totalCarbs: sTotalCar,
        totalFat: sTotalFat,
        totalPrice: sTotalPrice,
      );

      // Always set fitnessMetrics from user_info (present after cold restart too)
      final userInfo = resData['user_info'];
      if (userInfo is Map) {
        String goalStr = resData['goal']?.toString() ?? 'maintain';
        String goalDisplay = goalStr == 'lose'
            ? 'Lose Weight'
            : goalStr == 'gain'
                ? 'Gain Muscle'
                : 'Maintain Weight';
        fitnessMetrics = FitnessMetricsModel(
          bmi: _toDouble(userInfo['bmi'], 22.0),
          bodyFat: _toDouble(userInfo['body_fat'], 18.5),
          bmr: _toDouble(userInfo['bmr'], 1800.0),
          tdee: _toDouble(userInfo['tdee'], 2400.0),
          bmiOverview: userInfo['bmi_overview']?.toString() ?? 'Normal',
          goal: goalDisplay,
          goalExplanation: resData['goal_explanation']?.toString() ?? '',
        );
      } else if (resData['goal'] != null && fitnessMetrics != null) {
        // Partial update: goal/explanation only (polling path where user_info absent)
        String goalStr = resData['goal'].toString();
        String goalDisplay = goalStr == 'lose'
            ? 'Lose Weight'
            : goalStr == 'gain'
                ? 'Gain Muscle'
                : 'Maintain Weight';
        fitnessMetrics = FitnessMetricsModel(
          bmi: fitnessMetrics!.bmi,
          bodyFat: fitnessMetrics!.bodyFat,
          bmr: fitnessMetrics!.bmr,
          tdee: fitnessMetrics!.tdee,
          bmiOverview: fitnessMetrics!.bmiOverview,
          goal: goalDisplay,
          goalExplanation: resData['goal_explanation']?.toString() ?? '',
        );
      }

      selectedDay = 1;
      notifyListeners();
    } catch (e) {
      log('Fetch meal plan error: $e');
      summary ??= MealSummaryModel(
        totalDays: 7,
        totalMeals: 0,
        totalCalories: 0,
        totalProtein: 0,
        totalCarbs: 0,
        totalFat: 0,
        totalPrice: 0,
      );
      notifyListeners();
    }
  }

  Future<void> _fetchDeliveryAddress() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('c_by_ai_delivery')
          .doc(uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        deliveryBuilding = data['building']?.toString();
        deliveryAddress = data['address']?.toString();
        deliveryFloor = data['floor']?.toString();
        deliveryLandmark = data['landmark']?.toString();
        deliveryFullName = data['fullName']?.toString();
        deliveryAddressTitle = data['addressTitle']?.toString();
        deliveryCity = data['city']?.toString();
        if (data['latitude'] != null) {
          deliveryLatitude = _toDouble(data['latitude']);
        }
        if (data['longitude'] != null) {
          deliveryLongitude = _toDouble(data['longitude']);
        }
        deliveryFrequency = data['frequency'] ?? 3;
        isNotifying = data['isNotifying'] ?? false;
        lastMealPlanPdfUrl = data['mealPlanPdfUrl']?.toString() ??
            data['lastMealPlanPdfUrl']?.toString();
        notifyListeners();
      }
    } catch (e) {
      log("Error fetching delivery address: $e");
    }
  }

  /// Returns `true` when the server already has a **completed** meal plan for
  /// this device. When `true` the plan data is loaded and the provider is
  /// ready for the tracker UI (no generation needed).
  Future<bool> checkForExistingPlan() async {
    try {
      final deviceId = await _getDeviceId();
      final res = await http
          .get(
            Uri.parse('$_baseUrl/check-meals/$deviceId'),
            headers: {"Accept": "application/json"},
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return false;
      final body = jsonDecode(res.body);
      final resData = body['data'] ?? body;
      if (body['success'] == true && resData['has_meals'] == true) {
        await _fetchMealPlan();
        isGenerating = false;
        generationProgress = 100.0;
        notifyListeners();
        return true;
      }
    } catch (e) {
      log('checkForExistingPlan: $e');
    }
    return false;
  }

  Future<bool> recoverSession() async {
    // Clear all in-memory state first — prevents a previous user's data from
    // being shown to a new user on the same device before the server check completes.
    mealData.clear();
    dailyTotals.clear();
    summary = null;
    fitnessMetrics = null;
    isGenerating = false;
    generationProgress = 0.0;
    progressMessage = '';
    currentGeneratingDay = 0;
    error = null;

    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionIdKey);
    final deviceId = await _getDeviceId();

    isLoadingUserData = true;
    notifyListeners();

    _fetchDeliveryAddress();

    try {
      // 1. Check existing meals
      final checkRes = await http.get(
        Uri.parse('$_baseUrl/check-meals/$deviceId'),
        headers: {"Accept": "application/json"},
      );

      if (checkRes.statusCode == 200) {
        final checkData = jsonDecode(checkRes.body);
        final resData = checkData['data'] ?? checkData;

        if (checkData['success'] == true) {
          // New structure: resData contains 'has_meals' and 'is_generating'
          if (resData['has_meals'] == true) {
            await _fetchMealPlan();
            isGenerating = false;
            generationProgress = 100.0;
            isLoadingUserData = false;
            notifyListeners();
            return true;
          } else if (resData['is_generating'] == true &&
              resData['session'] != null) {
            _sessionId = resData['session']['id']?.toString();
            if (_sessionId != null) {
              await prefs.setString(_sessionIdKey, _sessionId!);
              isLoadingUserData = false;
              connectToStream();
              return true;
            }
          }
        }
      }

      // 2. Fallback: resume in-progress session via GET /session/{id}/status
      if (_sessionId != null) {
        final statusRes = await http.get(
          Uri.parse('$_baseUrl/session/$_sessionId/status'),
          headers: {"Accept": "application/json"},
        );

        if (statusRes.statusCode == 200) {
          final statusData = jsonDecode(statusRes.body);
          // Response: { success, session_id, status, current_day, total_days, progress_percentage }
          final resData = statusData['data'] ?? statusData;
          final String status = resData['status']?.toString() ?? 'failed';

          if (status == 'processing' || status == 'pending') {
            isLoadingUserData = false;
            connectToStream();
            return true;
          } else if (status == 'completed' || status == 'partially_completed') {
            await _fetchMealPlan();
            isGenerating = false;
            generationProgress = 100.0;
            isLoadingUserData = false;
            notifyListeners();
            return true;
          } else {
            await prefs.remove(_sessionIdKey);
          }
        } else {
          await prefs.remove(_sessionIdKey);
        }
      }
    } catch (e) {
      log("Recovery error: $e");
    }

    isLoadingUserData = false;
    notifyListeners();
    return false;
  }

  Future<bool> approveMealPlan() async {
    if (_sessionId == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/meals/$_sessionId/approve'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({}),
      );
      return response.statusCode == 200;
    } catch (e) {
      log("Approve error: $e");
      return false;
    }
  }

  /// Clear current meal plan/session so user can regenerate from scratch.
  Future<void> resetPlan() async {
    _pollingTimer?.cancel();
    isGenerating = false;
    generationProgress = 0.0;
    progressMessage = '';
    currentGeneratingDay = 0;
    mealData.clear();
    dailyTotals.clear();
    summary = null;
    error = null;
    _sessionId = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);

    notifyListeners();
  }

  bool get hasCompleteDeliveryAddress {
    final b = deliveryBuilding?.trim() ?? '';
    final a = deliveryAddress?.trim() ?? '';
    return b.isNotEmpty &&
        a.isNotEmpty &&
        deliveryLatitude != null &&
        deliveryLongitude != null;
  }

  Future<bool> saveDeliveryAddress({
    required String building,
    required String address,
    String? floor,
    String? landmark,
    String? fullName,
    String? addressTitle,
    String? city,
    double? latitude,
    double? longitude,
    int? frequency,
    bool? useForFuture,
    bool? isNotifying,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final Map<String, dynamic> data = {
        'userId': uid,
        'building': building,
        'address': address,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (floor != null) data['floor'] = floor;
      if (landmark != null) data['landmark'] = landmark;
      if (fullName != null) data['fullName'] = fullName;
      if (addressTitle != null) data['addressTitle'] = addressTitle;
      if (city != null && city.trim().isNotEmpty) data['city'] = city.trim();
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (frequency != null) data['frequency'] = frequency;
      if (useForFuture != null) data['useForFuture'] = useForFuture;
      if (isNotifying != null) data['isNotifying'] = isNotifying;

      await FirebaseFirestore.instance
          .collection('c_by_ai_delivery')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      // Update local state
      deliveryBuilding = building;
      deliveryAddress = address;
      if (floor != null) deliveryFloor = floor;
      if (landmark != null) deliveryLandmark = landmark;
      if (fullName != null) deliveryFullName = fullName;
      if (addressTitle != null) deliveryAddressTitle = addressTitle;
      if (city != null && city.trim().isNotEmpty) deliveryCity = city.trim();
      if (latitude != null) deliveryLatitude = latitude;
      if (longitude != null) deliveryLongitude = longitude;
      if (frequency != null) deliveryFrequency = frequency;
      if (isNotifying != null) this.isNotifying = isNotifying;

      notifyListeners();
      return true;
    } catch (e) {
      log("Error saving delivery address: $e");
      return false;
    }
  }

  static bool _bytesLookLikePdf(List<int> bytes) {
    if (bytes.length < 5) return false;
    return bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46;
  }

  List<int>? _tryBase64ToPdfBytes(String v) {
    var s = v.trim();
    if (s.isEmpty) return null;
    final dataUrlIdx = s.indexOf('base64,');
    if (dataUrlIdx != -1) {
      s = s.substring(dataUrlIdx + 7);
    }
    try {
      final raw = base64Decode(s);
      if (_bytesLookLikePdf(raw)) return raw;
    } catch (_) {}
    return null;
  }

  Future<Uint8List?> _downloadPdfFromUrl(String url) async {
    final r = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 90));
    if (r.statusCode != 200 || r.bodyBytes.isEmpty) return null;
    if (_bytesLookLikePdf(r.bodyBytes)) {
      return Uint8List.fromList(r.bodyBytes);
    }
    return null;
  }

  /// Parses common “download PDF” API shapes: `{ url }`, `{ data: { pdf_base64 } }`, etc.
  Future<Uint8List?> _resolvePdfFromApiJson(dynamic j, [int depth = 0]) async {
    if (depth > 6 || j == null) return null;

    if (j is String) {
      final b = _tryBase64ToPdfBytes(j);
      return b != null ? Uint8List.fromList(b) : null;
    }

    if (j is! Map) return null;
    final m = j.map((k, v) => MapEntry(k.toString(), v));

    for (final key in [
      'url',
      'pdf_url',
      'download_url',
      'file_url',
      'link',
      'href',
    ]) {
      final u = m[key]?.toString();
      if (u != null && u.startsWith('http')) {
        final got = await _downloadPdfFromUrl(u);
        if (got != null) return got;
      }
    }

    for (final key in ['pdf', 'pdf_base64', 'base64', 'file', 'content']) {
      final v = m[key];
      if (v is String) {
        final b = _tryBase64ToPdfBytes(v);
        if (b != null) return Uint8List.fromList(b);
      }
    }

    for (final key in ['data', 'payload', 'result']) {
      final got = await _resolvePdfFromApiJson(m[key], depth + 1);
      if (got != null) return got;
    }

    return null;
  }

  /// `GET /meal-plan/{device_id}/pdf` — AI/backend PDF only (same `device_id` as meal sync).
  /// Sends [session_id] when available so the server can resolve the right plan.
  Future<Uint8List?> fetchMealPlanPdfFromApi() async {
    try {
      final deviceId = await _getDeviceId();
      var uri = Uri.parse('$_baseUrl/meal-plan/$deviceId/pdf');
      if (_sessionId != null && _sessionId!.trim().isNotEmpty) {
        uri = uri.replace(queryParameters: {
          ...uri.queryParameters,
          'session_id': _sessionId!.trim(),
        });
      }
      final headers = <String, String>{
        'Accept': 'application/pdf, application/json;q=0.9, */*;q=0.8',
      };
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final t = await user.getIdToken();
          if (t != null && t.isNotEmpty) {
            headers['Authorization'] = 'Bearer $t';
          }
        } catch (_) {}
      }
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 90));
      if (response.statusCode != 200) {
        log('meal-plan/pdf: HTTP ${response.statusCode}');
        return null;
      }
      final bytes = response.bodyBytes;
      if (bytes.isEmpty) return null;
      if (_bytesLookLikePdf(bytes)) {
        return Uint8List.fromList(bytes);
      }
      try {
        final decoded = jsonDecode(utf8.decode(bytes));
        final resolved = await _resolvePdfFromApiJson(decoded);
        if (resolved != null) return resolved;
      } catch (_) {
        log('meal-plan/pdf: response is not PDF and not JSON');
      }
      return null;
    } catch (e) {
      log('meal-plan/pdf fetch: $e');
      return null;
    }
  }

  /// Saves frequency + delivery, uploads a meal-plan PDF to Storage, and merges
  /// order fields into `c_by_ai_delivery` for CRM.
  Future<bool> confirmCByAiOrder({
    required int frequency,
    required bool useForFuture,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      error = 'Not signed in';
      notifyListeners();
      return false;
    }
    if (!hasCompleteDeliveryAddress) {
      error = 'Add a delivery address on the map first';
      notifyListeners();
      return false;
    }

    try {
      final saved = await saveDeliveryAddress(
        building: deliveryBuilding!,
        address: deliveryAddress!,
        floor: deliveryFloor,
        landmark: deliveryLandmark,
        fullName: deliveryFullName,
        addressTitle: deliveryAddressTitle,
        city: deliveryCity,
        latitude: deliveryLatitude,
        longitude: deliveryLongitude,
        frequency: frequency,
        useForFuture: useForFuture,
      );
      if (!saved) {
        error = 'Could not save delivery address';
        notifyListeners();
        return false;
      }

      final meals = mealData[selectedDay] ?? [];
      final mealList = meals
          .map(
            (m) => <String, dynamic>{
              'type': m.type,
              'name': m.name,
              'time': m.time,
              'totalCal': m.totalCal,
              'totalProtein': m.totalProtein,
              'totalCarbs': m.totalCarbs,
              'totalFat': m.totalFat,
            },
          )
          .toList();

      // Always build from local mealData — server PDF currently returns incomplete content.
      // Server PDF is fetched in the background only to store as a secondary CRM URL.
      Uint8List pdfBytes;
      try {
        pdfBytes = await CByAiPdfService.buildMealPlanPdf(
          mealData: mealData,
          dailyTotals: dailyTotals,
          summary: summary,
          selectedDay: selectedDay,
        );
      } catch (pdfErr) {
        // Last-resort: try the server PDF
        log('Client PDF build failed ($pdfErr), falling back to server PDF');
        final Uint8List? apiPdf = await fetchMealPlanPdfFromApi();
        if (apiPdf == null || apiPdf.isEmpty) {
          error = 'Could not generate your meal plan PDF. Please try again.';
          notifyListeners();
          return false;
        }
        pdfBytes = apiPdf;
      }

      // Optionally fetch server PDF URL in background (non-blocking, for CRM ops)
      fetchMealPlanPdfFromApi().then((serverBytes) {
        // ignore bytes — we only care about ensuring the server has processed it
      }).catchError((_) {});

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${(_sessionId ?? 'plan').replaceAll(RegExp(r'[^\w-]'), '_')}.pdf';
      final ref = FirebaseStorage.instance
          .ref()
          .child('c_by_ai_orders/$uid/$fileName');
      await ref.putData(
        pdfBytes,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('c_by_ai_delivery')
          .doc(uid)
          .set(
            {
              'mealPlanPdfUrl': url,
              'mealPlanPdfPath': ref.fullPath,
              'mealPlanPdfUpdatedAt': FieldValue.serverTimestamp(),
              'lastOrderSelectedDay': selectedDay,
              'lastOrderMeals': mealList,
              'lastOrderAt': FieldValue.serverTimestamp(),
              'lastSessionId': _sessionId,
            },
            SetOptions(merge: true),
          );

      lastMealPlanPdfUrl = url;
      error = null;
      notifyListeners();
      return true;
    } catch (e, st) {
      log("confirmCByAiOrder: $e\n$st");
      error = 'Could not complete order. Try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _httpClient?.close();
    super.dispose();
  }
}
