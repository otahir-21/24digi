import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/controller/rewards_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/category_selector.dart';
import 'package:kivi_24/screens/wallet/widgets/elite_reward_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/reward_list_view.dart';
import 'package:kivi_24/screens/wallet/widgets/rewards_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';

class Rewards extends StatelessWidget {
  Rewards({super.key});

  final controller = Get.put(RewardsController());

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
                    TitleWidget(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      title: "Rewards",
                      subtitle: "Redeem your points for real value",
                      spaceAboveSubtitle: 45*s,
                      badgeIcon: "assets/icons/ArrowUpCircle.png",
                      badgeColor: Color(0xff00D4AA),
                      badgeText: "Top Up",
                    ),
                    SizedBox(height: 14 * s),
                    Row(
                      spacing: 10 * s,
                      children: [
                        Text(
                          "Available:",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff555568),
                          ),
                        ),
                        Text(
                          controller.points,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 17 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff00D4AA),
                          ),
                        ),
                        Text(
                          "PTS",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff555568),
                          ),
                        ),
                        Text(
                          "≈ ${controller.aed}",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 12 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff555568),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 45 * s),
                    CategorySelector(),
                    SizedBox(height: 45 * s),
                    EliteRewardWidget(
                      title: "Exclusive Drop",
                      subTitle: "24DIDI Elite Hoodies",
                      description: "Limited edition - only 23 remaining",
                    ),
                    SizedBox(height: 45 * s,),
                    RewardsListView(),
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
