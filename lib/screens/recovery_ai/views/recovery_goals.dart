import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/issue_select.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile_circle_icon.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/plain_scale.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../widgets/primary_button.dart';

class RecoveryGoals extends StatelessWidget {
  RecoveryGoals({super.key});

  final controller = Get.put(RecoveryGoalController());

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
              padding: EdgeInsets.all(16* s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DigiPillHeader(),
                    SizedBox(height: 30* s),
                  Expanded(
                    child: ListView(
                      children: [
                          SizedBox(height: 30* s),

                         Text(
                          "Recovery Goal",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24* s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                          SizedBox(height: 15* s),
                        Text(
                          "This helps tailor your recovery plan and recommendations.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18* s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                          SizedBox(height: 40* s),
                        Text(
                          "Temporary Plan",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18* s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                          SizedBox(height: 36* s),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double spacing = 10.0;
                            final double itemWidth =
                                (constraints.maxWidth - spacing) / 2;
                            final int totalItems =
                                controller.plansOptions.length;

                            return Wrap(
                              spacing: 10* s,
                              runSpacing: 20* s,
                              children: List.generate(totalItems, (index) {
                                final plan = controller.plansOptions[index];
                                bool isLastOddItem =
                                    (index == totalItems - 1) &&
                                    (totalItems % 2 != 0);

                                return Obx(() {
                                  return SizedBox(
                                    width: isLastOddItem
                                        ? constraints.maxWidth
                                        : itemWidth,
                                    child: OptionChip(
                                      fontSize: 14* s,
                                      title: plan.title,
                                      isSelected: plan.isSelected.value,
                                      onTap: () => controller.selectChip(plan),
                                    ),
                                  );
                                });
                              }),
                            );
                          },
                        ),
                        SizedBox(height: 60* s),
                          Text(
                          "Current Pain Level",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18* s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                          SizedBox(height: 30* s),
                        PlainStaticScale(
                          selectedIndex: controller.currentPainLevel,
                          onSelect: (val) => controller.currentPainLevel.value = val,
                        ),
                        SizedBox(height: 58* s),
                          Text(
                          "Main Area Concern",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18* s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                            SizedBox(height: 25* s),

                        ...controller.mainConcernOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(
                              () => OptionTileCircleIcon(
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 17),
                        PrimaryButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => IssueSelect(),
                              ),
                            );
                          },
                          title: "Continue",
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
