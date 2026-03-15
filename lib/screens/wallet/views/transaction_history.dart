import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/controller/transaction_history_controller.dart';
import 'package:kivi_24/screens/wallet/widgets/in_out_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/title_widget.dart';
import 'package:kivi_24/screens/wallet/widgets/transaction_category_selector.dart';
import 'package:kivi_24/widgets/custom_text_field.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../widgets/recent_activity_card.dart';

class TransactionHistory extends StatelessWidget {
  TransactionHistory({super.key});

  final controller = Get.put(TransactionHistoryController());

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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      title: "Transaction History",
                      subtitle:
                          "All points movement - transparent and verifies",
                      spaceAboveSubtitle: 45 * s,
                      badgeIcon: "assets/icons/ArrowUpCircle.png",
                      badgeColor: Color(0xff00D4AA),
                      badgeText: "Purchase",
                    ),
                    SizedBox(height: 14 * s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InOutWidget(amount: "+9,350"),
                        InOutWidget(totalIn: false, amount: "-450"),
                      ],
                    ),
                    SizedBox(height: 45 * s),
                    CustomTextField(
                      hintText: "Search transactions",
                      backgroundColor: Colors.white.withValues(alpha: 0.03),
                      borderColor: Colors.white.withValues(alpha: 0.04),
                    ),
                    SizedBox(height: 45 * s),
                    TransactionCategorySelector(),
                    SizedBox(height: 45 * s),
                    Obx(
                      () => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.transactions.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 20 * s),
                        itemBuilder: (context, index) {
                          final activity = controller.transactions[index];

                          return RecentActivityCard(
                            horizontalPadding: 15*s,
                            verticalPadding: 15*s,
                            cardColor: Colors.white.withValues(alpha: 0.02),
                            cardBorderColor: Colors.white.withValues(
                              alpha: 0.04,
                            ),
                            title: activity.title,
                            description: activity.description,
                            points: activity.points,
                            prefixIcon: activity.prefixIcon,
                            iconBgColor: activity.iconBgColor,
                            // status: activity.status,
                            titleFontColor: Colors.white,
                            descriptionFontColor: const Color(0xff7B8BA5),
                          );
                        },
                      ),
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
