import 'data/bracelet_data_parser.dart';

/// Heuristic extra daily fluid goal from bracelet activity (steps, calories, active time).
/// This is **not** a measurement of body hydration — only a suggested intake adjustment.
class HydrationActivityAdjustment {
  HydrationActivityAdjustment._();

  /// Cap so the UI goal does not balloon unreasonably on extreme days.
  static const double maxBonusLiters = 1.2;

  /// Extra liters on top of the user's base daily goal (e.g. 2.5 L).
  static double bonusLitersFromLiveData(Map<String, dynamic>? m) {
    if (m == null || m.isEmpty) return 0;

    final steps = BraceletDataParser.intFrom(
          BraceletDataParser.firstOf(m, ['step', 'Step', 'steps', 'Steps']),
        ) ??
        0;
    final cal = BraceletDataParser.toDouble(
          BraceletDataParser.firstOf(m, ['calories', 'Calories']),
        ) ??
        0.0;
    final activeMin = BraceletDataParser.intFrom(
          BraceletDataParser.firstOf(m, ['activeMinutes', 'ActiveMinutes']),
        ) ??
        0;
    final exerciseMin = BraceletDataParser.intFrom(
          BraceletDataParser.firstOf(m, ['exerciseMinutes', 'ExerciseMinutes']),
        ) ??
        0;

    if (steps <= 0 && cal <= 0 && activeMin <= 0 && exerciseMin <= 0) {
      return 0;
    }

    // Replacement proxy: deliberate exercise > general active minutes > kcal > steps above baseline.
    var bonus = 0.0;
    bonus += exerciseMin * 0.004;
    bonus += activeMin * 0.0018;
    bonus += (cal / 500.0) * 0.05;
    final stepsAbove = (steps - 3000).clamp(0, 20000);
    bonus += (stepsAbove / 5000.0) * 0.06;
    // Small floor when the band reports any movement so the goal visibly bumps (was ~0.02 L before cap).
    if (steps > 0 && bonus < 0.08) {
      bonus = 0.08;
    }

    return double.parse(bonus.clamp(0.0, maxBonusLiters).toStringAsFixed(3));
  }

  static double effectiveGoalLiters(double baseGoalLiters, Map<String, dynamic>? liveData) =>
      baseGoalLiters + bonusLitersFromLiveData(liveData);

  static double progress(
    double currentLiters,
    double baseGoalLiters,
    Map<String, dynamic>? liveData,
  ) {
    final g = effectiveGoalLiters(baseGoalLiters, liveData);
    if (g <= 0) return 0;
    return (currentLiters / g).clamp(0.0, 1.0);
  }

  static int percentRounded(
    double currentLiters,
    double baseGoalLiters,
    Map<String, dynamic>? liveData,
  ) {
    return (progress(currentLiters, baseGoalLiters, liveData) * 100).round().clamp(0, 100);
  }

  /// Bracelet-main-tile index 38–97 from current band readings only (not logged water / not a clinical hydration %).
  /// Higher ≈ lower immediate fluid strain from activity + vitals; lower ≈ drink sooner.
  static int? braceletHydrationIndexPercent(Map<String, dynamic>? m) {
    if (m == null || m.isEmpty) return null;

    final steps = BraceletDataParser.intFrom(
          BraceletDataParser.firstOf(m, ['step', 'Step', 'steps', 'Steps']),
        ) ??
        0;
    final cal = BraceletDataParser.toDouble(
          BraceletDataParser.firstOf(m, ['calories', 'Calories']),
        ) ??
        0.0;
    final activeMin = BraceletDataParser.intFrom(
          BraceletDataParser.firstOf(m, ['activeMinutes', 'ActiveMinutes']),
        ) ??
        0;
    final exerciseMin = BraceletDataParser.intFrom(
          BraceletDataParser.firstOf(m, ['exerciseMinutes', 'ExerciseMinutes']),
        ) ??
        0;
    final hr = BraceletDataParser.intFrom(
      BraceletDataParser.firstOf(m, ['heartRate', 'HeartRate', 'hr', 'HR']),
    );
    final hrv = BraceletDataParser.intFrom(
      BraceletDataParser.firstOf(m, ['hrv', 'HRV', 'Hrv', 'hrvValue', 'hrvResultValue']),
    );
    final temp = BraceletDataParser.toDouble(
      BraceletDataParser.firstOf(m, [
        'temperature',
        'Temperature',
        'temp',
        'Temp',
        'skinTemperature',
        'SkinTemperature',
      ]),
    );
    final stress = BraceletDataParser.intFrom(
      BraceletDataParser.firstOf(m, ['stress', 'Stress']),
    );
    final spo2Raw = BraceletDataParser.firstOf(m, [
      'spo2',
      'Blood_oxygen',
      'blood_oxygen',
      'SPO2',
      'Spo2',
    ]);
    final spo2 = BraceletDataParser.spo2PercentFromDevice(spo2Raw);

    final hasSignal = steps > 0 ||
        cal > 0 ||
        activeMin > 0 ||
        exerciseMin > 0 ||
        (hr != null && hr > 0) ||
        temp != null ||
        (hrv != null && hrv > 0) ||
        spo2 != null;
    if (!hasSignal) return null;

    var score = 74.0;

    score -= exerciseMin * 0.42;
    score -= activeMin * 0.15;
    score -= (cal / 180.0).clamp(0, 40) * 0.4;
    score -= (steps / 14000.0).clamp(0, 1.0) * 7;

    if (temp != null) {
      if (temp >= 36.25) {
        score -= (temp - 36.0) * 11;
      } else if (temp < 34.8) {
        score -= (34.8 - temp) * 2.5;
      }
    }

    if (hr != null && hr > 0) {
      if (hr > 102) {
        score -= (hr - 102) * 0.22;
      } else if (hr >= 52 && hr <= 90) {
        score += 3.5;
      }
    }

    if (hrv != null && hrv > 0) {
      if (hrv >= 48) {
        score += 5;
      } else if (hrv < 28) {
        score -= 6;
      }
    }

    if (stress != null && stress > 62) {
      score -= (stress - 62) * 0.09;
    }

    if (spo2 != null && spo2 < 96) {
      score -= (96 - spo2) * 1.1;
    }

    return score.round().clamp(38, 97);
  }

  /// Bar heights 0–1 for weekly/monthly charts from stored daily steps + calories (same heuristic, no HR/temp history).
  static List<double> normalizedHydrationIndexBarsFromActivitySeries(
    List<double> stepsSeries,
    List<double> caloriesSeries,
  ) {
    if (stepsSeries.isEmpty) return [];
    final cal = caloriesSeries.length == stepsSeries.length
        ? caloriesSeries
        : List<double>.filled(stepsSeries.length, 0.0);
    final out = <double>[];
    for (var i = 0; i < stepsSeries.length; i++) {
      final idx = braceletHydrationIndexPercent({
        'steps': stepsSeries[i].round(),
        'calories': cal[i],
      });
      out.add(
        idx == null ? 0.0 : ((idx - 38) / (97 - 38)).clamp(0.0, 1.0),
      );
    }
    return out;
  }
}
