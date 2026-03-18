import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/views/calibrating.dart';
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
              padding: EdgeInsets.all(16 * s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RecoveryHeaderWidget(
                    onBackTap: () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(height: 30 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 30 * s),
                          Text(
                          "Lets calibrate your profile.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 28* s),
                        CustomCard(
                          backgroundColor: Color(0xff1C242B),
                          borderColor: Color(0xff1C242B),
                          title:
                              "This helps our AI tailor challenges to your current activity level and preferences.",
                        ),
                        SizedBox(height: 45* s),
                        ...controller.activeLevelOptions.map((option) {
                          return Padding(
                            padding:   EdgeInsets.only(bottom: 11* s),
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
                        SizedBox(height: 45* s),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10* s,
                                mainAxisSpacing: 10* s,
                                mainAxisExtent: 55* s,
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
                        SizedBox(height: 45 * s),
                        Text(
                          "Week Frequency",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18* s,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20* s),
                        StaticFrequencyScale(),
                        SizedBox(height: 45* s),
                        DropDown(),
                        SizedBox(height: 45* s),
                        LemonLimeButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Calibrating(),
                              ),
                            );
                          },
                        ),
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
