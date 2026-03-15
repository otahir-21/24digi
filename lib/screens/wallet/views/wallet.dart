import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/views/smart_insight.dart';
import 'package:kivi_24/screens/wallet/views/wallet_settings.dart';
import 'package:kivi_24/screens/wallet/widgets/ai_insight_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/balance_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/circle_icon.dart';
import 'package:kivi_24/screens/wallet/widgets/labe_widet.dart';
import 'package:kivi_24/screens/wallet/widgets/option_card.dart';
import 'package:kivi_24/screens/wallet/widgets/recent_activity_card.dart';
import 'package:kivi_24/screens/wallet/widgets/smart_insight_card.dart';

import '../../../widgets/header.dart';
import '../controller/wallet_controller.dart';

class Wallet extends StatelessWidget {
  Wallet({super.key});

  final controller = Get.put(WalletController());

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
                image: AssetImage("assets/images/digi_background.png"),
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
                      children: [
                        Row(
                          spacing: 4 * s,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: CircleIcon(
                                icon: "assets/icons/notification.png",
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.06,
                                ),
                                iconColor: Color(0xff8888A0),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Get.to(() => WalletSettings()),
                              child: CircleIcon(
                                icon: "assets/icons/threedt.png",
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.06,
                                ),
                                iconColor: Color(0xff8888A0),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 17 * s),
                        BalanceCard(),
                        SizedBox(height: 44 * s),
                        Row(
                          spacing: 12 * s,
                          children: [
                            OptionCard(iconColor: Color(0xff00D4AA)),
                            OptionCard(
                              iconBackGroundColor: Color(
                                0xff6366F1,
                              ).withValues(alpha: 0.07),
                              option: "Transfer",
                              icon: "assets/icons/Icon (11).png",
                            ),
                            OptionCard(
                              iconBackGroundColor: Color(
                                0xffF472B6,
                              ).withValues(alpha: 0.07),
                              option: "24 Shop",
                              icon: "assets/icons/Icon (12).png",
                            ),
                            OptionCard(
                              iconBackGroundColor: Color(
                                0xffFBBF24,
                              ).withValues(alpha: 0.07),
                              option: "Purchase",
                              icon: "assets/icons/Icon (13).png",
                            ),
                          ],
                        ),
                        SizedBox(height: 44 * s),
                        AiInsightWidget(),
                        SizedBox(height: 44 * s),
                        LabelWidget(
                          title: "RecentActivity",
                          option: "View All",
                          optionOnTap: () {},
                        ),
                        SizedBox(height: 45 * s),
                        Obx(
                          () => ListView.separated(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 16 * s,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            // Use if inside a ScrollView
                            itemCount: controller.activities.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 20 * s),
                            itemBuilder: (context, index) {
                              final activity = controller.activities[index];

                              return RecentActivityCard(
                                title: activity.title,
                                description: activity.description,
                                points: activity.points,
                                prefixIcon: activity.prefixIcon,
                                iconBgColor: activity.iconBgColor,
                                titleFontColor: Colors.white,
                                descriptionFontColor: const Color(0xff7B8BA5),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 44 * s),
                        LabelWidget(
                          title: "Smart Insight",
                          option: "See all",
                          optionColor: Color(0xff6366F1),
                          optionOnTap: () => Get.to(() => SmartInsight()),
                        ),
                        SizedBox(height: 44 * s),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16 * s),
                          child: Obx(
                            () => Row(
                              children: controller.insights.map((insight) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 12 * s),
                                  child: SizedBox(
                                    width: Get.width * 0.8,
                                    child: SmartInsightCard(
                                      iconColor: insight.themeColor,
                                      titleColor: insight.themeColor,
                                      title: insight.title,
                                      description: insight.description,
                                      cardColor: insight.themeColor.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderColor: insight.themeColor
                                          .withValues(alpha: 0.063),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
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
