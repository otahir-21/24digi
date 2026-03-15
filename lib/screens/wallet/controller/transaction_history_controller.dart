import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TransactionHistoryController extends GetxController {
  var selectedCategory = "All".obs;

  final RxList<TransactionModel> transactions = <TransactionModel>[
    TransactionModel(
      title: "Top Up",
      description: "Feb 27, 04:00",
      points: "+2500",
      prefixIcon: "assets/icons/topUp.png",
      iconBgColor: const Color(0xff00D4AA).withValues(alpha: 0.12),
      status: "Verified",
    ),
    TransactionModel(
      title: "Daily Activity",
      description: "Feb 27, 04:00",
      points: "+85",
      prefixIcon: "assets/icons/graph.png",
      iconBgColor: const Color(0xff00D4AA).withValues(alpha: 0.12),
      status: "Verified",
    ),
    TransactionModel(
      title: "Challenge Reward",
      description: "Feb 27, 04:00",
      points: "+120",
      prefixIcon: "assets/icons/cup.png",
      iconBgColor: const Color(0xffFBBF24).withValues(alpha: 0.12),
      status: "Verified",
    ),
    TransactionModel(
      title: "AI Bonus",
      description: "Feb 27, 04:00",
      points: "-300",
      prefixIcon: "assets/icons/mind.png",
      iconBgColor: const Color(0xff6366F1).withValues(alpha: 0.12),
      status: "Verified",
    ),
    TransactionModel(
      title: "Challenge Reward",
      description: "Feb 27, 04:00",
      points: "+120",
      prefixIcon: "assets/icons/cup.png",
      iconBgColor: const Color(0xffFBBF24).withValues(alpha: 0.12),
      status: "Verified",
    ),
  ].obs;

  final List<String> categories = [
    "All",
    "Top Up",
    "Earned",
    "Spent",
    "Bonuses"
  ];

  void selectCategory(String category) {
    selectedCategory.value = category;
  }
}

class TransactionModel {
  final String title;
  final String description;
  final String points;
  final String prefixIcon;
  final Color iconBgColor;
  final String? status;

  TransactionModel({
    required this.title,
    required this.description,
    required this.points,
    required this.prefixIcon,
    required this.iconBgColor,
    this.status,
  });
}