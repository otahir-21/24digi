import 'package:get/get.dart';

class RecoveryPlanController extends GetxController {
  final List<RecoveryDayModel> recoveryPlan = [
    RecoveryDayModel(
      dayTitle: "Day 1: Initial relief and rest",
      goal: "Reduce initial soreness",
      benefits: [
        "Improved blood flow",
        "Reduced inflammation",
        "Muscle relaxation",
      ],
    ),
    RecoveryDayModel(
      dayTitle: "Day 2: Mobility focus",
      goal: "Increase range of motion",
      benefits: [
        "Joint lubrication",
        "Flexibility increase",
        "Enhanced tissue repair",
      ],
    ),
    RecoveryDayModel(
      dayTitle: "Day 3: Strengthening",
      goal: "Build stability",
      benefits: [
        "Muscle fiber activation",
        "Improved coordination",
      ],
    ),
  ];

  final List<ChipOption> recoveryCategory = [
    ChipOption(title: "Sport Recovery"),
    ChipOption(title: "Temporary"),
    ChipOption(title: "4 Days"),
  ];

  void selectChip(ChipOption chip) {
    for (var item in recoveryCategory) {
      if (item != chip) item.isSelected.value = false;
    }
    chip.isSelected.toggle();
  }
 final String description = "This plan focuses on gentle neck mobility exercises, relaxation techniques, and anti-inflammatory nutrition to alleviate soreness and promote while healing. Progressively increase activity while monitoring pain levels.";
}
class RecoveryDayModel {
  final String dayTitle;
  final String goal;
  final List<String> benefits;

  RecoveryDayModel({
    required this.dayTitle,
    required this.goal,
    required this.benefits,
  });
}


class ChipOption {
  final String title;
  RxBool isSelected;

  ChipOption({required this.title, bool initial = false})
      : isSelected = initial.obs;
}
