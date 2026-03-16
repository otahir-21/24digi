import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/subscribe/controller/subscription_controller.dart';
import 'package:kivi_24/screens/subscribe/widgets/transactions_widget.dart';

class TransactionsListView extends StatelessWidget {
  const TransactionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscriptionController>();
    final s = MediaQuery.of(context).size.width / 440;

    return Column(
      children: [
        Obx(() {
          int itemCount = controller.isExpanded.value
              ? controller.transactions.length
              : (controller.transactions.length > 4
                    ? 4
                    : controller.transactions.length);

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itemCount,
            separatorBuilder: (context, index) => SizedBox(height: 10 * s),
            itemBuilder: (context, index) {
              final data = controller.transactions[index];
              return TransactionsWidget(
                title: data.title,
                description: data.date,
                billAmount: data.amount,
                status: data.status,
              );
            },
          );
        }),

        Obx(() {
          if (controller.transactions.length <= 4) {
            return const SizedBox.shrink();
          }

          return InkWell(
            onTap: () => controller.toggleView(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16 * s),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.isExpanded.value
                        ? "Show Less"
                        : "View All (${controller.transactions.length})",
                    style: TextStyle(
                      fontFamily: "HelveticaNeue",
                      fontWeight: FontWeight.w500,
                      fontSize: 14.8 * s,
                      color: const Color(0xff7B8BA5),
                    ),
                  ),
                  SizedBox(width: 4 * s),
                  Icon(
                    controller.isExpanded.value
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xff7B8BA5),
                    size: 18 * s,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
