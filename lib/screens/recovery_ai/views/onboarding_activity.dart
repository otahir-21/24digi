import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/drop_down.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/frequency_scale.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/lemon_lime_button.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile.dart';
import 'package:kivi_24/widgets/activity_option_chip.dart';

import '../../../widgets/header.dart';
import '../controllers/onboarding_activity_controller.dart';

class OnboardingActivity extends StatelessWidget {
  OnboardingActivity({super.key});

  final controller = Get.put(OnboardingActivityController());

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
                          "Lets calibrate your profile.",
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
                              "This helps our AI tailor challenges to your current activity level and preferences.",
                        ),
                        SizedBox(height: 20),
                        ...controller.activeLevelOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(
                              () => OptionTile(
                                title: option.title,
                                description: option.description,
                                icon: option.icon,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 55,
                              ),
                          itemCount: controller.activities.length,
                          itemBuilder: (context, index) {
                            final activity = controller.activities[index];
                            return Obx(
                              () => ActivityOptionChip(
                                icon: activity.icon,
                                title: activity.title,
                                isSelected: activity.isSelected.value,
                                onTap: () =>
                                    controller.toggleActivity(activity),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 40,),
                        Text(
                          "Week Frequency",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20,),
                        StaticFrequencyScale(),
                        SizedBox(height: 40,),
                        DropDown(),
                        SizedBox(height: 40),
                        LemonLimeButton(),
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
