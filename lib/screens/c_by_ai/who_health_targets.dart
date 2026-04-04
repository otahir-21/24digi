import 'dart:math' as math;

/// WHO-style **adult** guidance for education only — not a medical diagnosis.
/// BMI classes: WHO (adults 18+). Waist cut-offs: commonly cited Europid values;
/// WHO notes ethnicity-specific thresholds may differ.
class WhoHealthTargets {
  WhoHealthTargets({
    required this.currentBmi,
    required this.bmiCategoryLabel,
    required this.healthyWeightMinKg,
    required this.healthyWeightMaxKg,
    required this.suggestedGoal,
    required this.suggestedTargetWeightKg,
    required this.suggestedTargetWaistCm,
    required this.suggestedTargetHipCm,
    required this.suggestedTargetNeckCm,
    required this.isAdultGuidance,
    required this.referenceBullets,
    required this.disclaimer,
  });

  final double currentBmi;
  final String bmiCategoryLabel;
  final double healthyWeightMinKg;
  final double healthyWeightMaxKg;

  /// `lose` | `maintain` | `gain` — matches C BY AI target screen.
  final String suggestedGoal;

  final double suggestedTargetWeightKg;
  final double suggestedTargetWaistCm;
  final double suggestedTargetHipCm;
  final double suggestedTargetNeckCm;

  final bool isAdultGuidance;
  final List<String> referenceBullets;
  final String disclaimer;

  static const double _bmiUnderweight = 18.5;
  static const double _bmiOverweight = 25.0;
  static const double _bmiObese = 30.0;

  /// Europid-oriented waist (cm) — increased / substantially increased risk.
  static const double _waistMaleIncreased = 94.0;
  static const double _waistMaleHigh = 102.0;
  static const double _waistFemaleIncreased = 80.0;
  static const double _waistFemaleHigh = 88.0;

  static WhoHealthTargets compute(Map<String, dynamic> userInfo) {
    final heightCm = (userInfo['height'] as num?)?.toDouble() ?? 170.0;
    final weightKg = (userInfo['weight'] as num?)?.toDouble() ?? 70.0;
    final age = (userInfo['age'] as num?)?.toInt() ?? 25;
    final genderRaw = (userInfo['gender'] as String?) ?? 'male';
    final isMale = _isMale(genderRaw);

    final waistCur = (userInfo['waist_circumference'] as num?)?.toDouble();
    final hipCur = (userInfo['hip_circumference'] as num?)?.toDouble();
    final neckCur = (userInfo['neck_circumference'] as num?)?.toDouble();

    final hM = (heightCm / 100.0).clamp(0.5, 2.5);
    final bmi = weightKg / (hM * hM);
    final wMin = _bmiUnderweight * hM * hM;
    final wMax = _bmiOverweight * hM * hM; // upper bound of “normal” band

    final category = _bmiCategory(bmi);
    final adult = age >= 18;
    final goal = _suggestGoal(bmi);
    final targetW = _suggestTargetWeightKg(
      weightKg: weightKg,
      bmi: bmi,
      wMin: wMin,
      wMax: wMax,
      goal: goal,
    );

    final waistBase = waistCur ??
        (isMale ? _waistMaleIncreased - 6 : _waistFemaleIncreased - 6);
    final targetWaist =
        _suggestTargetWaistCm(current: waistBase, isMale: isMale, goal: goal);

    final hipVal = hipCur;
    final hipHas = hipVal != null && hipVal > 0;
    final targetHip =
        hipHas ? _suggestTargetHipCm(current: hipVal, goal: goal) : 0.0;

    final neckVal = neckCur;
    final neckHas = neckVal != null && neckVal > 0;
    final targetNeck =
        neckHas ? _suggestTargetNeckCm(current: neckVal, goal: goal) : 0.0;

    final bullets = <String>[
      'Your BMI (~${bmi.toStringAsFixed(1)}): $category (adult categories, WHO).',
      'WHO adult BMI: underweight <18.5 · normal 18.5–24.9 · overweight ≥25 · obesity ≥30.',
      'Healthy weight band for your height (~${heightCm.round()} cm): '
          '${wMin.toStringAsFixed(1)}–${wMax.toStringAsFixed(1)} kg (BMI 18.5–24.9).',
      if (adult)
        'Waist targets use common Europid risk cut-offs (${isMale ? "men" : "women"}: '
            'increased risk from ~${isMale ? _waistMaleIncreased.toStringAsFixed(0) : _waistFemaleIncreased.toStringAsFixed(0)} cm); '
            'other groups may use different values.'
      else
        'You are under 18 — shown ranges are general adult references only; a clinician should set goals for minors.',
    ];

    return WhoHealthTargets(
      currentBmi: bmi,
      bmiCategoryLabel: category,
      healthyWeightMinKg: wMin,
      healthyWeightMaxKg: wMax,
      suggestedGoal: goal,
      suggestedTargetWeightKg: targetW,
      suggestedTargetWaistCm: targetWaist,
      suggestedTargetHipCm: targetHip,
      suggestedTargetNeckCm: targetNeck,
      isAdultGuidance: adult,
      referenceBullets: bullets,
      disclaimer:
          'Educational summary based on general WHO-style guidance for adults. '
          'Not medical advice. Adjust targets with a qualified professional if needed.',
    );
  }

  static bool _isMale(String g) {
    final s = g.toLowerCase();
    return s.startsWith('m');
  }

  static String _bmiCategory(double bmi) {
    if (bmi < _bmiUnderweight) return 'Underweight';
    if (bmi < _bmiOverweight) return 'Normal weight';
    if (bmi < _bmiObese) return 'Overweight';
    return 'Obesity';
  }

  static String _suggestGoal(double bmi) {
    if (bmi >= _bmiOverweight) return 'lose';
    if (bmi < _bmiUnderweight) return 'gain';
    return 'maintain';
  }

  static double _suggestTargetWeightKg({
    required double weightKg,
    required double bmi,
    required double wMin,
    required double wMax,
    required String goal,
  }) {
    switch (goal) {
      case 'lose':
        if (bmi >= _bmiObese) {
          return _round1(
            math.max(wMin + 0.5, math.min(weightKg * 0.90, weightKg - 2)),
          );
        }
        if (bmi >= _bmiOverweight) {
          final mid = (wMin + wMax) / 2;
          return _round1(
            math.max(wMin + 0.5, math.min(mid, weightKg - 1)),
          );
        }
        return _round1(weightKg * 0.98);
      case 'gain':
        return _round1(
          math.min(wMax - 0.5, math.max((wMin + wMax) / 2, weightKg + 1)),
        );
      default:
        return _round1(weightKg);
    }
  }

  static double _suggestTargetWaistCm({
    required double current,
    required bool isMale,
    required String goal,
  }) {
    final inc = isMale ? _waistMaleIncreased : _waistFemaleIncreased;
    final high = isMale ? _waistMaleHigh : _waistFemaleHigh;

    if (goal == 'lose') {
      if (current >= high) {
        return _round1((current - 8).clamp(50.0, high - 2));
      }
      if (current >= inc) {
        return _round1((inc - 4).clamp(50.0, current - 0.5));
      }
      return _round1((current * 0.97).clamp(40.0, 200.0));
    }
    if (goal == 'gain') {
      return _round1((current * 1.01).clamp(40.0, 200.0));
    }
    return _round1((current * 0.995).clamp(40.0, 200.0));
  }

  static double _suggestTargetHipCm({
    required double current,
    required String goal,
  }) {
    switch (goal) {
      case 'lose':
        return _round1((current * 0.98).clamp(30.0, 300.0));
      case 'gain':
        return _round1((current * 1.01).clamp(30.0, 300.0));
      default:
        return _round1(current);
    }
  }

  static double _suggestTargetNeckCm({
    required double current,
    required String goal,
  }) {
    switch (goal) {
      case 'lose':
        return _round1((current * 0.99).clamp(10.0, 100.0));
      case 'gain':
        return _round1((current * 1.01).clamp(10.0, 100.0));
      default:
        return _round1(current);
    }
  }

  static double _round1(double v) => (v * 10).round() / 10;
}
