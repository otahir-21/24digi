import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/controller/wallet_analytics_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/balance_composition_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/point_flow_widget.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../widgets/point_source_widget.dart';
import '../widgets/smart_insight_card.dart';

class WalletAnalytics extends StatelessWidget {
  WalletAnalytics({super.key});

  final controller = Get.put(WalletAnalyticsController());

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
                    Text(
                      "Wallet Analytics",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffFFFFFF),
                      ),
                    ),
                    Text(
                      "Your financial journey in number",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 45 * s),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10 * s,
                        mainAxisSpacing: 10 * s,
                        mainAxisExtent: 140 * s,
                      ),
                      itemCount: controller.analyticsData.length,
                      itemBuilder: (context, index) {
                        final analyticsData = controller.analyticsData[index];
                        return SmartInsightCard(
                          verticalPadding: 14 * s,
                          circularIcon: true,
                          iconBgColor: analyticsData.themeColor.withValues(alpha: 0.07),
                          icon: analyticsData.icon,
                          iconColor: analyticsData.themeColor,
                          title: '',
                          subTitle: analyticsData.points,
                          subTitleColor: analyticsData.themeColor,
                          description: analyticsData.description,
                          descriptionColor: Color(0xff555568),
                          spaceBeforeDescription: 0,
                          descriptionFontSize: 10 * s,
                        );
                      },
                    ),
                    SizedBox(height: 45 * s),
                    PointFlowWidget(),
                    SizedBox(height: 45 * s),
                    PointSourceWidget(),
                    SizedBox(height: 45 * s),
                    BalanceCompositionWidget(),
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
