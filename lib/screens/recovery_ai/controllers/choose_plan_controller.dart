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
