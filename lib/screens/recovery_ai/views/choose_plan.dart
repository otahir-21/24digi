import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/choose_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/my_plan.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/subscription_plan_card.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../widgets/primary_button.dart';

class ChoosePlan extends StatelessWidget {
  ChoosePlan({super.key});

  final controller = Get.put(ChoosePlanController());

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size.width / 440;
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
              padding:  EdgeInsets.all(16 * s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DigiPillHeader(),
                  SizedBox(height: 20 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 30),
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 28.0 * s),
                          child: Text(
                            "Choose Plan Type",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24 * s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                         SizedBox(height: 15 * s),
                        Padding(
                          padding:  EdgeInsets.symmetric(horizontal: 28.0 * s),
                          child:  Text(
                            "No active subscription. Subscription is required to create a plan",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffA8B3BA),
                            ),
                          ),
                        ),
                        SizedBox(height: 45 * s,),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.symmetric( vertical: 10 * s),
                          itemCount: controller.plans.length,
                          separatorBuilder: (context, index) =>  SizedBox(height: 45 * s),
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
                        SizedBox(height: 45 * s,),
                        PrimaryButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyPlan(),
                              ),
                            );
                          },
                          title: "Subscribe & Continue",
                        ),
                         SizedBox(height: 20 * s),
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
