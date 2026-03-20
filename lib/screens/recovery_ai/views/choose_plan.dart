import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/choose_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/subscription_plan_card.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/recovery_plan.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../widgets/primary_button.dart';
import 'package:kivi_24/services/recovery_ai_api.dart';

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
                            () async {
                              final backendPlanType =
                                  controller.selectedPlanBackendTypeOrNull;
                              if (backendPlanType == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please choose Temporary or Permanent plan before continuing.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              Map<String, dynamic>? resp;
                              try {
                                resp = await RecoveryAiApi.createPlanFromUserFlow(
                                  planType: backendPlanType,
                                  planDurationDays: 5,
                                );
                              } catch (e) {
                                var msg = e.toString();
                                if (msg.startsWith('Exception: ')) {
                                  msg = msg.substring('Exception: '.length);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(msg)),
                                );
                                return;
                              } finally {
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pop(); // close loading dialog
                                }
                              }

                              if (resp == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Failed to generate recovery plan. Please try again.",
                                    ),
                                  ),
                                );
                                return;
                              }

                              final planController = Get.put(
                                RecoveryPlanController(),
                              );
                              planController.setFromAiResponse(resp);

                              if (!context.mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecoveryPlan(),
                                ),
                              );
                            }();
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
