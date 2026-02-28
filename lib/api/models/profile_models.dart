// ── Enums (for dropdowns / validation) ─────────────────────────────────────
// Genders: female, male, other
// Health: heart_conditions, blood_pressure, breathing_lungs, sleep_recovery,
//         blood_sugar_metabolism, none_prefer_not_to_say
// Food allergies: none, dairy, eggs, gluten, shellfish, soy, sesame, fish, other
// Dietary goals: balanced, high_protein, vegan, light_fresh
// Activity: mostly_inactive, lightly_active, moderately_active, very_active
// Preferred workouts: walking_light, strength_training, cardio, sports,
//                      yoga_stretching, at_home, gym, no_preference
// Days off: mon, tue, wed, thu, fri, sat, sun
// Primary goals: improve_fitness, muscle_gain, lose_weight, increase_endurance, stay_healthy
// Current build: lean, average, muscular, athletic, higher_body_fat

/// Full profile from GET /profile/me
class Profile {
  final String? name;
  final String? dateOfBirth;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? primaryGoal;
  final String? dietaryGoal;
  final List<String>? foodAllergies;
  final String? otherAllergyText;
  final String? activityLevel;
  final List<String>? preferredWorkouts;
  final int? workoutsPerWeek;
  final List<String>? daysOff;
  final String? timezone;
  final String? currentBuild;
  final List<String>? healthConsiderations;
  final bool? isProfileComplete;

  const Profile({
    this.name,
    this.dateOfBirth,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.primaryGoal,
    this.dietaryGoal,
    this.foodAllergies,
    this.otherAllergyText,
    this.activityLevel,
    this.preferredWorkouts,
    this.workoutsPerWeek,
    this.daysOff,
    this.timezone,
    this.currentBuild,
    this.healthConsiderations,
    this.isProfileComplete,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: _str(json['name']),
      dateOfBirth: _str(json['date_of_birth']),
      age: _parseInt(json['age']),
      gender: _str(json['gender']),
      heightCm: _parseDouble(json['height_cm']),
      weightKg: _parseDouble(json['weight_kg']),
      bmi: _parseDouble(json['bmi']),
      primaryGoal: _str(json['primary_goal']),
      dietaryGoal: _str(json['dietary_goal']),
      foodAllergies: _list(json['food_allergies']),
      otherAllergyText: _str(json['other_allergy_text']),
      activityLevel: _str(json['activity_level']),
      preferredWorkouts: _list(json['preferred_workouts']),
      workoutsPerWeek: _parseInt(json['workouts_per_week']),
      daysOff: _list(json['days_off']),
      timezone: _str(json['timezone']),
      currentBuild: _str(json['current_build']),
      healthConsiderations: _list(json['health_considerations']),
      isProfileComplete: json.containsKey('is_profile_complete')
          ? (json['is_profile_complete'] == true)
          : null,
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }

  static List<String>? _list(dynamic v) {
    if (v == null || v is! List) return null;
    final list = v as List<dynamic>;
    if (list.isEmpty) return null;
    return list.map((e) => e.toString()).toList();
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  /// For Firestore: to map with snake_case keys (merge with existing doc).
  Map<String, dynamic> toFirestore() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth;
    if (age != null) map['age'] = age;
    if (gender != null) map['gender'] = gender;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (bmi != null) map['bmi'] = bmi;
    if (primaryGoal != null) map['primary_goal'] = primaryGoal;
    if (dietaryGoal != null) map['dietary_goal'] = dietaryGoal;
    if (foodAllergies != null) map['food_allergies'] = foodAllergies;
    if (otherAllergyText != null) map['other_allergy_text'] = otherAllergyText;
    if (activityLevel != null) map['activity_level'] = activityLevel;
    if (preferredWorkouts != null) map['preferred_workouts'] = preferredWorkouts;
    if (workoutsPerWeek != null) map['workouts_per_week'] = workoutsPerWeek;
    if (daysOff != null) map['days_off'] = daysOff;
    if (timezone != null) map['timezone'] = timezone;
    if (currentBuild != null) map['current_build'] = currentBuild;
    if (healthConsiderations != null) map['health_considerations'] = healthConsiderations;
    if (isProfileComplete != null) map['is_profile_complete'] = isProfileComplete;
    return map;
  }
}

/// PUT/PATCH /profile/basic
class ProfileBasicPayload {
  final String? name;
  final String? dateOfBirth; // YYYY-MM-DD
  final double? heightCm;
  final double? weightKg;
  final String? gender;

  const ProfileBasicPayload({
    this.name,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (gender != null) map['gender'] = gender;
    return map;
  }
}

/// PUT/PATCH /profile/health
class ProfileHealthPayload {
  final List<String>? healthConsiderations;

  const ProfileHealthPayload({this.healthConsiderations});

  Map<String, dynamic> toJson() {
    if (healthConsiderations == null) return {};
    return {'health_considerations': healthConsiderations};
  }
}

/// PUT/PATCH /profile/nutrition
class ProfileNutritionPayload {
  final List<String>? foodAllergies;
  final String? otherAllergyText;
  final String? dietaryGoal;

  const ProfileNutritionPayload({
    this.foodAllergies,
    this.otherAllergyText,
    this.dietaryGoal,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (foodAllergies != null) map['food_allergies'] = foodAllergies;
    if (otherAllergyText != null) map['other_allergy_text'] = otherAllergyText;
    if (dietaryGoal != null) map['dietary_goal'] = dietaryGoal;
    return map;
  }
}

/// PUT/PATCH /profile/activity
class ProfileActivityPayload {
  final String? activityLevel;
  final List<String>? preferredWorkouts;
  final int? workoutsPerWeek;
  final List<String>? daysOff;
  final String? timezone;

  const ProfileActivityPayload({
    this.activityLevel,
    this.preferredWorkouts,
    this.workoutsPerWeek,
    this.daysOff,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (activityLevel != null) map['activity_level'] = activityLevel;
    if (preferredWorkouts != null) map['preferred_workouts'] = preferredWorkouts;
    if (workoutsPerWeek != null) map['workouts_per_week'] = workoutsPerWeek;
    if (daysOff != null) map['days_off'] = daysOff;
    if (timezone != null) map['timezone'] = timezone;
    return map;
  }
}

/// PUT/PATCH /profile/goals
class ProfileGoalsPayload {
  final String? primaryGoal;
  final String? currentBuild;

  const ProfileGoalsPayload({
    this.primaryGoal,
    this.currentBuild,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (primaryGoal != null) map['primary_goal'] = primaryGoal;
    if (currentBuild != null) map['current_build'] = currentBuild;
    return map;
  }
}

/// POST /profile/finish
class ProfileFinishPayload {
  final bool confirm;
  final ProfileConsents consents;

  const ProfileFinishPayload({
    this.confirm = true,
    required this.consents,
  });

  Map<String, dynamic> toJson() {
    return {
      'confirm': confirm,
      'consents': {
        'terms_accepted': consents.termsAccepted,
        'privacy_accepted': consents.privacyAccepted,
        'health_disclaimer_accepted': consents.healthDisclaimerAccepted,
      },
    };
  }
}

class ProfileConsents {
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool healthDisclaimerAccepted;

  const ProfileConsents({
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.healthDisclaimerAccepted,
  });
}

/// Response data from PUT/PATCH profile or finish: { "profile": { ... } }
class ProfileUpdateData {
  final Profile? profile;
  final bool? isProfileComplete;

  const ProfileUpdateData({this.profile, this.isProfileComplete});

  factory ProfileUpdateData.fromJson(Map<String, dynamic> json) {
    Profile? profile;
    if (json['profile'] is Map<String, dynamic>) {
      profile = Profile.fromJson(json['profile'] as Map<String, dynamic>);
    }
    return ProfileUpdateData(
      profile: profile,
      isProfileComplete: json['is_profile_complete'] as bool?,
    );
  }
}
