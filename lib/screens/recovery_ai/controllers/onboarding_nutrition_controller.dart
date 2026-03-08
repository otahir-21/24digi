import 'package:get/get.dart';

class OnboardingNutritionController extends GetxController {
  final List<ChipOption> allergiesOptions = [
    ChipOption(title: "None"),
    ChipOption(title: "Dairy"),
    ChipOption(title: "Eggs"),
    ChipOption(title: "Gluten"),
    ChipOption(title: "Shellfish"),
    ChipOption(title: "Soy"),
    ChipOption(title: "Sesame"),
    ChipOption(title: "Fish"),
  ];

  final List<SelectionOption> dietaryOptions = [
    SelectionOption(title: "Balanced"),
    SelectionOption(title: "High-Protein"),
    SelectionOption(title: "Vegan"),
    SelectionOption(title: "Light and fresh"),
  ];

  void selectChip(ChipOption chip) {
    for (var item in allergiesOptions) {
      if (item != chip) item.isSelected.value = false;
    }
    chip.isSelected.toggle();
  }

  void toggleSelection(SelectionOption option) {
    for (var item in dietaryOptions) {
      if (item != option) item.isSelected.value = false;
    }
    option.isSelected.toggle();
  }
}

class ChipOption {
  final String title;
  RxBool isSelected;

  ChipOption({required this.title, bool initial = false})
      : isSelected = initial.obs;
}

class SelectionOption {
  final String title;
  RxBool isSelected; // Individual state for each item

  SelectionOption({required this.title, bool initialSelected = false})
      : isSelected = initialSelected.obs;
}
