import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/issue_select_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/data_front.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/bottom_border_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/static_option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/subscription_status.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../widgets/option_tile.dart';
import '../widgets/primary_button.dart';

class IssueSelect extends StatelessWidget {
  IssueSelect({super.key});

  final controller = Get.put(IssueSelectController());

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
                  const DigiPillHeader(),
                  SizedBox(height: 30 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 30 * s),
                        Text(
                          "Choose a recovery path and track your progress.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 16 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        SizedBox(height: 45 * s),
                        OptionTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DataFront(),
                              ),
                            );
                          },
                          backgroundColor: Color(0xffC084FC),
                          titleColor: Color(0xff151B20),
                          titleFontSize: 24 * s,
                          borderRadius: 15 * s,
                          borderColor: Color(0xffC084FC),
                          showPrefix: false,
                          descriptionFontSize: 16 * s,
                          descriptionColor: Color(0xff151B20),
                          title: "Get recovery plan",
                          titleFontWeight: FontWeight.w700,
                          isSelected: false,
                          icon: "asset/icon/maki_arrow.png",
                          showSuffixIcon: true,
                          description: "Sport,Medical, Phychological",
                        ),
                        SizedBox(height: 45 * s),
                        Row(
                          spacing: 12 * s,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BottomBorderChip(title: "MY PLAN", onTap: () {}),
                            BottomBorderChip(
                              title: "0% COMPLETE",
                              onTap: () {},
                            ),
                          ],
                        ),
                        SizedBox(height: 45 * s),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Recovery Categories",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: "HelveticaNeue",
                                  fontSize: 24 * s,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xffEAF2F5),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 78 * s,
                              child: PrimaryButton(
                                title: "Open",
                                borderColor: Color(0xFFC084FC),
                                height: 40 * s,
                                fontSize: 14 * s,
                                borderRadius: 10 * s,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15 * s),
                        Row(
                          spacing: 12 * s,
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
                        SizedBox(height: 45 * s),
                        Text(
                          "Recovery Status",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        CustomCard(
                          title: "No Active Plan",
                          description:
                              "Create a plan to start tracking progress",
                          titleFontSize: 18 * s,
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffEAF2F5),
                          showDescription: true,
                        ),
                        SizedBox(height: 45 * s),
                        Text(
                          "Subscription",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        SubscriptionStatusWidget(
                          status: controller.subscriptionStatus.status,
                          painAccess: controller.subscriptionStatus.painAccess,
                          periodEnd: controller.subscriptionStatus.periodEnd,
                          message: controller.subscriptionStatus.message,
                        ),
                        SizedBox(height: 45 * s),
                        Text(
                          "Today Metrics",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        CustomCard(
                          title: "No metrics yet",
                          description:
                              "Add manual metrics to improve plan recommendations.",
                          titleFontSize: 18 * s,
                          titleFontWeight: FontWeight.w700,
                          fontColor: Color(0xffEAF2F5),
                          showDescription: true,
                        ),
                        SizedBox(height: 45 * s),
                        Row(
                          spacing: 12 * s,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            BottomBorderChip(
                              title: "MY PLAN",
                              onTap: () {},
                              width: (MediaQuery.of(context).size.width / 3) -
                                  (20 * s),
                              height: 57 * s,
                              fontSize: 14 * s,
                            ),
                            BottomBorderChip(
                              title: "METRICS",
                              onTap: () {},
                              width:
                                  (MediaQuery.of(context).size.width / 3) - 20,
                              height: 57 * s,
                              fontSize: 14 * s,
                            ),
                            BottomBorderChip(
                              title: "SETTINGS",
                              onTap: () {},
                              width:
                                  (MediaQuery.of(context).size.width / 3) - 20,
                              height: 57 * s,
                              fontSize: 14 * s,
                            ),
                          ],
                        ),
                        SizedBox(height: 15 * s),
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
