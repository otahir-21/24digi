import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';

class AiInsightWidget extends StatelessWidget {
  const AiInsightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      horizontalPadding: 17 * s,
      verticalPadding: 17 * s,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xff6366F1).withValues(alpha: 0.06),
          Color(0xff6366F1).withValues(alpha: 0.02),
        ],
      ),
      borderColor: Color(0xff6366F1).withValues(alpha: 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleIcon(
            height: 36 * s,
            width: 36 * s,
            borderRadius: 16 * s,
            backgroundColor: Color(0xff6366F1).withValues(alpha: 0.1),
            icon: "assets/icons/starr.png",
          ),
          SizedBox(width: 11 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI INSIGHT",
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    color: Color(0xFF6366F1),
                    fontSize: 10 * s,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 3 * s),
                Text(
                  "You earned +420 pts this week.\nEfficiency is up 12% from last week.",
                  style: TextStyle(
                    fontFamily: "HelveticaNeue",
                    color: Color(0xFFB0B0C0),
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16 * s,
            color: Color(0xff6366F1).withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }
}
