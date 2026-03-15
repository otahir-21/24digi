import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/subscribe/widgets/transaction_list_view.dart';

import '../../../widgets/custom_text_field.dart';
import '../controller/subscription_controller.dart';
import 'base_card.dart';

class BillingHistory extends StatelessWidget {
  final controller = Get.find<SubscriptionController>();

  BillingHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return  BaseCard(
      title: "Billing history",
      cardGradientColorList: [
        const Color(0xff0F1520),
        const Color(0xff0F1520),
      ],
      titleFontSize: 19 * s,
      titleTrailingIcon: "assets/icons/SlidersHorizontal.png",
      child: Column(
        children: [
          CustomTextField(
            hintText: "Search transactions..",
            borderColor: Color(
              0xffFFFFFF,
            ).withValues(alpha: 0.06),
            backgroundColor: Color(
              0xffFFFFFF,
            ).withValues(alpha: 0.03),
          ),
          SizedBox(height: 16 * s,),
          TransactionsListView()
        ],
      ),
    );
  }
}
