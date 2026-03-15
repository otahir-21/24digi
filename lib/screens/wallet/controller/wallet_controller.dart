import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletController extends GetxController {
  final RxList<ActivityModel> activities = <ActivityModel>[
    ActivityModel(
      title: "Top Up",
      description: "Purchased 2,500 points via Visa •4892",
      points: "+2500",
      prefixIcon: "assets/icons/topUp.png",
      iconBgColor: const Color(0xff00D4AA).withValues(alpha: 0.12),
      status: "Verified",
    ),
    ActivityModel(
      title: "Daily Activity",
      description: "Complete 10,000 steps daily goal",
      points: "+85",
      prefixIcon: "assets/icons/graph.png",
      iconBgColor: const Color(0xff00D4AA).withValues(alpha: 0.12),
      status: "Verified",
    ),
    ActivityModel(
      title: "Challenge Reward",
      description: "7-day workout streak completed",
      points: "+120",
      prefixIcon: "assets/icons/cup.png",
      iconBgColor: const Color(0xffFBBF24).withValues(alpha: 0.12),
      status: "Verified",
    ),
    ActivityModel(
      title: "AI Bonus",
      description: "Consistency multiplier applied to morning",
      points: "-300",
      prefixIcon: "assets/icons/mind.png",
      iconBgColor: const Color(0xff6366F1).withValues(alpha: 0.12),
      status: "Verified",
    ),
    ActivityModel(
      title: "Challenge Reward",
      description: "7-day workout streak completed",
      points: "+120",
      prefixIcon: "assets/icons/cup.png",
      iconBgColor: const Color(0xffFBBF24).withValues(alpha: 0.12),
      status: "Verified",
    ),
  ].obs;

  final RxList<InsightModel> insights = <InsightModel>[
    InsightModel(
      title: 'TIER',
      description: "You are 120 pts away from Hero Tier. Keep up the streak!",
      themeColor: const Color(0xffFBBF24),
    ),
    InsightModel(
      title: 'TIER',
      description: "You've maintained a 5-day streak! Don't stop now.",
      themeColor: const Color(0xff00D4AA),
    ),
  ].obs;
}

class ActivityModel {
  final String title;
  final String description;
  final String points;
  final String prefixIcon;
  final Color iconBgColor;
  final String? status;

  ActivityModel({
    required this.title,
    required this.description,
    required this.points,
    required this.prefixIcon,
    required this.iconBgColor,
    this.status,
  });
}


class InsightModel {
  final String title;
  final String description;
  final Color themeColor;

  InsightModel({
    required this.title,
    required this.description,
    required this.themeColor
  });
}
