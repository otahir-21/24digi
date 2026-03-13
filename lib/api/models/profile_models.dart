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

  // Additional fields for profile integration
  final String? bio;
  final String? profileImage;
  final bool? notificationsEnabled;
  final bool? emailNotificationsEnabled;
  final bool? activityRemindersEnabled;
  final bool? hydrationRemindersEnabled;
  final bool? sleepRemindersEnabled;
  final bool? weeklySummaryEnabled;
  final bool? quietHoursEnabled;
  final String? theme;
  final String? preferredDistanceUnit; // 'km' or 'miles'
  final String? preferredWeightUnit; // 'kg' or 'lbs'
  final String? preferredTempUnit; // '°C' or '°F'
  final bool? alarmEnabled;
  final bool? reminderEnabled;
  
  // Health stats
  final double? targetWeight;
  final String? bloodType;
  final bool? faceIdEnabled;
  final bool? appLockEnabled;
  final bool? hapticEnabled;
  final bool? animationsEnabled;
  final String? dateFormat;
  final String? timeFormat;
  final String? language;

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
    this.bio,
    this.profileImage,
    this.notificationsEnabled,
    this.emailNotificationsEnabled,
    this.activityRemindersEnabled,
    this.hydrationRemindersEnabled,
    this.sleepRemindersEnabled,
    this.weeklySummaryEnabled,
    this.quietHoursEnabled,
    this.theme,
    this.preferredDistanceUnit,
    this.preferredWeightUnit,
    this.preferredTempUnit,
    this.alarmEnabled,
    this.reminderEnabled,
    this.targetWeight,
    this.bloodType,
    this.faceIdEnabled,
    this.appLockEnabled,
    this.hapticEnabled,
    this.animationsEnabled,
    this.dateFormat,
    this.timeFormat,
    this.language,
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
      bio: _str(json['bio']),
      profileImage: _str(json['profile_image']),
      notificationsEnabled: _bool(json['notifications_enabled']),
      emailNotificationsEnabled: _bool(json['email_notifications_enabled']),
      activityRemindersEnabled: _bool(json['activity_reminders_enabled']),
      hydrationRemindersEnabled: _bool(json['hydration_reminders_enabled']),
      sleepRemindersEnabled: _bool(json['sleep_reminders_enabled']),
      weeklySummaryEnabled: _bool(json['weekly_summary_enabled']),
      quietHoursEnabled: _bool(json['quiet_hours_enabled']),
      theme: _str(json['theme']),
      preferredDistanceUnit: _str(json['preferred_distance_unit']),
      preferredWeightUnit: _str(json['preferred_weight_unit']),
      preferredTempUnit: _str(json['preferred_temp_unit']),
      alarmEnabled: _bool(json['alarm_enabled']),
      reminderEnabled: _bool(json['reminder_enabled']),
      targetWeight: _parseDouble(json['target_weight']),
      bloodType: _str(json['blood_type']),
      faceIdEnabled: _bool(json['face_id_enabled']),
      appLockEnabled: _bool(json['app_lock_enabled']),
      hapticEnabled: _bool(json['haptic_enabled']),
      animationsEnabled: _bool(json['animations_enabled']),
      dateFormat: _str(json['date_format']),
      timeFormat: _str(json['time_format']),
      language: _str(json['language']),
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

  static bool? _bool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v.toLowerCase() == 'true';
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
    
    if (bio != null) map['bio'] = bio;
    if (profileImage != null) map['profile_image'] = profileImage;
    if (notificationsEnabled != null) map['notifications_enabled'] = notificationsEnabled;
    if (emailNotificationsEnabled != null) map['email_notifications_enabled'] = emailNotificationsEnabled;
    if (activityRemindersEnabled != null) map['activity_reminders_enabled'] = activityRemindersEnabled;
    if (hydrationRemindersEnabled != null) map['hydration_reminders_enabled'] = hydrationRemindersEnabled;
    if (sleepRemindersEnabled != null) map['sleep_reminders_enabled'] = sleepRemindersEnabled;
    if (weeklySummaryEnabled != null) map['weekly_summary_enabled'] = weeklySummaryEnabled;
    if (quietHoursEnabled != null) map['quiet_hours_enabled'] = quietHoursEnabled;
    if (theme != null) map['theme'] = theme;
    if (preferredDistanceUnit != null) map['preferred_distance_unit'] = preferredDistanceUnit;
    if (preferredWeightUnit != null) map['preferred_weight_unit'] = preferredWeightUnit;
    if (preferredTempUnit != null) map['preferred_temp_unit'] = preferredTempUnit;
    if (alarmEnabled != null) map['alarm_enabled'] = alarmEnabled;
    if (reminderEnabled != null) map['reminder_enabled'] = reminderEnabled;
    if (targetWeight != null) map['target_weight'] = targetWeight;
    if (bloodType != null) map['blood_type'] = bloodType;
    if (faceIdEnabled != null) map['face_id_enabled'] = faceIdEnabled;
    if (appLockEnabled != null) map['app_lock_enabled'] = appLockEnabled;
    if (hapticEnabled != null) map['haptic_enabled'] = hapticEnabled;
    if (animationsEnabled != null) map['animations_enabled'] = animationsEnabled;
    if (dateFormat != null) map['date_format'] = dateFormat;
    if (timeFormat != null) map['time_format'] = timeFormat;
    if (language != null) map['language'] = language;
    
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
  final String? bio;
  final String? profileImage;

  const ProfileBasicPayload({
    this.name,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.gender,
    this.bio,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (dateOfBirth != null) map['date_of_birth'] = dateOfBirth;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (gender != null) map['gender'] = gender;
    if (bio != null) map['bio'] = bio;
    if (profileImage != null) map['profile_image'] = profileImage;
    return map;
  }
}

/// PUT/PATCH /profile/health
class ProfileHealthPayload {
  final List<String>? healthConsiderations;
  final double? heightCm;
  final double? weightKg;
  final double? targetWeight;
  final String? bloodType;

  const ProfileHealthPayload({
    this.healthConsiderations,
    this.heightCm,
    this.weightKg,
    this.targetWeight,
    this.bloodType,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (healthConsiderations != null) map['health_considerations'] = healthConsiderations;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (targetWeight != null) map['target_weight'] = targetWeight;
    if (bloodType != null) map['blood_type'] = bloodType;
    return map;
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
