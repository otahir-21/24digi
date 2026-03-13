import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/controller/subscription_controller.dart';
import 'package:kivi_24/screens/subscribe/widgets/subscription_insight_details_card.dart';

import '../../recovery_ai/widgets/primary_button.dart' show PrimaryButton;
import 'base_card.dart';

class CByAiAssistant extends StatelessWidget {
  final controller = Get.find<SubscriptionController>();
   CByAiAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      title: "C By AI Assistant",
      cardBorderColor: Color(0xff1e2a3d),
      cardGradientColorList: [
        Color(0xff0f1520),
        Color(0xff0f1520),
      ],
      prefixIcon: "assets/icons/Bot.png",
      iconGradient: LinearGradient(
        colors: [Color(0xff0092B8), Color(0xff00786F)],
      ),

      titleFontSize: 20 * s,
      description: "Smart subscription insight",
      child: Column(
        spacing: 12 * s,
        children: [
          SubscriptionInsightDetailsCard(
            icon: controller
                .smartSubscriptionInsightDetails[0]
                .icon,
            description: controller
                .smartSubscriptionInsightDetails[0]
                .description,
            option: controller
                .smartSubscriptionInsightDetails[0]
                .option,
          ),
          SubscriptionInsightDetailsCard(
            iconBgColor: Color(
              0xffD4A574,
            ).withValues(alpha: 0.1),
            iconBorderColor: Color(
              0xffD4A574,
            ).withValues(alpha: 0.2),
            icon: controller
                .smartSubscriptionInsightDetails[1]
                .icon,
            description: controller
                .smartSubscriptionInsightDetails[1]
                .description,
            option: controller
                .smartSubscriptionInsightDetails[1]
                .option,
          ),
          SubscriptionInsightDetailsCard(
            iconBgColor: Color(
              0xffFF6900,
            ).withValues(alpha: 0.1),
            iconBorderColor: Color(
              0xffFF6900,
            ).withValues(alpha: 0.2),
            icon: controller
                .smartSubscriptionInsightDetails[2]
                .icon,
            description: controller
                .smartSubscriptionInsightDetails[2]
                .description,
            option: controller
                .smartSubscriptionInsightDetails[2]
                .option,
          ),
          SizedBox(height: 30 * s),
          PrimaryButton(
            onTap: () {},
            title: "Optimize My Plan",
            isGradient: true,
            gradientColorList: [
              Color(0xffD4A574),
              Color(0xffC08B5C),
            ],
            height: 42 * s,
            fontSize: 14 * s,
            fontWeight: FontWeight.w500,
            fontColor: Color(0xff080C14),
            borderColor: Color(0xffd4a574),
          ),
        ],
      ),
    );
  }
}
