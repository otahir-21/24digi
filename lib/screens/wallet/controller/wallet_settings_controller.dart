import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletSettingsController extends GetxController {
  var autoRenewEnabled = true.obs;

  final RxList<CardContentModel> securityAndVerification = <CardContentModel>[
    CardContentModel(
      icon: "assets/icons/verifiedd.png",
      title: "Transaction Verification Log",
      description: "All transaction verified",
      themeColor: Color(0xff00D4AA),
      status: "Active",
    ),
    CardContentModel(
      icon: "assets/icons/v_icon.png",
      title: "Anti-Abuse Status",
      description: "Fair-play verified - no flag",
      themeColor: Color(0xff00D4AA),
      status: 'Active',
    ),
    CardContentModel(
      icon: "assets/icons/bio.png",
      title: "Biometric Lock",
      description: "Face ID/ Fingerprint enabled ",
      themeColor: Color(0xff6366F1),
      status: 'Active',
    ),
    CardContentModel(
      icon: "assets/icons/bio.png",
      title: "PIN Security",
      description: "6-Digit PIN configured",
      themeColor: Color(0xff6366F1),
      status: 'Active',
    ),
  ].obs;

  final RxList<CardContentModel> paymentMethod = <CardContentModel>[
    CardContentModel(
      icon: "assets/icons/verifiedd.png",
      title: "Visa • 4892",
      description: "Default payment method • Exp 09/27",
      themeColor: Color(0xff5B5FC7),
      status: "Connected",
    ),
    CardContentModel(
      icon: "assets/icons/v_icon.png",
      title: "Mastercard • 7731",
      description: "Backup method • Exp 03/28",
      themeColor: Color(0xffEB001B),
      status: 'Connected',
    ),
    CardContentModel(
      icon: "assets/icons/bio.png",
      title: "Apple pay",
      description: "Connected",
      themeColor: Color(0xff8888A0),

      status: 'Connected',
    ),
  ].obs;

  final RxList<CardContentModel> transparency = <CardContentModel>[
    CardContentModel(
      icon: "assets/icons/verifiedd.png",
      title: "Points Rules & Pricing",
      description: "How points work and their value",
      themeColor: Color(0xffFBBF24),
    ),
    CardContentModel(
      icon: "assets/icons/v_icon.png",
      title: "Data Usage Policy",
      description: "What data we use and why",
      themeColor: Color(0xff38BDF8),
    ),
    CardContentModel(
      icon: "assets/icons/bio.png",
      title: "Term and Conditions",
      description: "Legal terms for point purchase",
      themeColor: Color(0xff8888A0),
    ),
    CardContentModel(
      icon: "assets/icons/bio.png",
      title: "Refund Policy",
      description: "Point purchase refund guidelines",
      themeColor: Color(0xff8888A0),
    ),
  ].obs;

  final RxList<CardContentModel> connectedSystems = <CardContentModel>[
    CardContentModel(
      icon: "assets/icons/verifiedd.png",
      title: "Smart Wearables",
      description: "Apple watch - connected",
      themeColor: Color(0xff00D4AA),
      status: "Connected",
    ),
    CardContentModel(
      icon: "assets/icons/v_icon.png",
      title: "Health App",
      description: "Apple Health - Synced",
      themeColor: Color(0xff00D4AA),
      status: "Connected",
    ),
    CardContentModel(
      icon: "assets/icons/bio.png",
      title: "24SHOP Account",
      description: "Linked",
      themeColor: Color(0xffF472B6),
      status: "Connected",
    ),
  ].obs;

  final RxList<CardContentModel> notification = <CardContentModel>[
    CardContentModel(
      icon: "assets/icons/notification.png",
      title: "Purchase Confirmation",
      description: "Instant top-up notifications",
      themeColor: Color(0xff00D4AA),
      status: "Connected",
      toggle: true.obs
    ),
    CardContentModel(
      icon: "assets/icons/notification.png",
      title: "Smart Insight",
      description: "AI-powered wallet notifications",
      themeColor: Color(0xff00D4AA),
      status: "Connected",
        toggle: true.obs
    ),
    CardContentModel(
      icon: "assets/icons/notification.png",
      title: "Earning Alerts",
      description: "Get notification when you earn point",
      themeColor: Color(0xffF472B6),
      status: "Connected",
        toggle: true.obs
    ),
  ].obs;

  void toggleNotifications(bool v, int index) {
    notification[index].toggle!.value = v;
    // debugPrint("Toggle is now: ${autoRenewEnabled.value}");
  }
}

class CardContentModel {
  final String icon;
  final String title;
  final String description;
  final Color themeColor;
  final String? status;
  final RxBool? toggle;

  CardContentModel( {
    required this.icon,
    required this.title,
    required this.description,
    required this.themeColor,
    this.status,
    this.toggle
  });
}
// class CardContentModel {
//   final String icon;
//   final String title;
//   final String description;
//   final Color themeColor;
//   final String? status;
//
//   CardContentModel({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.themeColor,
//     this.status,
//   });
// }
