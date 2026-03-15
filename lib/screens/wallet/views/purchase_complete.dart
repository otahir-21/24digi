import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';
import 'package:kivi_24/screens/wallet/views/main_parent_screen.dart';
import 'package:kivi_24/screens/wallet/widgets/points_added_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/recent_activity_card.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';

class PurchaseComplete extends StatelessWidget {
  const PurchaseComplete({super.key});

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
                      title: "Purchase Complete",
                      isSecure: true,
                    ),
                    SizedBox(height: 79 * s),
                    SizedBox(
                      height: 90 * s,
                      child: Image.asset("assets/images/Container.png"),
                    ),
                    SizedBox(height: 25 * s),
                    Center(
                      child: Text(
                        "Payment Successful!",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: Color(0xffffffff),
                          fontSize: 21 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Points have been credited to your wallet",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          color: Color(0xff555568),
                          fontSize: 15 * s,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 45 * s),
                    PointsAddedWidget(),
                    SizedBox(height: 17 * s),
                    RecentActivityCard(
                      verticalPadding: 15 * s,
                      horizontalPadding: 15 * s,
                      cardColor: Color(0xffFFFFFF).withValues(alpha: 0.02),
                      cardBorderColor: Color(
                        0xffFFFFFF,
                      ).withValues(alpha: 0.02),
                      prefixIcon: "assets/icons/verifiedd.png",
                      title: "Reference",
                      titleFontSize: 12 * s,
                      titleFontColor: Color(0xff8888A0),
                      description: "TXN-2026-0227-002",
                      descriptionFontSize: 12 * s,
                      descriptionFontColor: Colors.white,
                      status: "VERIFIED",
                      statusColor: Color(0xff00D4AA),
                      statusBgColor: Color(0xff00D4AA).withValues(alpha: 0.1),
                    ),
                    SizedBox(height: 25 * s),
                    PrimaryButton(
                      onTap: () => Get.to(() => MainParentScreen()),
                      height: 56 * s,
                      isGradient: true,
                      gradientColorList: [Color(0xff00D4AA), Color(0xff00B894)],
                      borderRadius: 17 * s,
                      borderColor: Colors.transparent,
                      title: "Back to Wallet",
                      fontSize: 15 * s,
                      fontColor: Color(0xff0A0A12),
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 12 * s),
                    PrimaryButton(
                      height: 56 * s,
                      buttonColor: Color(0xffFFFFFF).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      borderColor: Colors.transparent,
                      title: "View Purchase History",
                      fontSize: 15 * s,
                      fontWeight: FontWeight.w500,
                      fontColor: Color(0xff8888A0),
                    ),
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
