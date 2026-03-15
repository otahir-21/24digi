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
  String? error;

  String? _sessionId;
  http.Client? _streamClient;
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
            .collection('users')
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
        'height': data['height'] ?? 175,
        'weight': data['weight'] ?? 70,
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
      final body = {
        'device_id': deviceId,
        'age': userInfo['age'],
        'height': userInfo['height'],
        'weight': userInfo['weight'],
        'gender': userInfo['gender'],
        'activity_level': userInfo['activity_level'],
        'neck_circumference': userInfo['neck_circumference'],
        'waist_circumference': userInfo['waist_circumference'],
        'hip_circumference': userInfo['hip_circumference'],
      };
      log("body: $body");
      final response = await http.post(
        Uri.parse('$_baseUrl/generate-meals'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );
      log("response:: code: ${response.statusCode}, body: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        error =
            "Server error ${response.statusCode}: The AI backend is taking too long to respond (Gateway Timeout) or is experiencing issues.";
        isGenerating = false;
        notifyListeners();
        return false;
      }

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        _sessionId = data['data']['session_id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('c_by_ai_session_id', _sessionId!);

        final userMetrics = data['data']['user_metrics'] ?? {};
        fitnessMetrics = FitnessMetricsModel(
          bmi: (userMetrics['bmi'] ?? 22.86).toDouble(),
          bodyFat: (userMetrics['body_fat'] ?? 18.5).toDouble(),
          bmr: (userMetrics['bmr'] ?? 1800.0).toDouble(),
          tdee: (userMetrics['tdee'] ?? 2400.0).toDouble(),
          bmiOverview: userMetrics['bmi_overview']?.toString() ?? 'Normal',
          goal: userMetrics['goal']?.toString() ?? 'Maintain Weight',
          goalExplanation: userMetrics['goal_explanation']?.toString() ?? '',
        );

        notifyListeners();
        return true;
      } else {
        error = data['message'] ?? 'Failed to start generation';
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

  void _reconnectStream(int retriesLeft) {
    if (retriesLeft > 0 && isGenerating) {
      Future.delayed(const Duration(seconds: 2), () {
        connectToStream(retries: retriesLeft - 1);
      });
    } else if (isGenerating) {
      error = "Connection lost. Failed to reconnect.";
      isGenerating = false;
      notifyListeners();
    }
  }

  Future<void> connectToStream({int retries = 3}) async {
    if (_sessionId == null) return;

    isGenerating = true;
    error = null;
    notifyListeners();

    try {
      _streamClient?.close();
      _streamClient = http.Client();

      final request = http.Request(
        'GET',
        Uri.parse('$_baseUrl/stream/$_sessionId'),
      );
      final response = await _streamClient!.send(request);

      if (response.statusCode != 200) {
        _reconnectStream(retries);
        return;
      }

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.isEmpty) return;

              if (line.startsWith('event:')) {
                // Read next line for data
                return;
              }

              if (line.startsWith('data:')) {
                try {
                  final payload = line.substring(5).trim();
                  if (payload.isEmpty) return;

                  final decoded = jsonDecode(payload);

                  // We infer event type from the payload keys
                  if (decoded['status'] == 'processing' &&
                      decoded.containsKey('progress')) {
                    // status or heartbeat
                    generationProgress = (decoded['progress'] ?? 0).toDouble();
                    progressMessage = decoded['message'] ?? progressMessage;
                    notifyListeners();
                  } else if (decoded.containsKey('meals') &&
                      decoded.containsKey('day')) {
                    // meal_data
                    int day = decoded['day'];
                    List<MealModel> meals = (decoded['meals'] as List<dynamic>)
                        .map((m) => MealModel.fromJson(m))
                        .toList();
                    mealData[day] = meals;

                    if (decoded['daily_total'] != null) {
                      dailyTotals[day] = DailyTotalModel.fromJson(
                        decoded['daily_total'],
                      );
                    }
                    notifyListeners();
                  } else if (decoded.containsKey('day') &&
                      decoded.containsKey('progress')) {
                    // day_progress / day_complete
                    currentGeneratingDay = decoded['day'];
                    generationProgress = (decoded['progress'] ?? 0).toDouble();
                    progressMessage =
                        decoded['message'] ??
                        'Completed day $currentGeneratingDay';
                    notifyListeners();
                  } else if (decoded['status'] == 'completed') {
                    // complete
                    summary = MealSummaryModel.fromJson(
                      decoded['summary'] ?? {},
                    );
                    progressMessage =
                        decoded['message'] ?? 'Meal generation completed!';
                    generationProgress = 100.0;
                    isGenerating = false;

                    if (summary!.totalDays > 0 &&
                        selectedDay > summary!.totalDays) {
                      selectedDay = 1;
                    }
                    notifyListeners();
                    _streamClient?.close();
                    _streamClient = null;
                  } else if (decoded['status'] == 'failed') {
                    // error
                    error = decoded['message'] ?? 'Stream error';
                    isGenerating = false;
                    notifyListeners();
                    _streamClient?.close();
                    _streamClient = null;
                  }
                } catch (e) {
                  // Ignore parse errors on partial stream data
                }
              }
            },
            onError: (err) {
              _reconnectStream(retries);
            },
            onDone: () {
              if (isGenerating) {
                _reconnectStream(retries);
              }
            },
            cancelOnError: true,
          );
    } catch (e) {
      _reconnectStream(retries);
    }
  }

  Future<bool> recoverSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('c_by_ai_session_id');

    if (_sessionId == null) return false;

    isLoadingUserData = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/session/$_sessionId/status'),
      );
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final status = data['data']['status'];

        if (status == 'processing') {
          isLoadingUserData = false;
          connectToStream();
          return true;
        } else if (status == 'completed') {
          final deviceId = await _getDeviceId();
          final mlpRes = await http.get(
            Uri.parse('$_baseUrl/meal-plan/$deviceId'),
          );
          final mlpData = jsonDecode(mlpRes.body);

          if (mlpData['success'] == true) {
            summary = MealSummaryModel.fromJson(
              mlpData['data']['summary'] ?? {},
            );
            final days = mlpData['data']['meal_plan'] as List<dynamic>? ?? [];
            final dTotals =
                mlpData['data']['daily_totals'] as List<dynamic>? ?? [];

            for (int i = 0; i < days.length; i++) {
              final dayNum = i + 1;
              mealData[dayNum] = (days[i] as List<dynamic>)
                  .map((m) => MealModel.fromJson(m))
                  .toList();
            }

            for (int i = 0; i < dTotals.length; i++) {
              final dayNum = i + 1;
              dailyTotals[dayNum] = DailyTotalModel.fromJson(dTotals[i]);
            }

            isGenerating = false;
            generationProgress = 100.0;
            isLoadingUserData = false;
            notifyListeners();
            return true;
          }
        }
      }
    } catch (e) {
      error = e.toString();
    }

    isLoadingUserData = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _streamClient?.close();
    super.dispose();
  }
}
