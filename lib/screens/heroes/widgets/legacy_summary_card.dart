import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/heroes/controller/hero_profile_controller.dart';

import '../../../core/utils/ui_scale.dart';

class LegacySummaryCard extends StatelessWidget {
  final controller = Get.find<HeroProfileController>();
  LegacySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 30 * s),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xff26313a),
            ),
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xff151B20),
          ),
          child: Text(
            controller.legacySummary,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "HelveticaNeueLight",
              fontSize: 18 * s,
              fontWeight: FontWeight.w400,
              color: Color(0xffEAF2F5),
            ),
          ),
        ),

        Positioned(
          top: -9.32 * s,
          left: 18.16 * s,
          child:
          Container(
            // width: 122.38 * s,
            height: 29 * s,
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10 * s),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5* s),
              border: Border.all(color: Color(0xff26313A), width: 2 * s),
              color: Color(0xff0E1215)
            ),
            child: Text(
              "LEGACY SUMMARY",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "HelveticaNeueLight",
                fontWeight: FontWeight.w400,
                fontSize: 12 * s,
                color: const Color(0xffEAF2F5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
