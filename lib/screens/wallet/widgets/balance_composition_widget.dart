import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/wallet/controller/wallet_analytics_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/labe_widet.dart';
import 'package:kivi_24/screens/wallet/widgets/period_toggle_button.dart';
import 'package:kivi_24/screens/wallet/widgets/point_flow_graph.dart';

import 'balance_composition_bar.dart';

class BalanceCompositionWidget extends StatelessWidget {
  final controller = Get.find<WalletAnalyticsController>();
  BalanceCompositionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return BaseCard(
      backgroundColor: Color(0xffFFFFFF).withValues(alpha: 0.02),
      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
      horizontalPadding: 18 * s,
      verticalPadding: 23 * s,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Balance Composition",
            style: TextStyle(
              fontFamily: "HelveticaNeue",
              fontSize: 15 * s,
              fontWeight: FontWeight.w500,
              color: Color(0xffFFFFFF),
            ),
          ),
          Obx(() => Column(
            children: controller.progressStats.map((data) {
              return Padding(
                padding: EdgeInsets.only(bottom: 20 * s),
                child: BalanceCompositionBar(
                  title: data.title,
                  percentage: data.percentage,
                  color: data.color,
                ),
              );
            }).toList(),
          ))
        ],
      ),
    );
  }
}
