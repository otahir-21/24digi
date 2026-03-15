import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/controller/rewards_controller.dart';
import 'package:kivi_24/screens/wallet/controller/top_up_points_controller.dart';
import 'package:kivi_24/screens/wallet/views/top_up_points.dart';
import 'package:kivi_24/screens/wallet/widgets/purchasing_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/recent_activity_card.dart';
import 'package:kivi_24/screens/wallet/widgets/step_progress_tracker.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../../recovery_ai/widgets/primary_button.dart' show PrimaryButton;

class TopUpPointsTwo extends StatelessWidget {
  TopUpPointsTwo({super.key});

  final controller = Get.put(TopUpPointsController());

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
                    SizedBox(height: 26 * s),
                    StepProgressTracker(currentStep: 2),
                    SizedBox(height: 26 * s),
                    PurchasingWidget(),
                    SizedBox(height: 21 * s),
                    TitleWidget(title: "Payment Method", titleFontSize: 15 * s),
                    SizedBox(height: 12*s,),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.paymentMethods.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12 * s),
                      itemBuilder: (context, index) {
                        final method = controller.paymentMethods[index];

                         return Obx(() {
                           final bool isSelected = controller.selectedMethodId.value == method.id;

                          return GestureDetector(
                            onTap: () => controller.selectMethod(method.id),
                            behavior: HitTestBehavior.opaque,
                            child: RecentActivityCard(
                              title: method.title,
                              description: method.description,
                              prefixIcon: "assets/icons/Wallet.png",
                              iconBgColor: method.iconColor.withValues(alpha: 0.082),
                              iconImageColor: method.iconColor,
                              // REACTIVE PROPERTIES
                              cardColor: isSelected
                                  ? const Color(0xff00D4AA).withValues(alpha: 0.06)
                                  : Colors.white.withValues(alpha: 0.02),
                              cardBorderColor: isSelected
                                  ? const Color(0xff00D4AA).withValues(alpha: 0.30)
                                  : Colors.white.withValues(alpha: 0.04),
                              suffixIcon: isSelected
                                  ? "assets/icons/cp1.png"
                                  : "assets/icons/cp.png",
                              verticalPadding: 19 * s,
                              horizontalPadding: 17 * s,
                            ),
                          );
                        });
                      },
                    ),
                    SizedBox(height: 21*s,),
                    GestureDetector(
                      onTap: (){},
                      child: RecentActivityCard(
                        verticalPadding: 19*s,
                        horizontalPadding: 17*s,
                        cardColor: Color(0xffFFFFFF).withValues(alpha: 0.02),
                        cardBorderColor: Color(0xffFFFFFF).withValues(alpha: 0.08),
                        prefixIcon: "assets/icons/pls.png",
                        iconBgColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
                         title: "Add Payment Method",
                        titleFontColor: Color(0xff8888A0),
                      ),
                    ),
                    SizedBox(height: 24 * s),
                    PrimaryButton(
                      onTap: () => Get.to(() => TopUpPoints()),
                      height: 56 * s,
                      isGradient: true,
                      gradientColorList: [
                        Color(0xff00D4AA),
                        Color(0xff00B894),
                      ],
                      borderRadius: 17 * s,
                      borderColor: Colors.transparent,
                      title: "Review Order",
                      fontSize: 15 * s,
                      fontColor: Color(0xff0A0A12),
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 24 * s),
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
