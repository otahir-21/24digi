import 'package:get/get.dart';

class DataFrontController extends GetxController {
  final severity = 0.obs;
  final List<IssueType> issueType = [
    IssueType(issue: "Muscles Soreness ", icon: "assets/icons/Group 1000001883.png"),
    IssueType(issue: "Muscle Strain", icon: "assets/icons/Group 1000001882.png"),
    IssueType(issue: "Muscle Cramps", icon: "assets/icons/Group 1000001881.png"),
    IssueType(issue: "Joint Pain", icon: "assets/icons/Group (1).png"),
    IssueType(issue: "Exercise fatigue", icon: "assets/icons/Vector (1).png"),
    IssueType(issue: "Minor Sprain", icon: "assets/icons/Mask group.png"),
  ];

  final List<ChipOption> issueDuration = [
    ChipOption(title: "Today"),
    ChipOption(title: "1-2 days ago"),
    ChipOption(title: "3-5 days ago"),
    ChipOption(title: "More then a week ago"),
  ];

  void toggleActivity(IssueType activity) {
    for (var item in issueType) {
      if (item != activity) item.isSelected.value = false;
    }
    activity.isSelected.toggle();
  }

  void selectChip(ChipOption chip) {
    for (var item in issueDuration) {
      if (item != chip) item.isSelected.value = false;
    }
    chip.isSelected.toggle();
  }

}

class IssueType {
  final String issue;
  final String icon;
  RxBool isSelected;

  IssueType({required this.issue, required this.icon, bool initial = false})
      : isSelected = initial.obs;
}

class ChipOption {
  final String title;
  RxBool isSelected;

  ChipOption({required this.title, bool initial = false})
      : isSelected = initial.obs;
}
