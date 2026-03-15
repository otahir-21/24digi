import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletAnalyticsController extends GetxController {
  var selectedPeriodIndex = 0.obs;

  final List<HeroChartData> weeklyStats = <HeroChartData>[
    HeroChartData(day: "MON", earned: 1, spent: 0),
    HeroChartData(day: "TUE", earned: 1, spent: 00),
    HeroChartData(day: "WED", earned: 1, spent: 30),
    HeroChartData(day: "THU", earned: 1, spent: 0),
    HeroChartData(day: "FRI", earned: 1, spent: 0),
    HeroChartData(day: "SAT", earned: 2, spent: 70),
    HeroChartData(day: "SUN", earned: 1, spent: 00),
  ];

  final List<DoughnutData> doughnutStats = <DoughnutData>[
    DoughnutData(
      category: 'Purchase',
      value: 40,
      color: const Color(0xFF00D4AA),
    ),
    DoughnutData(
      category: 'Activity',
      value: 22,
      color: const Color(0xFF6366F1),
    ),
    DoughnutData(category: 'Health', value: 15, color: const Color(0xFF38BDF8)),
    DoughnutData(
      category: 'Challenges',
      value: 13,
      color: const Color(0xFFFBBF24),
    ),
    DoughnutData(
      category: 'Bonuses',
      value: 10,
      color: const Color(0xFFF472B6),
    ),
  ];

  final RxList<ProgressData> progressStats = <ProgressData>[
    ProgressData(
      title: "Purchase Points",
      percentage: 0.40,
      color: const Color(0xFF00D4AA),
    ),
    ProgressData(
      title: "Earned from Activity",
      percentage: 0.35,
      color: const Color(0xFF6366F1),
    ),
    ProgressData(
      title: "Bonuses & Rewards",
      percentage: 0.25,
      color: const Color(0xFFFBBF24),
    ),
  ].obs;

  final RxList<AnalyticsData> analyticsData = <AnalyticsData>[
    AnalyticsData(
      icon: "assets/icons/TrendingUp.png",
      points: "+420",
      description: "Earned this week",
      themeColor: const Color(0xFF00D4AA),
    ),
    AnalyticsData(
      icon: "assets/icons/TrendingUp.png",
      points: "+420",
      description: "Earned this week",
      themeColor: const Color(0xFF6366F1),
    ),
    AnalyticsData(
      icon: "assets/icons/TrendingUp.png",
      points: "+420",
      description: "Earned this week",
      themeColor: const Color(0xFF38BDF8),
    ),
    AnalyticsData(
      icon: "assets/icons/TrendingUp.png",
      points: "+420",
      description: "Earned this week",
      themeColor: const Color(0xFFF472B6),
    ),
  ].obs;

  void updatePeriod(int index) {
    selectedPeriodIndex.value = index;
  }
}

class HeroChartData {
  final String day;
  final double earned;
  final double spent;

  HeroChartData({required this.day, required this.earned, required this.spent});
}

class DoughnutData {
  final String category;
  final double value;
  final Color color;

  DoughnutData({
    required this.category,
    required this.value,
    required this.color,
  });
}

class ProgressData {
  final String title;
  final double percentage; // value between 0.0 and 1.0
  final Color color;

  ProgressData({
    required this.title,
    required this.percentage,
    required this.color,
  });
}

class AnalyticsData {
  final String? icon;
  final String points; // value between 0.0 and 1.0
  final String description;
  final Color themeColor;

  AnalyticsData({
    required this.icon,
    required this.points,
    required this.description,
    required this.themeColor
  });
}
