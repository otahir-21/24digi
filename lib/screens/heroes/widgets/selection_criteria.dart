import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/heroes/widgets/hero_base_container.dart';

class SelectionCriteria extends StatelessWidget {
  const SelectionCriteria({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return HeroBaseContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selection Criteria",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFF6B7680),
              fontSize: 18 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 45 * s),
          Text(
            "Long-term data",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 24 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "We analyze years, not weeks. Your legacy is built on the foundation of the time.",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFA8B3BA),
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 45 * s),
          Text(
            "Health-first behaviour",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 24 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Performance never compromises well-being. Vitality is the ultimate metric.",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFA8B3BA),
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 45 * s),
          Text(
            "Consistency over intensity",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFEAF2F5),
              fontSize: 24 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Bursts fade. Discipline endures. We reward the steady hand.",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFA8B3BA),
              fontSize: 16 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 19 * s),
        ],
      ),
    );
  }
}
