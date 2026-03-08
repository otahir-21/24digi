import 'package:get/get.dart';

class OnboardingHealthController extends GetxController {
  final List<SelectionOption> options = [
    SelectionOption(title: "Health Condition"),
    SelectionOption(title: "Blood Pressure Concern"),
    SelectionOption(title: "Breathing or Lungs"),
    SelectionOption(title: "Sleep and Recovery"),
    SelectionOption(title: "Blood Sugar and metabolism"),
    SelectionOption(title: "None/Prefer not to say")
  ];

  void toggleSelection(SelectionOption option) {
    // If you want ONLY ONE selected at a time:
    for (var item in options) {
      if (item != option) item.isSelected.value = false;
    }

    // Toggle the clicked one
    option.isSelected.toggle();
  }
}

class SelectionOption {
  final String title;
  RxBool isSelected; // Individual state for each item

  SelectionOption({required this.title, bool initialSelected = false})
      : isSelected = initialSelected.obs;
}


