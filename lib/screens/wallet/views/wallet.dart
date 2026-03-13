import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_plan_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/ai_insight_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/balance_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/option_card.dart';

import '../../../widgets/header.dart';
import '../../subscribe/widgets/base_card.dart';

class Wallet extends StatelessWidget {
  Wallet({super.key});

  final controller = Get.put(RecoveryPlanController());

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
                        SizedBox(height: 44  *s,),
                        AiInsightWidget(),
                        SizedBox(height: 44 * s,),
                        BaseCard(
                          cardBorderColor: Colors.transparent,
                          cardGradientColorList: [
                            Colors.transparent,
                            Colors.transparent
                          ],
                          prefixIcon: "assets/icons/ArrowUpCircle.png",
                          iconBgColor: Color(0xff00D4AA).withValues(alpha: 0.12),
                          iconBorderRadius: 17 * s,
                          title: "Top Up",
                          titleFontSize: 14 * s,
                          description: "Purchased 2,500 points via Visa •4892",
                          descriptionFontSize: 12 * s,
                          status: "Default",
                          statusBorderColor: Color(0xff00BC7D).withValues(alpha: 0.2),
                          statusBackgroundColor: Color(0xff00BC7D).withValues(alpha: 0.2),
                          statusFontColor: Color(0xff00D492),
                          statusFontSize: 12 * s,
                          bottomSpacing: false,
                          child: SizedBox(),
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
