import 'package:get/get.dart';

class RecoveryGoalController extends GetxController {
  final List<ChipOption> plansOptions = [
    ChipOption(title: "Recover from injury"),
    ChipOption(title: "Manage Chronic Pain"),
    ChipOption(title: "Improve sleep Quality"),
    ChipOption(title: "Reduce Stress/Anxiety"),
    ChipOption(title: "Post-Surgery Recovery"),
    ChipOption(title: "Improve Energy Level"),
    ChipOption(title: "Overall Wellness"),
  ];

  final List<MainConcernOption> mainConcernOptions = [
    MainConcernOption(title: "Physical Recovery"),
    MainConcernOption(title: "Mental/Emotional Health"),
    MainConcernOption(title: "Sleep issue"),
    MainConcernOption(title: "Energy/ Fatigue"),
    MainConcernOption(title: "Pain management"),
    MainConcernOption(title: "Stress management"),
  ];

  void selectChip(ChipOption chip) {
    for (var item in plansOptions) {
      if (item != chip) item.isSelected.value = false;
    }
    chip.isSelected.toggle();
  }

  void toggleSelection(MainConcernOption option) {
    for (var item in mainConcernOptions) {
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

class MainConcernOption {
  final String title;
  RxBool isSelected;

  MainConcernOption({required this.title, bool initialSelected = false})
      : isSelected = initialSelected.obs;
}
