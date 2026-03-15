import 'package:flutter/material.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import 'card.dart';
import 'circle_icon.dart';

class OptionCard extends StatelessWidget {
  final String? option;
  final String? icon;
  final Color? iconBackGroundColor;
  final Color? iconColor;

  const OptionCard({
    super.key,
    this.option,
    this.icon,
    this.iconBackGroundColor, this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      height: 98* s,
      width: 92 * s,
      verticalPadding: 10 * s,
      child: Column(
        spacing: 8 * s,
        children: [
          CircleIcon(
            borderRadius: 17 * s,
            backgroundColor: iconBackGroundColor ??  Color(0xff00D4AA).withValues(alpha: 0.07),
            // iconColor: Color(0xff00D4AA),
            iconColor: iconColor,
            icon: icon?? "assets/icons/ArrowUpCircle.png",
          ),
          Text(
            option?? "Top Up",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              color: Color(0xFFC0C0D0),
              fontSize: 11 * s,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
