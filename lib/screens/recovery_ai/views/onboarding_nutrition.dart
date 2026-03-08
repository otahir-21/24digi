import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gradient_option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/lemon_lime_button.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gradient_option_chip.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

import '../../../widgets/header.dart';
import '../controllers/onboarding_nutrition_controller.dart';

class OnboardingNutrition extends StatelessWidget {
  OnboardingNutrition({super.key});

  final controller = Get.put(OnboardingNutritionController());

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
                          "Nutrition Profile",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20),
                        DescriptionWidget(
                          backgroundColor: Color(0xff1C242B),
                          borderColor: Color(0xff1C242B),
                          text:
                              "Help out AI build your perfect menu. Select any allergies or intolerances.",
                        ),
                        SizedBox(height: 20),
                        const Text(
                          "Food Allergies",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: controller.allergiesOptions.map((option) {
                            return Obx(
                              () => GradientOptionChip(
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.selectChip(option),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 20,),
                        GradientBorderWrapper(
                          innerColor: Color(0xff000300),
                          child: Center(
                            child: Text(
                              "Other..",
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xffA8B3BA),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20,),
                        ...controller.dietaryOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(
                              () => GradientOptionTile(
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 20,),
                        Text(
                          "Private & secure. You can update this later.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffA8B3BA),
                          ),
                        ),
                        SizedBox(height: 16,),
                        LemonLimeButton()
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
