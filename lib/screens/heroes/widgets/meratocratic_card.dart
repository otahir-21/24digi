import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/heroes/widgets/hero_base_container.dart';

class MeratocraticCard extends StatelessWidget {
  const MeratocraticCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return HeroBaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "STRICTLY MERATOCRATIC",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18 * s),
          Text(
            "No manual applications accepted.",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18 * s),
          Text(
            "No purchases or subscriptions influence selection.",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 18 * s),
          Text(
            "Strictly by system invitation only.",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
