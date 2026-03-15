class IngredientModel {
  final String name;
  final String amount;
  final double cal;
  final double protein;
  final double carbs;
  final double fat;
  final double price;

  IngredientModel({
    required this.name,
    required this.amount,
    required this.cal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.price,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      name: json['name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      cal: (json['cal'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class MealModel {
  final String type;
  final String name;
  final String time;
  final String instructions;
  final List<IngredientModel> ingredients;
  final List<IngredientModel> sauces;
  final double totalCal;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalPrice;

  MealModel({
    required this.type,
    required this.name,
    required this.time,
    required this.instructions,
    required this.ingredients,
    required this.sauces,
    required this.totalCal,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalPrice,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sauces: (json['sauces'] as List<dynamic>?)
              ?.map((e) => IngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCal: (json['total_cal'] ?? 0).toDouble(),
      totalProtein: (json['total_protein'] ?? 0).toDouble(),
      totalCarbs: (json['total_carbs'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}

class DailyTotalModel {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double price;

  DailyTotalModel({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.price,
  });

  factory DailyTotalModel.fromJson(Map<String, dynamic> json) {
    return DailyTotalModel(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class MealSummaryModel {
  final int totalDays;
  final int totalMeals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double totalPrice;

  MealSummaryModel({
    required this.totalDays,
    required this.totalMeals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalPrice,
  });

  factory MealSummaryModel.fromJson(Map<String, dynamic> json) {
    return MealSummaryModel(
      totalDays: json['total_days'] ?? 0,
      totalMeals: json['total_meals'] ?? 0,
      totalCalories: (json['total_calories'] ?? 0).toDouble(),
      totalProtein: (json['total_protein'] ?? 0).toDouble(),
      totalCarbs: (json['total_carbs'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}

class FitnessMetricsModel {
  final double bmi;
  final double bodyFat;
  final double bmr;
  final double tdee;
  final String bmiOverview;
  final String goal;
  final String goalExplanation;

  FitnessMetricsModel({
    required this.bmi,
    required this.bodyFat,
    required this.bmr,
    required this.tdee,
    required this.bmiOverview,
    required this.goal,
    required this.goalExplanation,
  });

  factory FitnessMetricsModel.fromJson(Map<String, dynamic> json) {
    return FitnessMetricsModel(
      bmi: (json['bmi'] ?? 0).toDouble(),
      bodyFat: (json['body_fat'] ?? 0).toDouble(),
      bmr: (json['bmr'] ?? 0).toDouble(),
      tdee: (json['tdee'] ?? 0).toDouble(),
      bmiOverview: json['bmi_overview']?.toString() ?? '',
      goal: json['goal']?.toString() ?? '',
      goalExplanation: json['goal_explanation']?.toString() ?? '',
    );
  }
}
