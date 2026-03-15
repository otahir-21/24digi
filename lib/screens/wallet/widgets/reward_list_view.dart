import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/controller/rewards_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/rewards_widget.dart';

class RewardsListView extends StatelessWidget {
  final controller = Get.find<RewardsController>();

  RewardsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);

    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 16 * s),
        physics: const NeverScrollableScrollPhysics(),
        // Use if inside a SingleChildScrollView
        itemCount: controller.rewardsList.length,
        separatorBuilder: (context, index) => SizedBox(height: 16 * s),
        itemBuilder: (context, index) {
          final reward = controller.rewardsList[index];

          return RewardsWidget(
            title: reward.title,
            description: reward.description,
            points: reward.points,
            category: reward.category,
            iconBackgroundColor: reward.iconBgColor,
            dayLeft: reward.daysLeft, // Will be null if not provided in model
          );
        },
      ),
    );
  }
}
