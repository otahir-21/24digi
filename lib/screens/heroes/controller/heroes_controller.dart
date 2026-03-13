import 'package:get/get.dart';

class HeroesController extends GetxController {
  final RxList<HeroModel> heroes = <HeroModel>[
    HeroModel(
      heroImage: "assets/images/hero.png",
      position: "#1",
      heroName: "User Name",
      rank: "User rank",
      legacyLabel: "LEGACY",
      legacyValue: "985",
    ),
    HeroModel(
      heroImage: "assets/images/hero.png",
      position: "#2",
      heroName: "Alice Johnson",
      rank: "Moderator",
      legacyLabel: "ACTIVE",
      legacyValue: "1200",
    ),
    HeroModel(
      heroImage: "assets/images/hero.png",
      position: "#3",
      heroName: "Brain Smith",
      rank: "Member",
      legacyLabel: "ACTIVE",
      legacyValue: "750",
    ),
    HeroModel(
      heroImage: "assets/images/hero.png",
      position: "#3",
      heroName: "Brain Smith",
      rank: "Member",
      legacyLabel: "ACTIVE",
      legacyValue: "750",
    ),
    HeroModel(
      heroImage: "assets/images/hero.png",
      position: "#3",
      heroName: "Brain Smith",
      rank: "Member",
      legacyLabel: "ACTIVE",
      legacyValue: "750",
    ),
    HeroModel(
      heroImage: "assets/images/hero.png",
      position: "#3",
      heroName: "Brain Smith",
      rank: "Member",
      legacyLabel: "ACTIVE",
      legacyValue: "750",
    ),
  ].obs;
}

class HeroModel {
  final String heroImage;
  final String position;
  final String heroName;
  final String rank;
  final String legacyLabel;
  final String legacyValue;

  HeroModel({
    required this.heroImage,
    required this.position,
    required this.heroName,
    required this.rank,
    required this.legacyLabel,
    required this.legacyValue,
  });
}
