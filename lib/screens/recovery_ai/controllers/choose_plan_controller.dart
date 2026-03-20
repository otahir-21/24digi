import 'package:get/get.dart';

class ChoosePlanController extends GetxController {
  final List<PlanModel> plans = [
    PlanModel(
      title: "Temporary Plan",
      duration: "3 - 7 days",
      price: "10 AED/month",
      features: [
        "Quick relief protocol",
        "Daily recovery activities",
        "Symptom management",
        "Basic Guid",
      ],
    ),
    PlanModel(
      title: "Permanent Plan",
      duration: "3 - 7 days",
      price: "10 AED/month",
      features: [
        "Quick relief protocol",
        "Daily recovery activities",
        "Symptom management",
        "Basic Guid",
      ],
    ),
  ];

  void selectPlan(PlanModel selectedPlan) {
    for (var plan in plans) {
      plan.isSelected.value = (plan == selectedPlan);
    }
  }

  /// Backend expects plan_type as: "temporary" | "permanent".
  String get selectedPlanType {
    final selected = plans.where((p) => p.isSelected.value).toList();
    if (selected.isEmpty) return 'temp';
    final title = selected.first.title.toLowerCase();
    if (title.contains('permanent')) return 'permanent';
    return 'temp';
  }

  PlanModel? get selectedPlanOrNull {
    for (final p in plans) {
      if (p.isSelected.value) return p;
    }
    return null;
  }

  /// Returns backend plan_type: "temporary" | "permanent"
  /// Returns null when user didn't pick anything yet.
  String? get selectedPlanTypeOrNull {
    final selected = selectedPlanOrNull;
    if (selected == null) return null;
    final title = selected.title.toLowerCase();
    if (title.contains('permanent')) return 'permanent';
    return 'temp';
  }

  /// Backend expects: "temporary" | "permanent"
  String? get selectedPlanBackendTypeOrNull {
    final t = selectedPlanTypeOrNull;
    if (t == null) return null;
    if (t == 'temp') return 'temporary';
    return t;
  }
}

class PlanModel {
  final String title;
  final String duration;
  final String price;
  final List<String> features;
  RxBool isSelected = false.obs;

  PlanModel({
    required this.title,
    required this.duration,
    required this.price,
    required this.features,
  });
}
