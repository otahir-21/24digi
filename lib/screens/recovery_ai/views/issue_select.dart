import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/issue_select_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/bottom_border_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/static_option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/subscription_status.dart';

import '../../../widgets/header.dart';
import '../widgets/option_tile.dart';
import '../widgets/primary_button.dart';

class IssueSelect extends StatelessWidget {
  IssueSelect({super.key});

  final controller = Get.put(IssueSelectController());

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
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        const SizedBox(height: 45),
                        OptionTile(
                          backgroundColor: Color(0xffC084FC),
                          titleColor: Color(0xff151B20),
                          titleFontSize: 24,
                          borderRadius: 15,
                          borderColor: Color(0xffC084FC),
                          showPrefix: false,
                          descriptionFontSize: 16,
                          descriptionColor: Color(0xff151B20),
                          title: "Get recovery plan",
                          titleFontWeight: FontWeight.w700,
                          isSelected: false,
                          onTap: () {},
                          icon: "asset/icon/maki_arrow.png",
                          showSuffixIcon: true,
                          description: "Sport,Medical, Phychological",
                        ),
                        SizedBox(height: 45),
                        Row(
                          spacing: 12,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BottomBorderChip(title: "MY PLAN", onTap: () {}),
                            BottomBorderChip(
                              title: "0% COMPLETE",
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 45),
                        Row(
                          children: [
                            Expanded(
                              child: const Text(
                                "Recovery Categories",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "HelveticaNeue",
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffEAF2F5),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 88,
                              child: PrimaryButton(
                                title: "Open",
                                height: 40,
                                fontSize: 14,
                                borderRadius: 10,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          spacing: 12,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StaticOptionChip(
                              title: "Sports",
                              description: "Soreness, Strain, Cramps",
                              onTap: () {},
                            ),
                            StaticOptionChip(
                              title: "Medical",
                              description: "Surgery, Pain, Rehab",
                              onTap: () {},
                            ),
                            StaticOptionChip(
                              title: "Psych",
                              description: "Stress,anxiety,Sleep",
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 45),
                        Text(
                          "Recovery Status",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 15),
                        CustomCard(
                          title: "No Active Plan",
                          description:
                              "Create a plan to start tracking progress",
                          titleFontSize: 18,
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffEAF2F5),
                          showDescription: true,
                        ),
                        SizedBox(height: 45,),
                        Text(
                          "Subscription",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 15),
                        SubscriptionStatusWidget(
                          status: controller.subscriptionStatus.status,
                          painAccess: controller.subscriptionStatus.painAccess,
                          periodEnd: controller.subscriptionStatus.periodEnd,
                          message: controller.subscriptionStatus.message,
                        ),
                        SizedBox(height: 45),
                        Text(
                          "Today Metrics",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 15),
                        CustomCard(
                          title: "No metrics yet",
                          description:
                              "Add manual metrics to improve plan recommendations.",
                          titleFontSize: 18,
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffEAF2F5),
                          showDescription: true,
                        ),
                        SizedBox(height: 45),
                        Row(
                          spacing: 12,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BottomBorderChip(
                              title: "MY PLAN",
                              onTap: () {},
                              width: (Get.width / 3)-20,
                              height: 57,
                              fontSize: 14,
                            ),
                            BottomBorderChip(
                              title: "METRICS",
                              onTap: () {},
                              width: (Get.width / 3) -20,
                              height: 57,
                              fontSize: 14,
                            ),
                            BottomBorderChip(
                              title: "SETTINGS",
                              onTap: () {},
                              width: (Get.width / 3) -20,
                              height: 57,
                              fontSize: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
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
