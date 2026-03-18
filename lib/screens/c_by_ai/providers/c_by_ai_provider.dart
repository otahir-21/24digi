import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/c_by_ai_models.dart';

double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

class CByAiProvider extends ChangeNotifier {
  final _baseUrl = 'http://16.170.207.64/api/v1/mobile';

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
  int deliveryFrequency = 3;
  bool isNotifying = false;
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
    String? deviceId = prefs.getString('c_by_ai_device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('c_by_ai_device_id', deviceId);
    }
    return deviceId;
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
          await prefs.setString('c_by_ai_session_id', _sessionId!);

          final metrics =
              data['user_metrics'] ?? data['data']?['user_metrics'] ?? {};

          String goalStr = metrics['goal']?.toString() ?? 'maintain';
          String goalDisplay = "Maintain Weight";
          if (goalStr == "lose") goalDisplay = "Lose Weight";
          if (goalStr == "gain") goalDisplay = "Gain Muscle";

          fitnessMetrics = FitnessMetricsModel(
            bmi: _toDouble(metrics['bmi'], 22.0),
            bodyFat: _toDouble(metrics['body_fat'], 18.5),
            bmr: _toDouble(metrics['bmr'], 1800.0),
            tdee: _toDouble(metrics['tdee'], 2400.0),
            bmiOverview: metrics['bmi_overview']?.toString() ?? 'Normal',
            goal: goalDisplay,
            goalExplanation: '',
          );

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
              resData['completed'] == true || status == 'completed';

          generationProgress = _toDouble(resData['progress']);
          currentGeneratingDay = resData['day_completed'] ?? 0;
          int totalDays = resData['total_days'] ?? 7;
          if (totalDays < 1) totalDays = 7; // ensure valid

          int currentDay = resData['current_day'] ?? (currentGeneratingDay + 1);
          if (currentDay > totalDays)
            currentDay = totalDays; // Fix "Generating day 8 of 7"

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
            final mealMap = resData['meal_data'] as Map<String, dynamic>;
            final rawKeys = mealMap.keys
                .map((k) => int.tryParse(k))
                .whereType<int>()
                .toList();
            // Detect 0-indexed keys (server sends days 0..N-1 instead of 1..N)
            final isZeroIndexed = rawKeys.isNotEmpty &&
                rawKeys.every((k) => k < rawKeys.length);
            final offset = isZeroIndexed ? 1 : 0;

            mealMap.forEach((dayStr, dayContent) {
              final rawDay = int.tryParse(dayStr);
              if (rawDay != null && dayContent is Map) {
                final dayNum = rawDay + offset;
                final mealsRaw = dayContent['meals'];
                final mealsList = (mealsRaw is List) ? mealsRaw : [];
                final meals = mealsList
                    .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
                    .toList();
                mealData[dayNum] = meals;

                // Calculate daily totals from meals
                double dCal = 0, dPro = 0, dCar = 0, dFat = 0, dPrice = 0;
                for (var m in meals) {
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
              }
            });
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

  Future<void> _fetchMealPlan() async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.get(
        Uri.parse('$_baseUrl/meal-plan/$deviceId'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final resData = data['data'] ?? data;

          // Only clear if we actually got a new full plan to avoid losing incremental stream data
          final hasNewData =
              (resData['meal_plan'] != null &&
                  (resData['meal_plan'] as List).isNotEmpty) ||
              (resData['meal_data'] != null &&
                  (resData['meal_data'] as Map).isNotEmpty);

          if (hasNewData) {
            mealData.clear();
            dailyTotals.clear();
          }

          final daysRaw = resData['meal_plan'];
          final days = (daysRaw is List) ? daysRaw : [];
          final totalsRaw = resData['daily_totals'];
          final totals = (totalsRaw is List) ? totalsRaw : [];

          // Also check for 'meal_data' map format
          if (resData['meal_data'] != null && resData['meal_data'] is Map) {
            final mealMap = resData['meal_data'] as Map<String, dynamic>;
            final rawKeys = mealMap.keys
                .map((k) => int.tryParse(k))
                .whereType<int>()
                .toList();
            // Detect 0-indexed keys (server sends days 0..6 instead of 1..7)
            final isZeroIndexed = rawKeys.isNotEmpty && rawKeys.every((k) => k < rawKeys.length);
            final offset = isZeroIndexed ? 1 : 0;

            mealMap.forEach((dayStr, dayContent) {
              final rawDay = int.tryParse(dayStr);
              if (rawDay != null && dayContent is Map) {
                final dayNum = rawDay + offset; // remap 0→1, 1→2 … or keep as-is
                final mealsRaw = dayContent['meals'];
                final mealsList = (mealsRaw is List) ? mealsRaw : [];
                final meals = mealsList
                    .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
                    .toList();
                mealData[dayNum] = meals;

                // Calculate daily totals directly from meal nutrition data
                double dCal = 0, dPro = 0, dCar = 0, dFat = 0, dPrice = 0;
                for (var m in meals) {
                  dCal += m.totalCal;
                  dPro += m.totalProtein;
                  dCar += m.totalCarbs;
                  dFat += m.totalFat;
                  dPrice += m.totalPrice;
                }

                // Prefer server-supplied daily totals as fallback for cal/price
                final serverDayCal = _toDouble(dayContent['daily_total_cal']);
                final serverDayPrice = _toDouble(dayContent['daily_total_cost']);

                dailyTotals[dayNum] = DailyTotalModel(
                  calories: dCal > 0 ? dCal : serverDayCal,
                  protein: dPro,
                  carbs: dCar,
                  fat: dFat,
                  price: dPrice > 0 ? dPrice : serverDayPrice,
                );
              }
            });
          } else {
            for (int i = 0; i < days.length; i++) {
              final d = days[i];
              if (d is List) {
                int dayNum = i + 1;
                mealData[dayNum] = d
                    .map((m) => MealModel.fromJson(m as Map<String, dynamic>))
                    .toList();
              }
            }

            for (int i = 0; i < totals.length; i++) {
              final t = totals[i];
              if (t is Map) {
                dailyTotals[i + 1] = DailyTotalModel.fromJson(
                  t as Map<String, dynamic>,
                );
              }
            }
          }

          final summaryData = resData['summary'] ?? {};
          int sTotalDays = resData['total_days'] ?? 7;
          if (mealData.keys.isNotEmpty) {
            int maxDayKey = mealData.keys.reduce((a, b) => a > b ? a : b);
            if (maxDayKey > sTotalDays) sTotalDays = maxDayKey;
          }
          if (sTotalDays < 1) sTotalDays = 7; // ensure valid

          // Always recompute totals from actual meal data to avoid zeros
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

          // Fallback: use server summary if we still have no calorie data from meals
          if (sTotalCal == 0) {
            sTotalCal = _toDouble(summaryData['total_calories']);
            sTotalPro = _toDouble(summaryData['total_protein']);
            sTotalCar = _toDouble(summaryData['total_carbs']);
            sTotalFat = _toDouble(summaryData['total_fat']);
            sTotalPrice = _toDouble(summaryData['total_price']);
            if (sTotalMeals == 0) sTotalMeals = resData['total_meals'] ?? summaryData['total_meals'] ?? 0;
          }

          // Rebuild dailyTotals from mealData to guarantee consistency
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

          if (resData['goal'] != null && fitnessMetrics != null) {
            String goalStr = resData['goal'].toString();
            String goalDisplay = "Maintain Weight";
            if (goalStr == "lose") goalDisplay = "Lose Weight";
            if (goalStr == "gain") goalDisplay = "Gain Muscle";

            fitnessMetrics = FitnessMetricsModel(
              bmi: fitnessMetrics!.bmi,
              bodyFat: fitnessMetrics!.bodyFat,
              bmr: fitnessMetrics!.bmr,
              tdee: fitnessMetrics!.tdee,
              bmiOverview: fitnessMetrics!.bmiOverview,
              goal: goalDisplay,
              goalExplanation: resData['goal_explanation'] ?? '',
            );
          }

          selectedDay = 1;
          notifyListeners();
        }
      }
    } catch (e) {
      log("Fetch meal plan error: $e");
      // Fallback summary to avoid crash
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
        deliveryFrequency = data['frequency'] ?? 3;
        isNotifying = data['isNotifying'] ?? false;
        notifyListeners();
      }
    } catch (e) {
      log("Error fetching delivery address: $e");
    }
  }

  Future<bool> recoverSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('c_by_ai_session_id');
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
              await prefs.setString('c_by_ai_session_id', _sessionId!);
              isLoadingUserData = false;
              connectToStream();
              return true;
            }
          }
        }
      }

      // 2. Check saved session status fallback
      if (_sessionId != null) {
        final statusRes = await http.post(
          Uri.parse('$_baseUrl/generate-meals/status'),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({"session_id": _sessionId}),
        );

        if (statusRes.statusCode == 200) {
          final statusData = jsonDecode(statusRes.body);
          final resData = statusData['data'] ?? statusData;
          String status = resData['status']?.toString() ?? 'failed';

          if (status == 'processing') {
            isLoadingUserData = false;
            connectToStream();
            return true;
          } else if (status == 'completed') {
            await _fetchMealPlan();
            isGenerating = false;
            generationProgress = 100.0;
            isLoadingUserData = false;
            notifyListeners();
            return true;
          } else {
            await prefs.remove('c_by_ai_session_id');
          }
        } else {
          await prefs.remove('c_by_ai_session_id');
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
    await prefs.remove('c_by_ai_session_id');

    notifyListeners();
  }

  Future<void> saveDeliveryAddress({
    required String building,
    required String address,
    String? floor,
    String? landmark,
    String? fullName,
    String? addressTitle,
    int? frequency,
    bool? useForFuture,
    bool? isNotifying,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

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
      if (frequency != null) deliveryFrequency = frequency;
      if (isNotifying != null) this.isNotifying = isNotifying;

      notifyListeners();
    } catch (e) {
      log("Error saving delivery address: $e");
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _httpClient?.close();
    super.dispose();
  }
}
