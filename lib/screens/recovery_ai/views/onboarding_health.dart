import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_health_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/onboarding_nutrition.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gradient_option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/lemon_lime_button.dart';

import '../../../widgets/header.dart';

class OnboardingHealth extends StatelessWidget {
  OnboardingHealth({super.key});

  final controller = Get.put(OnboardingHealthController());

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
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Do you have any health considerations?",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20,),
                        DescriptionWidget(
                          backgroundColor: Color(0xff1C242B),
                          borderColor: Color(0xff1C242B),
                          prefixIcon: Image.asset(
                            "assets/icons/privacy_lock.png",
                          ),
                          text:
                              "Sharing this helps our AI personalize insights and alerts adjust intensity and recommendations safely. Your data is encrypted and private. This is not a medical diagnosis.",
                        ),
                        SizedBox(height: 26,),
                        ...controller.options.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(() => GradientOptionTile(
                              title: option.title,
                              isSelected: option.isSelected.value,
                              onTap: () => controller.toggleSelection(option),
                            ))
                          );
                        }),
                        LemonLimeButton(onTap: () => Get.to(OnboardingNutrition()),)
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
