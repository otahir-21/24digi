// Recovery score is NOT from the SDK; it is computed from raw SDK metrics.
// See docs/SDK_RECOVERY_READINESS_FINDINGS.md.

/// Inputs for a single recovery score calculation.
/// All fields optional; missing data reduces contribution of that factor.
class RecoveryInput {
  const RecoveryInput({
    this.totalSleepMinutes,
    this.hrv,
    this.restingHeartRate,
    this.stress,
    this.yesterdaySteps,
    this.hrvHistoryLast7Days,
    this.restingHeartRateHistoryLast7Days,
  });

  /// Last night's total sleep (from SleepStorage / sleep parser).
  final int? totalSleepMinutes;

  /// Current or latest HRV (ms). From BraceletChannel.lastKnownHrv or live merge.
  final int? hrv;

  /// Resting or morning heart rate (bpm). From live data or estimated.
  final int? restingHeartRate;

  /// Stress/fatigue 0–100 if available (device or derived).
  final int? stress;

  /// Yesterday's step count (activity load). From WeeklyDataStorage.last7DaysSteps[5].
  final int? yesterdaySteps;

  /// Last 7 days of valid HRV values (oldest first). Used for baseline average.
  final List<int>? hrvHistoryLast7Days;

  /// Last 7 days of valid resting HR values (oldest first). Used for baseline average.
  final List<int>? restingHeartRateHistoryLast7Days;
}

/// Result of recovery score calculation.
class RecoveryResult {
  const RecoveryResult({
    required this.score,
    required this.status,
    required this.reasons,
  });

  /// Score 0–100.
  final int score;

  /// Label: Low / Fair / Good / Excellent.
  final String status;

  /// Short reasons (positive and negative) for the score.
  final List<String> reasons;
}

/// Computes recovery score from raw metrics (sleep, HRV, resting HR, stress, activity).
/// Uses 7-day baselines when provided; otherwise uses fixed thresholds.
class RecoveryScoreCalculator {
  RecoveryScoreCalculator._();

  // ─── Sleep (adjustable constants) ─────────────────────────────────────────
  /// Target sleep range: 7–9 h. Below this we penalize.
  static const int sleepTargetMinMinutes = 420; // 7 h
  static const int sleepTargetMaxMinutes = 540; // 9 h
  /// Penalty per 30 min short of target (capped).
  static const int sleepPenaltyPer30MinShort = 5;
  /// Max penalty from sleep alone (so one factor doesn’t dominate).
  static const int sleepMaxPenalty = 25;
  /// Slight penalty for very long sleep (> 9 h) – can indicate poor quality or oversleep.
  static const int sleepOverMaxPenalty = 5;

  // ─── HRV vs baseline (adjustable) ────────────────────────────────────────
  /// Default HRV “baseline” when no 7-day history (ms). Used for relative comparison.
  static const int defaultHrvBaselineMs = 45;
  /// Bonus when HRV is above baseline (up to this many points).
  static const int hrvAboveBaselineMaxBonus = 15;
  /// Penalty when HRV is below baseline (up to this many points).
  static const int hrvBelowBaselineMaxPenalty = 20;
  /// Threshold: HRV below this (ms) is considered “low” even without baseline.
  static const int hrvLowAbsoluteMs = 25;

  // ─── Resting HR vs baseline (adjustable) ──────────────────────────────────
  /// Default resting HR baseline when no history (bpm).
  static const int defaultRestingHrBaseline = 65;
  /// Penalty when resting HR is above baseline (up to this many points).
  static const int restingHrAboveBaselineMaxPenalty = 15;
  /// Resting HR considered “high” in absolute terms (bpm).
  static const int restingHrHighAbsoluteBpm = 80;

  // ─── Stress (adjustable) ──────────────────────────────────────────────────
  /// Stress level (0–100) above which we apply penalty.
  static const int stressHighThreshold = 70;
  static const int stressPenalty = 10;

  // ─── Yesterday activity load (overreaching) (adjustable) ──────────────────
  /// Steps above this with poor sleep may indicate under-recovery.
  static const int yesterdayStepsHighThreshold = 12000;
  /// Extra penalty when yesterday steps were high and sleep was short.
  static const int overreachingPenalty = 10;

  /// Compute recovery score and status from [input].
  static RecoveryResult calculate(RecoveryInput input) {
    double score = 100.0;
    final reasons = <String>[];

    // ─── Sleep ──────────────────────────────────────────────────────────────
    final sleepMin = input.totalSleepMinutes;
    if (sleepMin != null && sleepMin > 0) {
      if (sleepMin < sleepTargetMinMinutes) {
        final shortfall = sleepTargetMinMinutes - sleepMin;
        final penalty = (shortfall / 30).ceil() * sleepPenaltyPer30MinShort;
        final capped = penalty > sleepMaxPenalty ? sleepMaxPenalty : penalty;
        score -= capped;
        reasons.add('Poor sleep duration (${sleepMin ~/ 60}h ${sleepMin % 60}m)');
      } else if (sleepMin > sleepTargetMaxMinutes) {
        score -= sleepOverMaxPenalty;
        reasons.add('Very long sleep (${sleepMin ~/ 60}h)');
      } else {
        reasons.add('Good sleep duration');
      }
    }

    // ─── HRV vs baseline ───────────────────────────────────────────────────
    final hrvBaseline = _averageValid(input.hrvHistoryLast7Days, 10, 200) ?? defaultHrvBaselineMs;
    final hrv = input.hrv;
    if (hrv != null && hrv > 0) {
      if (hrv >= hrvBaseline) {
        final delta = (hrv - hrvBaseline).clamp(0, 50);
        final bonus = (delta / 50.0 * hrvAboveBaselineMaxBonus).round();
        score += bonus;
        reasons.add('HRV above baseline');
      } else {
        final delta = (hrvBaseline - hrv).clamp(0, 80);
        final penalty = (delta / 80.0 * hrvBelowBaselineMaxPenalty).round();
        score -= penalty;
        reasons.add('HRV below baseline');
      }
      if (hrv < hrvLowAbsoluteMs) {
        reasons.add('Low HRV');
      }
    }

    // ─── Resting HR vs baseline ─────────────────────────────────────────────
    final hrBaseline = _averageValid(input.restingHeartRateHistoryLast7Days, 40, 120) ?? defaultRestingHrBaseline;
    final restingHr = input.restingHeartRate;
    if (restingHr != null && restingHr >= 40 && restingHr <= 120) {
      if (restingHr > hrBaseline) {
        final delta = (restingHr - hrBaseline).clamp(0, 30);
        final penalty = (delta / 30.0 * restingHrAboveBaselineMaxPenalty).round();
        score -= penalty;
        reasons.add('Resting HR above baseline');
      }
      if (restingHr >= restingHrHighAbsoluteBpm) {
        reasons.add('High resting HR');
      }
    }

    // ─── Stress ─────────────────────────────────────────────────────────────
    final stress = input.stress;
    if (stress != null && stress >= stressHighThreshold) {
      score -= stressPenalty;
      reasons.add('High stress');
    }

    // ─── Yesterday activity (overreaching) ──────────────────────────────────
    final yesterdaySteps = input.yesterdaySteps;
    final sleepOk = sleepMin != null && sleepMin >= sleepTargetMinMinutes;
    if (yesterdaySteps != null &&
        yesterdaySteps >= yesterdayStepsHighThreshold &&
        !sleepOk) {
      score -= overreachingPenalty;
      reasons.add('High activity yesterday with insufficient sleep');
    }

    // Clamp and derive status
    final finalScore = score.clamp(0.0, 100.0).round();
    final status = _statusFromScore(finalScore);

    return RecoveryResult(
      score: finalScore,
      status: status,
      reasons: reasons,
    );
  }

  static double? _averageValid(List<int>? list, int minVal, int maxVal) {
    if (list == null || list.isEmpty) return null;
    final valid = list.where((v) => v >= minVal && v <= maxVal).toList();
    if (valid.isEmpty) return null;
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  static String _statusFromScore(int score) {
    if (score <= 25) return 'Low';
    if (score <= 50) return 'Fair';
    if (score <= 75) return 'Good';
    return 'Excellent';
  }
}
