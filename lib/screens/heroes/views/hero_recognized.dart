import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/heroes/widgets/how_recognized_card.dart';
import 'package:kivi_24/screens/heroes/widgets/meratocratic_card.dart';
import 'package:kivi_24/screens/heroes/widgets/selection_criteria.dart';

import '../../../widgets/header.dart';

class HeroRecognized extends StatelessWidget {
  const HeroRecognized({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/hero_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.92)),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16 * s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RecoveryHeaderWidget(onBackTap: () => Get.back()),
                  SizedBox(height: 30 * s),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 22 * s),
                      children: [
                        SizedBox(height: 30 * s),
                        HowRecognizedCard(),
                        SizedBox(height: 45 * s),
                        SelectionCriteria(),
                        SizedBox(height: 45 * s),
                        MeratocraticCard(),
                        SizedBox(height: 45 * s),
                        Text(
                          textAlign: TextAlign.center,
                          "EXCELLENCE IS ITS OWN REWARD",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            color: Color(0xFF6B7680),
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 45 * s),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
