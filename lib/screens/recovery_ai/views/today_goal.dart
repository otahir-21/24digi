import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/today_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/TitledActionCard.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/plain_scale.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';
import 'package:kivi_24/widgets/custom_text_field.dart';

import '../../../widgets/header.dart';
import '../widgets/option_chip.dart';

class TodayGoal extends StatelessWidget {
  TodayGoal({super.key});

  final controller = Get.put(TodayGoalController());

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
                            "Initial Relief & Rest",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45),
                        Center(
                          child: const Text(
                            "Today's Goal",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffC084FC),
                            ),
                          ),
                        ),
                        SizedBox(height: 45),
                        const Text(
                          "Reduce initial soreness and begin gentle mobility",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffC084FC),
                          ),
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          backgroundColor: Color(0xff151B20),
                          title: "Today's Activities",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          showDescription: true,
                          description: controller.activities,
                          descriptionFontSize: 16,
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          backgroundColor: Color(0xff151B20),
                          title: "Symptom management",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          padding: EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          showDescription: true,
                          description: controller.symptomManagement,
                          descriptionFontSize: 18,
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          backgroundColor: Color(0xff151B20),
                          title: "What to avoid",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          padding: EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          showDescription: true,
                          description: controller.whatToAvoid,
                          descriptionFontSize: 18,
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          backgroundColor: Color(0xff151B20),
                          title: "Pain Level (0-10)",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          trailing: PlainStaticScale(),
                          showDescription: true,
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          backgroundColor: Color(0xff151B20),
                          title: "Energy level (0-10)",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          trailing: PlainStaticScale(),
                          showDescription: true,
                        ),
                        SizedBox(height: 45),
                        TitledActionCard(
                          title: "Mode",
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: controller.statusOptions.map((status) {
                              return Obx(
                                () => OptionChip(
                                  height: 36,
                                  fontSize: 16,
                                  title: status,
                                  isSelected:
                                      controller.selectedStatus.value == status,
                                  onTap: () => controller.updateStatus(status),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 45),
                        TitledActionCard(
                          title: "How are you feeling today",
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: controller.feelingsOptions.map((status) {
                              return Obx(
                                () => OptionChip(
                                  height: 36,
                                  fontSize: 16,
                                  title: status,
                                  isSelected:
                                      controller.selectedFeeling.value ==
                                      status,
                                  onTap: () => controller.updateFeeling(status),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 45),
                        TitledActionCard(
                          title: "Notes",
                          child: CustomTextField(
                            hintText: "Add note for today...",
                            maxLines: null,
                            minLines: 5,
                            borderColor: Color(0xff151B20),
                            backgroundColor: Color(0xff151B20),
                          ),
                        ),
                        SizedBox(height: 45,),
                        PrimaryButton(title: "Mark Day Complete"),
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
