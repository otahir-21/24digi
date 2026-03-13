import 'package:get/get.dart';

class TodayGoalController extends GetxController {
  var energyLevel = 0.obs;
  var painLevel = 0.obs;

  final List<String> statusOptions = ["Low", "Ok", "Great"];
  final List<String> feelingsOptions = ["Better", "Same", "Worse"];

  var selectedStatus = "Low".obs;
  var selectedFeeling = "Better".obs;

  void updateStatus(String value) {
    selectedStatus.value = value;
  }

  void updateFeeling(String value) {
    selectedFeeling.value = value;
  }

  void selectEnergy(int index) {
    energyLevel.value = index;
  }

  void selectPain(int index) {
    painLevel.value = index;
  }

  String activities =
      "Exercise: Neck tilts\n"
      "Practise: Breathing\n"
      "Food: Turmeric-spiced oatmeal\n"
      "Sleep Optimization: Use a supportive pillow to maintain neck alignment";

  String symptomManagement = "Use ice pack on the shoulder for 15 minutes every hour";

  String whatToAvoid = "Heavy Lifting\nOverhead activities";
}