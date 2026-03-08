import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile_circle_icon.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/plain_scale.dart';

import '../../../widgets/header.dart';
import '../widgets/option_tile.dart';
import '../widgets/primary_button.dart';

class IssueSelect extends StatelessWidget {
  IssueSelect({super.key});

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
                          "Choose a recovery path and track your progress.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        const SizedBox(height: 30),
                        OptionTile(
                          backgroundColor: Color(0xffC084FC),
                            titleColor: Color(0xff151B20),
                            titleFontSize: 24,
                            borderRadius: 15,
                            borderColor: Color(0xffC084FC),
                            showPrefix: false,
                            descriptionFontSize: 16,
                            title: "Get recovery plan",
                            isSelected: false,
                            onTap: () {},
                            icon: "asset/icon/maki_arrow.png",
                            description: "Sport,Medical, Phychological"),
                        const Text(
                          "Temporary Plan",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 30),

                        LayoutBuilder(
                          builder: (context, constraints) {
                            final double spacing = 10.0;
                            final double itemWidth =
                                (constraints.maxWidth - spacing) / 2;
                            final int totalItems =
                                controller.plansOptions.length;

                            return Wrap(
                              spacing: 20,
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
                        const SizedBox(height: 30),
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
                        SizedBox(height: 40,),
                        const Text(
                          "Main Area Concern",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 30),

                        ...controller.mainConcernOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(
                                  () =>
                                  OptionTileCircleIcon(
                                    title: option.title,
                                    isSelected: option.isSelected.value,
                                    onTap: () =>
                                        controller.toggleSelection(option),
                                  ),
                            ),
                          );
                        }),
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
