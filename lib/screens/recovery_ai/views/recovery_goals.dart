import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile_circle_icon.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/plain_scale.dart';

import '../../../widgets/header.dart';
import '../widgets/primary_button.dart';

class RecoveryGoals extends StatelessWidget {
  RecoveryGoals({super.key});

  final controller = Get.put(RecoveryGoalController());

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

                        const Text(
                          "Recovery Goal",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "This helps tailor your recovery plan and recommendations.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Temporary Plan",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 36),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double spacing = 10.0;
                            final double itemWidth =
                                (constraints.maxWidth - spacing) / 2;
                            final int totalItems =
                                controller.plansOptions.length;

                            return Wrap(
                              spacing: 10,
                              runSpacing: 20,
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
                        const SizedBox(height: 60),
                        const Text(
                          "Current Pain Level",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 30),
                        PlainStaticScale(),
                        SizedBox(height: 58),
                        const Text(
                          "Main Area Concern",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 25),

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
                        PrimaryButton(title: "Continue"),
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
