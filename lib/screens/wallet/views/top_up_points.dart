import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';
import 'package:kivi_24/screens/wallet/views/purchase_complete.dart';
import 'package:kivi_24/screens/wallet/widgets/order_summary_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/recent_activity_card.dart';
import 'package:kivi_24/screens/wallet/widgets/step_progress_tracker.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';

class TopUpPoints extends StatelessWidget {
  const TopUpPoints({super.key});

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
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      title: "Top Up Points",
                      subtitle: "Purchase 24DIGI points securely",
                      isSecure: true,
                    ),
                    SizedBox(height: 26 * s,),
                    StepProgressTracker(currentStep: 3),
                    SizedBox(height: 26 * s,),
                    OrderSummaryWidget(),
                    SizedBox(height:21 * s),

                    SizedBox(height: 17 * s),
                    RecentActivityCard(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      verticalPadding: 15 * s,
                      horizontalPadding: 15 * s,
                      cardColor: Color(0xff00D4AA).withValues(alpha: 0.04),
                      cardBorderColor: Color(0xff00D4AA).withValues(
                          alpha: 0.08),
                      prefixIcon: "assets/icons/verifiedd.png",
                      title: "Secure Transaction",
                      titleFontSize: 12 * s,
                      titleFontColor: Color(0xffFFFFFF),
                      description: "Your payment is processed through encrypted channels. Points will be credited instantly upon successful payment.",
                      descriptionFontSize: 11 * s,
                      descriptionFontColor: Color(0xff555568),
                    ),
                    SizedBox(height: 25 * s,),
                    PrimaryButton(
                      onTap: () => Get.to(()=> PurchaseComplete()),
                      height: 56 * s,
                      isGradient: true,
                      gradientColorList: [
                        Color(0xff00D4AA),
                        Color(0xff00B894),
                      ],
                      borderRadius: 17 * s,
                      borderColor: Colors.transparent,
                      title: "Confirm & Pay 225.00 AED",
                      fontSize: 15 * s,
                      fontColor: Color(0xff0A0A12),
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 12 * s,),
                    PrimaryButton(
                      height: 56 * s,
                      buttonColor: Color(0xffFFFFFF).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      borderColor: Colors.transparent,
                      title: "Cancel",
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w500,
                      fontColor: Color(0xff8888A0),

                    ),
                    SizedBox(height: 24 * s,)
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
