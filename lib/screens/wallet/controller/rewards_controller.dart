import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardsController extends GetxController {
  final String points = "12,874";
  final String aed = "12,874";
  var selectedCategory = "All".obs;

  final List<String> categories = [
    "All",
    "Gear",
    "Apparel",
    "Digital",
    "Experience",
  ];

  final RxList<RewardModel> rewardsList = <RewardModel>[
    RewardModel(
      title: "Premium Yoga Mat",
      description: "Eco-Friendly anti-slip premium yoga mat",
      points: "2,500",
      category: "Silver +",
      iconBgColor: const Color(0xffF472B6).withValues(alpha: 0.12),
      daysLeft: "23 left",
    ),
    RewardModel(
      title: "24DIGI Elite Hoodie",
      description: "Limited edition wellness lifestyle hoodie",
      points: "4,000",
      category: "Elite",
      iconBgColor: const Color(0xffF472B6).withValues(alpha: 0.12),
      daysLeft: "23 left",
      // No daysLeft provided (Optional)
    ),
    RewardModel(
      title: "1-Month AI Coach Pro",
      description: "Unlock advanced AI coaching features",
      points: "1,500",
      category: "Bronze+",
      iconBgColor: const Color(0xff6366F1).withValues(alpha: 0.12),
    ),
    RewardModel(
      title: "Premium Yoga Mat",
      description: "Eco-Friendly anti-slip premium yoga mat",
      points: "2,500",
      category: "Silver +",
      iconBgColor: const Color(0xffF472B6).withValues(alpha: 0.12),
      daysLeft: "23 left",
    ),
    RewardModel(
      title: "24DIGI Elite Hoodie",
      description: "Limited edition wellness lifestyle hoodie",
      points: "4,000",
      category: "Elite",
      iconBgColor: const Color(0xffF472B6).withValues(alpha: 0.12),
      daysLeft: "23 left",
      // No daysLeft provided (Optional)
    ),
    RewardModel(
      title: "1-Month AI Coach Pro",
      description: "Unlock advanced AI coaching features",
      points: "1,500",
      category: "Bronze+",
      iconBgColor: const Color(0xff6366F1).withValues(alpha: 0.12),
    ),
  ].obs;

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}

class RewardModel {
  final String title;
  final String description;
  final String points;
  final String category;
  final Color iconBgColor;
  final String? daysLeft; // Optional field

  RewardModel({
    required this.title,
    required this.description,
    required this.points,
    required this.category,
    required this.iconBgColor,
    this.daysLeft,
  });
}
