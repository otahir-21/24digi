import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/heroes/controller/hero_profile_controller.dart';
import 'package:kivi_24/screens/heroes/controller/heroes_controller.dart';
import 'package:kivi_24/screens/heroes/widgets/hero_profile_avatart.dart';
import 'package:kivi_24/screens/heroes/widgets/holistic_score_widget.dart';
import 'package:kivi_24/screens/heroes/widgets/legacy_summary_card.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../widgets/compitition_card.dart';

class HeroProfile extends StatelessWidget {
  HeroProfile({super.key});

  final controller = Get.put(HeroProfileController());

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Scaffold(
      backgroundColor: Color(0xff0E1215),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16 * s),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RecoveryHeaderWidget(onBackTap: () => Get.back()),
              SizedBox(height: 30 * s),
              Expanded(
                child: ListView(
                  children: [
                    // SizedBox(height: 30 * s),
                    HeroProfileAvatar(imageUrl: controller.profileImage),
                    SizedBox(height: 25 * s),
                    Text(
                    controller.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 32 * s,
                        fontWeight: FontWeight.w700,
                        color: Color(0xffEAF2F5),
                      ),
                    ),
                    SizedBox(height: 25 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset("assets/icons/bar.png", width: 39 * s),
                        Text(
                          controller.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffFFB547),
                          ),
                        ),
                        Image.asset(
                          "assets/icons/bar_right.png",
                          width: 39 * s,
                        ),
                      ],
                    ),
                    SizedBox(height: 25 * s),
                    Text(
                      "Hall of Fame Inductee • Jan 2025",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 18 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff6B7680),
                      ),
                    ),
                    SizedBox(height: 25),
                    // Image.asset("assets/images/holistic_score.png", width: 394 * s, height: 394 * s,),
                    HolisticScoreWidget(),
                    SizedBox(height: 25 * s),
                    LegacySummaryCard(),
                    SizedBox(height: 25 * s),
                    // Inside your build method
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16 * s),
                      child: Obx(() => Row(
                        children: controller.competitions.map((comp) {
                          return Padding(
                            padding: EdgeInsets.only(right: 12 * s), // Spacing between cards
                            child: CompititionCard(
                              image: comp.image,
                              name: comp.name,
                              borderColor: comp.color, // Passing the color from controller
                            ),
                          );
                        }).toList(),
                      )),
                    ),
                    SizedBox(height: 25 * s,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
