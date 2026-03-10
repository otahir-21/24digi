import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/choose_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/subscription_plan_card.dart';

import '../../../widgets/header.dart';
import '../widgets/primary_button.dart';

class ChoosePlan extends StatelessWidget {
  ChoosePlan({super.key});

  final controller = Get.put(ChoosePlanController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/digi_background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.92)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RecoveryHeaderWidget(onBackTap: () => Get.back()),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: const Text(
                            "Choose Plan Type",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: const Text(
                            "No active subscription. Subscription is required to create a plan",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffA8B3BA),
                            ),
                          ),
                        ),
                        SizedBox(height: 45,),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric( vertical: 10),
                          itemCount: controller.plans.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 45), // Space between cards
                          itemBuilder: (context, index) {
                            final plan = controller.plans[index];

                            return Obx(() => SubscriptionPlanCard(
                              title: plan.title,
                              duration: plan.duration,
                              price: plan.price,
                              features: plan.features,
                              isSelected: plan.isSelected.value, // GetX observable
                              onTap: () => controller.selectPlan(plan), // Method to toggle selection
                            ));
                          },
                        ),
                        SizedBox(height: 45,),
                        PrimaryButton(title: "Subscribe & Continue"),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
