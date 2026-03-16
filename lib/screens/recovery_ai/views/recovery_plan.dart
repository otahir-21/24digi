import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/today_goal.dart';
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
                        Center(
                          child: Text(
                            "Neck Muscle Soreness Recovery Plan",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24 * s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45 * s),
                        Wrap(
                          spacing: 12 * s,
                          runSpacing: 12 * s,
                          children: controller.recoveryCategory.map((option) {
                            return Obx(
                              () => OptionChip(
                                borderRadius: 25 * s,
                                height: 37 * s,
                                fontSize: 16 * s,
                                horizontalPadding: 12 * s,
                                fontWeight: FontWeight.w700,
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.selectChip(option),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 45 * s),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * s,
                            vertical: 23 * s,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffA8B3BA),
                              width: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(25 * s),
                            color: const Color(0xff151B20).withOpacity(0.2),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(vertical: 10 * s),
                            itemCount: controller.recoveryPlan.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 45 * s),
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
                        SizedBox(height: 45 * s),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          title: "Safety note",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24 * s,
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35 * s,
                            vertical: 20 * s,
                          ),
                          showDescription: true,
                          description:
                              "Avoid any activities that strain the neck or involve heavy lifting",
                          descriptionFontSize: 18 * s,
                        ),
                        SizedBox(height: 45 * s),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          title: "Warning signs",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24 * s,
                          padding: EdgeInsets.symmetric(
                            horizontal: 35 * s,
                            vertical: 20 * s,
                          ),
                          showDescription: true,
                          descriptionList: [
                            "Increase pain or stiffness",
                            "Reduce mobility",
                          ],
                          descriptionFontSize: 18 * s,
                        ),
                        SizedBox(height: 45 * s),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          title: "Overall Strategies",
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffC084FC),
                          titleFontSize: 24 * s,
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35 * s,
                            vertical: 20 * s,
                          ),
                          showDescription: true,
                          description: controller.description,
                          descriptionFontSize: 18 * s,
                        ),
                        SizedBox(height: 45 * s),
                        PrimaryButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => TodayGoal(),
                              ),
                            );
                          },
                          title: "Day by Day Plan",
                        ),

                        SizedBox(height: 45 * s),
                        PrimaryButton(title: "Start this plan"),

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
