import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import '../controller/subscription_controller.dart';
import 'base_card.dart';
import 'icon_toggle_row.dart';

class PaymentAndBilling extends StatelessWidget {
  final controller = Get.find<SubscriptionController>();

  PaymentAndBilling({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      title: "Payment & billing",
      cardGradientColorList: [
        const Color(0xff0F1520),
        const Color(0xff0F1520),
      ],
      titleFontSize: 19 * s,
      child: Column(
        children: [
          BaseCard(
            cardBorderColor: Color(0xffffffff).withValues(alpha: 0.05),
            cardGradientColorList: [
              Color(0xffffffff).withValues(alpha: 0.03),
              Color(0xffffffff).withValues(alpha: 0.03),
            ],
            prefixIcon: "assets/icons/CreditCard.png",
            iconGradient: LinearGradient(
              colors: [Color(0xff4F39F6), Color(0xff372AAC)],
            ),
            title: "Visa .... 4892",
            titleFontSize: 14 * s,
            description: "Expires 09/27",
            descriptionFontSize: 12 * s,
            status: "Default",
            statusBorderColor: Color(0xff00BC7D).withValues(alpha: 0.2),
            statusBackgroundColor: Color(0xff00BC7D).withValues(alpha: 0.2),
            statusFontColor: Color(0xff00D492),
            statusFontSize: 12 * s,
            bottomSpacing: false,
            child: SizedBox(),
          ),
          SizedBox(height: 12 * s),
          BaseCard(
            cardBorderColor: Color(0xffffffff).withValues(alpha: 0.05),
            cardGradientColorList: [
              Color(0xffffffff).withValues(alpha: 0.03),
              Color(0xffffffff).withValues(alpha: 0.03),
            ],
            prefixIcon: "assets/icons/Wallet.png",
            iconImageColor: Colors.white,
            iconGradient: LinearGradient(
              begin: AlignmentGeometry.topCenter,
              end: AlignmentGeometry.bottomCenter,
              colors: [Color(0xffD4A574), Color(0xffB8895A)],
            ),
            title: "24 Wallet",
            titleFontSize: 14 * s,
            description: "Balance 523.50 AED",
            descriptionFontSize: 12 * s,
            status: "Use",
            statusOnTap: () {},
            statusBorderColor: Colors.transparent,
            statusBackgroundColor: Colors.transparent,
            statusFontColor: Color(0xffD4A574),
            statusFontSize: 14 * s,
            bottomSpacing: false,
            child: SizedBox(),
          ),
          SizedBox(height: 28 * s),
          IconToggleRow(
            iconPath: "assets/icons/Plus.png",
            title: "Add Payment",
          ), // is
          SizedBox(height: 18 * s),
          IconToggleRow(
            iconPath: "assets/icons/svg.png",
            title: "Auto-Renew",
            isSwitched: controller.autoRenewEnabled,
            onToggle: (value) {
              controller.toggleNotifications(value);
            },
          ), // is
          SizedBox(height: 18 * s),
          IconToggleRow(
            iconPath: "assets/icons/MapPin.png",
            title: "Billing Address",
          ), // is
          SizedBox(height: 18 * s),
          IconToggleRow(
            iconPath: "assets/icons/FileText.png",
            title: "Download Invoice",
          ), // is
          SizedBox(height: 18 * s),
          Container(
            // padding: EdgeInsetsGeometry.symmetric(vertical: 14 * s),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xff1E2A3D), width: 1.25),
              ),
            ),
          ),
          SizedBox(height: 10 * s,),
          IconToggleRow(
            iconPath: "assets/icons/Lock2.png",
            title: " • Secure Payment ",
            titleFontColor: Color(0xff7B8BA5)
          ),
        ],
      ),
    );
  }
}
