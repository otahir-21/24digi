import 'package:get/get.dart';

class OnboardingActivityController extends GetxController {
  final List<SelectionOption> activeLevelOptions = [
    SelectionOption(
      title: "Mostly Active",
      description: '"Little planned movement"',
      icon: "assets/icons/mostly_active.png",
    ),
    SelectionOption(
      title: "Lightly Active",
      description: '"Some walking or light activity"',
      icon: "assets/icons/lightly_active.png",
    ),
    SelectionOption(
      title: "Moderately Active",
      description: '"Exercise or sports few time a week"',
      icon: "assets/icons/moderate_active.png",
    ),
    SelectionOption(
      title: "Very Active",
      description: '"Training, Sports, or intense activity most days"',
      icon: "assets/icons/very_active.png",
    ),
  ];

  final List<ActivityOption> activities = [
    ActivityOption(title: "Walking/Light movement ", icon: "assets/icons/lightly_active.png"),
    ActivityOption(title: "Strength training", icon: "assets/icons/Icon.png"),
    ActivityOption(title: "Cardio workout", icon: "assets/icons/Icon1.png"),
    ActivityOption(title: "Sports", icon: "assets/icons/Icon2.png"),
    ActivityOption(title: "Yoga/ stretching", icon: "assets/icons/Icon4.png"),
    ActivityOption(title: "At-Home Workouts", icon: "assets/icons/Icon3.png"),
    ActivityOption(title: "Gym Workout", icon: "assets/icons/Icon5.png"),
    ActivityOption(title: "No Preferences / not sure", icon: "assets/icons/Icon6.png"),
  ];

  void toggleActivity(ActivityOption activity) {
    // If you want single selection:
    for (var item in activities) {
      if (item != activity) item.isSelected.value = false;
    }
    activity.isSelected.toggle();
  }

  void toggleSelection(SelectionOption option) {
    for (var item in activeLevelOptions) {
      if (item != option) item.isSelected.value = false;
    }
    option.isSelected.toggle();
  }
}

class ActivityOption {
  final String title;
  final String icon;
  RxBool isSelected;

  ActivityOption({required this.title, required this.icon, bool initial = false})
      : isSelected = initial.obs;
}



class SelectionOption {
  final String title;
  final String description;
  final String icon;
  RxBool isSelected;

  SelectionOption({
    required this.title,
    required this.description,
    required this.icon,
    bool initialSelected = false,
  }) : isSelected = initialSelected.obs;
}
