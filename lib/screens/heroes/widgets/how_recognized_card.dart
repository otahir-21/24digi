import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/heroes/widgets/center_thick_divider.dart';
import 'package:kivi_24/screens/heroes/widgets/hero_base_container.dart';

class HowRecognizedCard extends StatelessWidget {
  const HowRecognizedCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return HeroBaseContainer(
      child: Column(
        spacing: 15 * s,
        children: [
          Text(
            "How Heroes Are",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 30 * s,
              fontWeight: FontWeight.w500,
            ),
          ),

          Text(
            "Recognized",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFF193CAD),
              fontSize: 30 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "Enter into the Hall of fame is an honor earned, not claimed.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFF6B7680),
              fontSize: 22 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          CenterThickDivider(),
        ],
      ),
    );
  }
}
