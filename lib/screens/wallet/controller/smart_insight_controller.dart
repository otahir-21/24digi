import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SmartInsightController extends GetxController {
  final RxList<AllInsightModel> allInsights = <AllInsightModel>[
    AllInsightModel(
      icon: "assets/icons/tier_icon.png",
      title: "TIER",
      description: "You are 120 pts away from Hero Tier. Keep up the streak!",
      themeColor: Color(0xffFBBF24),
    ),
    AllInsightModel(
      icon: "assets/icons/TrendingUp.png",
      title: "PERFORMANCE",
      description: "Your consistency increased rewards efficiency by 1",
      themeColor: Color(0xff00D4AA),
    ),
    AllInsightModel(
      icon: "assets/icons/clock_icon.png",
      title: "EXPIRY",
      description: "Premium Yoga Mat reward expires in 3 days. Redeem ",
      themeColor: Color(0xffEF4444),
      isExpire: true
    ),
    AllInsightModel(
      icon: "assets/icons/bulb_icon.png",
      title: "INSIGHT",
      description: "Morning workouts earned you 2.3x more points than evening sessions.",
      themeColor: Color(0xff6366F1),
    ),
    AllInsightModel(
      icon: "assets/icons/current_icon.png",
      title: "SUGGESTION",
      description: "Top up 2,500 pts to unlock the Elite Hoodie before stock runs out.",
      themeColor: Color(0xff38BDF8),
    ),
  ].obs;
}

class AllInsightModel {
  final String icon;
  final String title;
  final String description;
  final Color themeColor;
  final bool? isExpire;

  AllInsightModel({
    required this.icon,
    required this.title,
    required this.description,
    required this.themeColor,
    this.isExpire
  });
}
