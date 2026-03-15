import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/widgets/base_card.dart';

class SubscriptionInsightDetailsCard extends StatelessWidget {
  final String icon;
  final String description;
  final String option;
  final Color? iconBgColor;
  final Color? iconBorderColor;

  const SubscriptionInsightDetailsCard({
    super.key,
    required this.icon,
    required this.description,
    required this.option, this.iconBgColor, this.iconBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      cardBorderColor: Color(0xffffffff).withValues(alpha: 0.05),
      cardGradientColorList: [
        Color(0xffffffff).withValues(alpha: 0.03),
        Color(0xffffffff).withValues(alpha: 0.03),
      ],
      prefixIcon: icon,
      iconBgColor: iconBgColor??  Color(0xff00BC7D).withValues(alpha: 0.1),
      iconBorderColor: iconBorderColor?? Color(0xff00BC7D).withValues(alpha: 0.2),
      title:
          description,
      titleFontSize: 14 * s,
      titleFontColor: Color(0xffE8ECF4),
      spaceBeforeDescription: 8,
      description: option,
      descriptionOnCall: () {},
      descriptionFontColor: Color(0xffD4A574),
      bottomSpacing: false,
      child: SizedBox(),
    );
  }
}
