import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/views/onboarding_activity.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gradient_option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/lemon_lime_button.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gradient_option_chip.dart';
import 'package:kivi_24/widgets/gradient_border_wrapper.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../controllers/onboarding_nutrition_controller.dart';

class OnboardingNutrition extends StatelessWidget {
  OnboardingNutrition({super.key});

  final controller = Get.put(OnboardingNutritionController());

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
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
              padding:   EdgeInsets.all(16* s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DigiPillHeader(),
                  SizedBox(height: 30 * s,),
                  Expanded(
                    child: ListView(
                      children: [
                          SizedBox(height: 30* s),
                          Text(
                          "Nutrition Profile",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22* s,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 28* s),
                        CustomCard(
                          backgroundColor: Color(0xff1C242B),
                          borderColor: Color(0xff1C242B),
                          title:
                              "Help out AI build your perfect menu. Select any allergies or intolerances.",
                        ),
                        SizedBox(height: 28* s),
                          Text(
                          "Food Allergies",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 18* s,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 28* s),
                        Wrap(
                          spacing: 12* s,
                          runSpacing: 12* s,
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
                        SizedBox(height: 33* s,),
                        GradientBorderWrapper(
                          innerColor: Color(0xff000300),
                          child: Center(
                            child: Text(
                              "Other..",
                              style: TextStyle(
                                fontFamily: "HelveticaNeue",
                                fontSize: 18* s,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xffA8B3BA),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28* s,),
                        Text(
                          "Dietary Goals",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22* s,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 28* s,),
                        ...controller.dietaryOptions.map((option) {
                          return Padding(
                            padding:  EdgeInsets.only(bottom: 26* s),
                            child: Obx(
                              () => GradientOptionTile(
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 59* s,),
                        Center(
                          child: Text(
                            "Private & secure. You can update this later.",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 12* s,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xffA8B3BA),
                            ),
                          ),
                        ),
                        SizedBox(height: 16*  s,),
                        LemonLimeButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OnboardingActivity(),
                              ),
                            );
                          },
                        )
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
