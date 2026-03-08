import 'package:get/get.dart';
import '../models/recovery_option_model.dart';

class RecoveryAiController extends GetxController {

  final recoveryOptions = [
    RecoveryOptionModel(
      icon: "assets/icons/physical.png",
      title: "PHYSICAL",
      heading: "Sport Recovery",
      description:
      "Optimize physical performance and muscle repair after intense training.",
    ),
    RecoveryOptionModel(
      icon: "assets/icons/Group.png",
      title: "MENTAL",
      heading: "Psychological Recovery",
      description:
      "Enhance cognitive function and reduce stress through mindfulness practices.",
    ),
    RecoveryOptionModel(
      icon: "assets/icons/Vector.png",
      title: "HEALTH",
      heading: "Medical Recovery",
      description:
      "Clinical rehabilitation protocols and biometric health monitoring.",
    ),
  ];
}