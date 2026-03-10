import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/choose_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/bottom_border_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';

import '../../../widgets/header.dart';

class RecoveryAiSubscription extends StatelessWidget {
  RecoveryAiSubscription({super.key});

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
                        Center(
                          child: const Text(
                            "Subscriptions",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          title:
                          "Manage your subscription and billing status",
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          title: "Current Subscription",
                          titleFontSize: 24,
                          titleFontWeight: FontWeight.w500,
                          fontColor: Color(0xffeaf2f5),
                          showDescription: true,
                          description:
                          "Plans\nStatus\nAmount\nRenewal date",
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                        ),
                        SizedBox(height: 45),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          child: BottomBorderChip(
                            title: "UPGRADE",
                            onTap: () {},
                            borderRadius: 25,
                            fontColor: Color(0xffC084FC),
                            height: 66,
                          ),
                        ),
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
