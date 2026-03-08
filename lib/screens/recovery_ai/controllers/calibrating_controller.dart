import 'package:get/get.dart';

class CalibratingController extends GetxController {
  final List<SelectionOption> mobilityOptions = [
    SelectionOption(
      title: "Fully Active",
      description: "No limitation",
      icon: "assets/icons/mostly_active.png",
    ),
    SelectionOption(
      title: "Limited Mobility",
      description: 'Some difficulty with movement',
      icon: "assets/icons/lightly_active.png",
    ),
    SelectionOption(
      title: "Restricted Mobility",
      description: 'Significant difficulty, may use aids',
      icon: "assets/icons/moderate_active.png",
    ),
    SelectionOption(
      title: "Wheelchair User",
      description: 'Uses a wheel chair',
      icon: "assets/icons/very_active.png",
    ),
    SelectionOption(
      title: "Bedridden/ Recovering",
      description: 'Bed rest or post surgery recovery',
      icon: "assets/icons/very_active.png",
    ),
  ];

  final List<SelectionOption> dailyActivityOptions = [
    SelectionOption(
      title: "Sedentary",
      description: "Mostly sitting or lying down",
      icon: "assets/icons/mostly_active.png",
    ),
    SelectionOption(
      title: "Light Activity",
      description: 'Occasional walking or standing',
      icon: "assets/icons/lightly_active.png",
    ),
    SelectionOption(
      title: "Moderate Activity",
      description: 'Regular movement through the day',
      icon: "assets/icons/moderate_active.png",
    ),
  ];

  void toggleSelection(SelectionOption option) {
    for (var item in mobilityOptions) {
      if (item != option) item.isSelected.value = false;
    }
    option.isSelected.toggle();
  }
  void toggleActivityLevel(SelectionOption option) {
    for (var item in dailyActivityOptions) {
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
