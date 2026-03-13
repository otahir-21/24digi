import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeroProfileController extends GetxController {
  final String profileImage = "assets/images/hero.png";
  final String name = "Khalfan";
  final String title = "THE ARCHITECT OF DISCIPLINE";
  final String award = "Hall of Fame Inductee • Jan 2025";
  final String legacySummary =
      "“Khalfan redefined the boundaries of 24DIGI. Maintaining a perfect streak of 365 days. A pillar of mental serves as the foundational blueprint for the Discipline Protocol.";

  final RxList<CompetitionModel> competitions = <CompetitionModel>[
    CompetitionModel(
      name: "Competition Name",
      image: "assets/icons/comp1.png",
      color: Color(0xffCB9D5D),
    ),
    CompetitionModel(
      name: "Competition Name A",
      image: "assets/images/comp2.png",
      color: Color(0xff6F7A84),
    ),
    CompetitionModel(
      name: "Competition Name B",
      image: "assets/images/comp3.png",
      color: Color(0xff513F39),
    ),
  ].obs;
}

class CompetitionModel {
  final String name;
  final String image;
  final Color color;

  CompetitionModel({
    required this.name,
    required this.image,
    required this.color,
  });
}
