import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:kivi_24/screens/wallet/controller/top_up_point_one_controller.dart';
import 'package:kivi_24/screens/wallet/views/top_up_points_two.dart';
import 'package:kivi_24/screens/wallet/widgets/custom_amount_widget.dart';
 import 'package:kivi_24/screens/wallet/widgets/packages_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/purchasing_widget.dart';
 import 'package:kivi_24/screens/wallet/widgets/step_progress_tracker.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../../recovery_ai/widgets/primary_button.dart' show PrimaryButton;
import '../widgets/recent_activity_card.dart';

class TopUpPointsOne extends StatelessWidget {
  TopUpPointsOne({super.key});

  final controller = Get.put(TopUpPointOneController());

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
                    StepProgressTracker(currentStep: 1),
                    SizedBox(height: 26 * s),
                    PurchasingWidget(
                      showPts: false,
                      title: "Current Balance",
                      amount: "12,847",
                      suffix: "=12,84 AED",
                      suffixFontSize: 12*s,
                      suffixFontColor: Color(0xff555568),
                    ),
                    SizedBox(height: 45*s,),
                    Text(
                      "Select a Package",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xffFFFFFF),
                      ),
                    ),
                    SizedBox(height: 45*s,),
                    Obx(() => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.packages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12 * s,
                        mainAxisSpacing: 20 * s, // Increased spacing to accommodate the top tag
                        mainAxisExtent: 110 * s, // Adjust based on your BaseCard height
                      ),
                      itemBuilder: (context, index) {
                        final package = controller.packages[index];
                        return PackagesWidget(
                          amount: package.amount,
                          title: package.title,
                          suffix: package.price,
                          isBestValue: package.isBestValue,
                        );
                      },
                    )),
                    SizedBox(height: 45*s,),
                    GestureDetector(
                      onTap: (){},
                      child: RecentActivityCard(
                        verticalPadding: 19*s,
                        horizontalPadding: 17*s,
                        cardColor: Color(0xff6366F1).withValues(alpha: 0.06),
                        cardBorderColor: Color(0xff6366F1).withValues(alpha: 0.3),
                        prefixIcon: "assets/icons/pls.png",
                        iconImageColor: Color(0xff6366F1),
                        iconBgColor: Color(0xfF6366F1).withValues(alpha: 0.04),
                        title: "Custom Amount",
                        description: "Enter any amount you want",
                        descriptionFontColor: Color(0xff555568),
                        suffixIcon: "assets/icons/arrow_right.png",
                        titleFontColor: Color(0xff8888A0),
                      ),
                    ),
                    SizedBox(height: 45*s,),
                    CustomAmountWidget(),
                    SizedBox(height: 45*s,),
                    PrimaryButton(
                      onTap: () => Get.to(()=> TopUpPointsTwo()),
                      height: 56 * s,
                      isGradient: true,
                      gradientColorList: [
                        Color(0xff00D4AA),
                        Color(0xff00B894),
                      ],
                      borderRadius: 17 * s,
                      borderColor: Colors.transparent,
                      title: "Continue to Pay",
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
