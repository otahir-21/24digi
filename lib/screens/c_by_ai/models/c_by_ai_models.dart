double _toDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

int _toInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class MealModel {
  final String type; // "breakfast"/"lunch"/"dinner"/"snack"
  final String name;
  final String time; // "07:00", fallback by type below
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
    // Fallback times by meal type
    final timeFallbacks = {
      'coffee': '06:30',
      'breakfast': '08:00',
      'lunch': '13:00',
      'snack': '16:00',
      'dinner': '19:00',
      'dessert': '20:30',
    };
    final type = json['type']?.toString() ?? 'meal';

    final ingredients = (json['ingredients'] as List<dynamic>? ?? [])
        .map((i) => IngredientModel.fromJson(i))
        .toList();
    final sauces = (json['sauces'] as List<dynamic>? ?? [])
        .map((i) => IngredientModel.fromJson(i))
        .toList();

    double totalCal = _toDouble(json['total_cal']);
    double totalProtein = _toDouble(json['total_protein']);
    double totalCarbs = _toDouble(json['total_carbs']);
    double totalFat = _toDouble(json['total_fat']);
    double totalPrice = _toDouble(json['total_price']);

    // If totals are missing, calculate from ingredients
    if (totalProtein == 0 && totalCarbs == 0 && totalFat == 0) {
      for (var ing in ingredients) {
        totalCal += totalCal == 0 ? ing.cal : 0; // Only add if root cal was 0
        totalProtein += ing.protein;
        totalCarbs += ing.carbs;
        totalFat += ing.fat;
        totalPrice += totalPrice == 0 ? ing.price : 0;
      }
      for (var sauce in sauces) {
        totalProtein += sauce.protein;
        totalCarbs += sauce.carbs;
        totalFat += sauce.fat;
      }
    }

    return MealModel(
      type: type,
      name: json['name']?.toString() ?? 'Meal',
      time: json['time']?.toString() ?? timeFallbacks[type] ?? '12:00',
      instructions: json['instructions']?.toString() ?? 'Prepare as directed.',
      ingredients: ingredients,
      sauces: sauces,
      totalCal: totalCal,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      totalPrice: totalPrice,
    );
  }
}

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

  factory IngredientModel.fromJson(Map<String, dynamic> json) =>
      IngredientModel(
        name: json['name']?.toString() ?? '',
        amount: json['amount']?.toString() ?? '',
        cal: _toDouble(json['cal']),
        protein: _toDouble(json['protein']),
        carbs: _toDouble(json['carbs']),
        fat: _toDouble(json['fat']),
        price: _toDouble(json['price']),
      );
}

class DailyTotalModel {
  final double calories, protein, carbs, fat, price;

  DailyTotalModel({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.price,
  });

  factory DailyTotalModel.fromJson(Map<String, dynamic> json) =>
      DailyTotalModel(
        calories: _toDouble(json['calories']),
        protein: _toDouble(json['protein']),
        carbs: _toDouble(json['carbs']),
        fat: _toDouble(json['fat']),
        price: _toDouble(json['price']),
      );
}

class MealSummaryModel {
  final int totalDays, totalMeals;
  final double totalCalories, totalProtein, totalCarbs, totalFat, totalPrice;

  MealSummaryModel({
    required this.totalDays,
    required this.totalMeals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.totalPrice,
  });

  factory MealSummaryModel.fromJson(Map<String, dynamic> json) =>
      MealSummaryModel(
        totalDays: _toInt(json['total_days'], 7),
        totalMeals: _toInt(json['total_meals']),
        totalCalories: _toDouble(json['total_calories']),
        totalProtein: _toDouble(json['total_protein']),
        totalCarbs: _toDouble(json['total_carbs']),
        totalFat: _toDouble(json['total_fat']),
        totalPrice: _toDouble(json['total_price']),
      );
}

class FitnessMetricsModel {
  final double bmi, bodyFat, bmr, tdee;
  final String bmiOverview, goal, goalExplanation;

  FitnessMetricsModel({
    required this.bmi,
    required this.bodyFat,
    required this.bmr,
    required this.tdee,
    required this.bmiOverview,
    required this.goal,
    required this.goalExplanation,
  });
}
