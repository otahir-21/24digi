import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/controller/smart_insight_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/ai_insight_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/smart_insight_card.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';

class SmartInsight extends StatelessWidget {
  SmartInsight({super.key});

  final controller = Get.put(SmartInsightController());

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
                    SizedBox(height: 30 * s),
                    Text(
                      "Smart Insight",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffFFFFFF),
                      ),
                    ),
                    Text(
                      "AI-powered wallet intelligence",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 45 * s),
                    SmartInsightCard(
                      borderColor: Color(0xff6366F1).withValues(alpha: 0.1),
                      cardGradient: LinearGradient(
                        colors: [
                          Color(0xff6366F1).withValues(alpha: 0.08),
                          Color(0xff00D4AA).withValues(alpha: 0.03),
                        ],
                      ),
                      title: "WEEKLY SUMMARY",
                      titleColor: Color(0xff6366F1),
                      iconColor: Color(0xff6366F1),
                      subTitle: "Strong week, Khalfan!",
                      description:
                          "You earned 420 points with 12% better efficiency. \n"
                          "Your 14-day streak is boosting your multiplier.",
                      descriptionFontSize: 15 * s,
                    ),
                    SizedBox(height: 45 * s),
                    Text(
                      "All Insights",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffFFFFFF),
                      ),
                    ),
                    SizedBox(height: 45 * s),
                    Obx(
                      () => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.allInsights.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 10 * s),
                        itemBuilder: (context, index) {
                          final allInsights = controller.allInsights[index];
                          return AiInsightWidget(
                            horizontalOuterPadding: 0,
                            showSuffixIcon: false,
                            cardColor: allInsights.themeColor.withValues(
                              alpha: 0.06,
                            ),
                            cardBorderColor: allInsights.themeColor.withValues(
                              alpha: 0.063,
                            ),
                            iconBackgroundColor: allInsights.themeColor
                                .withValues(alpha: 0.07),
                            isUrgent: allInsights.isExpire ?? false,
                            icon: allInsights.icon,
                            title: allInsights.title,
                            titleColor: allInsights.themeColor,
                            description: allInsights.description,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 45 * s,)
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
