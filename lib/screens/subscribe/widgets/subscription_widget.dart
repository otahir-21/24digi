import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/controller/subscription_controller.dart';
import 'package:kivi_24/screens/subscribe/widgets/subscription_details_card.dart';
import 'base_card.dart';

class SubscriptionWidget extends StatelessWidget {
  final controller = Get.find<SubscriptionController>();
   SubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      title: "Subscriptions",
      status: "24DIGI",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SubscriptionDetailsCard(
                  icon: 'assets/icons/Wallet.png',
                  title: 'Monthly Cost',
                  detail:
                  controller.subscriptionDetails[0].detail,
                  unit: controller.subscriptionDetails[0].unit,
                ),
              ),
              SizedBox(width: 12 * s),

              Expanded(
                child: SubscriptionDetailsCard(
                  icon: 'assets/icons/CalendarClock.png',
                  title: 'Next Billing',
                  detail:
                  controller.subscriptionDetails[1].detail,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * s),
          Row(
            children: [
              Expanded(
                child: SubscriptionDetailsCard(
                  icon: 'assets/icons/Layers3.png',
                  title: 'Active Plans',
                  detail:
                  controller.subscriptionDetails[2].detail,
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),

          SizedBox(height: 12 * s),

          SubscriptionDetailsCard(
            icon: 'assets/icons/TrendingUp.png',
            title: 'Insight',
            detail: controller.subscriptionDetails[3].detail,
            detailsFontSize: 15 * s,
          ),
        ],
      ),
    );
  }
}
