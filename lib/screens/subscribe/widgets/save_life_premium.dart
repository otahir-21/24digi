import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/controller/subscription_controller.dart';
import 'package:kivi_24/screens/subscribe/widgets/subscription_details_card.dart';

import 'base_card.dart';

class SaveLifePremium extends StatelessWidget {
  final controller = Get.find<SubscriptionController>();

  SaveLifePremium({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      cardGradientColorList: [
        Color(0xff002C22).withValues(alpha: 0.4),
        Color(0xff022F2E).withValues(alpha: 0.3),
      ],
      cardBorderColor: Color(0xff00BC7D).withValues(alpha: 0.2),
      topBorderWidth: 3,
      prefixIcon: "assets/icons/ShieldCheck.png",
      iconGradient: LinearGradient(
        begin: AlignmentGeometry.topCenter,
        end: AlignmentGeometry.bottomCenter,
        colors: [Color(0xff00BC7D), Color(0xff009689)],
      ),
      title: "SafeLife Premium",
      titleFontSize: 19 * s,
      description: "Emerging monitoring & response",
      status: "Coverage Active",
      statusFontSize: 12 * s,
      statusFontColor: Color(0xff00D492),
      statusBackgroundColor: Color(0xff00BC7D).withValues(alpha: 0.1),
      statusBorderColor: Color(0xff00BC7D).withValues(alpha: 0.2),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SubscriptionDetailsCard(
                  icon: 'assets/icons/Wallet.png',
                  title: 'Monitoring',
                  detailsFontSize: 14 * s,
                  showTitleBelow: true,
                  detail: controller.premiumSubscriptionDetails[0].detail,
                ),
              ),
              SizedBox(width: 12 * s),

              Expanded(
                child: SubscriptionDetailsCard(
                  icon: 'assets/icons/RefreshCw.png',
                  title: 'Renewal',
                  detailsFontSize: 14 * s,
                  showTitleBelow: true,
                  detail: controller.premiumSubscriptionDetails[1].detail,
                ),
              ),
              SizedBox(width: 12 * s),
              Expanded(
                child: SubscriptionDetailsCard(
                  icon: 'assets/icons/AlertTriangle.png',
                  title: 'Priority',
                  showTitleBelow: true,
                  detailsFontSize: 14 * s,
                  detail: controller.premiumSubscriptionDetails[2].detail,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * s),
          BaseCard(
            prefixIcon: "assets/icons/AlertTriangle.png",
            prefixIconWithBase: false,
            title:
                "This is a critical safety subscription. Cancellation requires additional verification to ensure your safety coverage continues.",
            titleFontColor: Color(0xffFFD230).withValues(alpha: 0.8),
            cardBorderColor: Color(0xfffe9a00).withValues(alpha: 0.15),
            cardGradientColorList: [
              Color(0xfffe9a00).withValues(alpha: 0.05),
              Color(0xfffe9a00).withValues(alpha: 0.05),
            ],
            titleFontSize: 12 * s,
            bottomSpacing: false,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}
