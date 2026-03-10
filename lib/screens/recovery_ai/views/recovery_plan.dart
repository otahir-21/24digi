import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/date_wise_recovery_card.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';

import '../../../widgets/header.dart';
import '../widgets/option_chip.dart';

class RecoveryPlan extends StatelessWidget {
  RecoveryPlan({super.key});

  final controller = Get.put(RecoveryPlanController());

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
                            "Neck Muscle Soreness Recovery Plan",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: controller.recoveryCategory.map((option) {
                            return Obx(
                              () => OptionChip(
                                borderRadius: 25,
                                height: 37,
                                fontSize: 16,
                                horizontalPadding: 12,
                                fontWeight: FontWeight.w700             ,
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.selectChip(option),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 45),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 23,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffA8B3BA),
                              width: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            color: const Color(0xff151B20).withOpacity(0.2),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: controller.recoveryPlan.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 45),
                            // Space between cards
                            itemBuilder: (context, index) {
                              final plan = controller.recoveryPlan[index];
                              return DayWiseRecoveryCard(
                                title: plan.dayTitle,
                                goal: plan.goal,
                                benefits: plan.benefits,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          title: "Safety note",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          showDescription: true,
                          description:
                              "Avoid any activities that strain the neck or involve heavy lifting",
                          descriptionFontSize: 18,
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          title: "Warning signs",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          padding: EdgeInsets.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          showDescription: true,
                          descriptionList: [
                            "Increase pain or stiffness",
                            "Reduce mobility",
                          ],
                          descriptionFontSize: 18,
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          title: "Overall Strategies",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24,
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35,
                            vertical: 20,
                          ),
                          showDescription: true,
                          description: controller.description,
                          descriptionFontSize: 18,
                        ),
                        SizedBox(height: 45),
                        PrimaryButton(title: "Day by Day Plan"),

                        SizedBox(height: 45),
                        PrimaryButton(title: "Start this plan"),

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
