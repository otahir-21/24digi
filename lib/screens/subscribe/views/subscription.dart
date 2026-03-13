import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/subscribe/controller/subscription_controller.dart';
import 'package:kivi_24/screens/subscribe/widgets/subscription_widget.dart';
import 'package:kivi_24/screens/subscribe/widgets/billing_history.dart';
import 'package:kivi_24/screens/subscribe/widgets/bundle_and_savings.dart';
import 'package:kivi_24/screens/subscribe/widgets/c_by_ai_assistant.dart';
import 'package:kivi_24/screens/subscribe/widgets/data_protected_widget.dart';
import 'package:kivi_24/screens/subscribe/widgets/discover_more.dart';
import 'package:kivi_24/screens/subscribe/widgets/payment_and_billing.dart';
import 'package:kivi_24/screens/subscribe/widgets/save_life_premium.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../widgets/active_subscription_card.dart';

class Subscription extends StatelessWidget {
  Subscription({super.key});

  final controller = Get.put(SubscriptionController());

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
               SizedBox(height: 60 * s),
              Expanded(
                child: ListView(
                  children: [
                    SubscriptionWidget(),
                    SizedBox(height: 45 * s),
                    SaveLifePremium(),
                    SizedBox(height: 45 * s),
                    CByAiAssistant(),
                    SizedBox(height: 45 * s),
                    ActiveSubscriptionCard(
                      prefixIcon: controller.activeSubscriptions[0].icon,
                      iconGradient: LinearGradient(
                        colors: [Color(0xff0092B8), Color(0xff00786F)],
                      ),
                      title: controller.activeSubscriptions[0].name,
                      plan: controller.activeSubscriptions[0].plan,
                      status: "Active",
                      price: controller.activeSubscriptions[0].price,
                      unit: "/mo",
                      nextPaymentDate:
                          controller.activeSubscriptions[0].nextPaymentDate,
                    ),
                    SizedBox(height: 16 * s),
                    ActiveSubscriptionCard(
                      prefixIcon: controller.activeSubscriptions[1].icon,
                      iconGradient: LinearGradient(
                        colors: [Color(0xff4F39F6), Color(0xff7008E7)],
                      ),
                      title: controller.activeSubscriptions[1].name,
                      plan: controller.activeSubscriptions[1].plan,
                      status: "Active",
                      price: controller.activeSubscriptions[1].price,
                      unit: "/mo",
                      nextPaymentDate:
                          controller.activeSubscriptions[1].nextPaymentDate,
                    ),
                    SizedBox(height: 16 * s),
                    ActiveSubscriptionCard(
                      prefixIcon: controller.activeSubscriptions[2].icon,
                      iconGradient: LinearGradient(
                        colors: [Color(0xffEC003F), Color(0xffEC003F)],
                      ),
                      title: controller.activeSubscriptions[2].name,
                      plan: controller.activeSubscriptions[2].plan,
                      status: "Trail",
                      price: controller.activeSubscriptions[2].price,
                      unit: "/mo",
                      nextPaymentDate:
                          controller.activeSubscriptions[2].nextPaymentDate,
                    ),
                    SizedBox(height: 45 * s),
                    BundleAndSavings(),
                    SizedBox(height: 45 * s),
                    PaymentAndBilling(),
                    SizedBox(height: 45 * s),
                    BillingHistory(),
                    SizedBox(height: 45 * s,),
                    DiscoverMore(),
                    SizedBox(height: 45 * s,),
                    DataProtectedWidget()
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
