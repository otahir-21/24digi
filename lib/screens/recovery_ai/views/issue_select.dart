import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/issue_select_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/calibrating_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_health_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_nutrition_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/setting_screen_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/recovery_ai_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/data_front.dart';
import 'package:kivi_24/screens/recovery_ai/views/recovery_goals.dart';
import 'package:kivi_24/screens/recovery_ai/views/setting_screen.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/bottom_border_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/static_option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/subscription_status.dart';
import 'package:provider/provider.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import 'my_plan.dart';
import '../widgets/option_tile.dart';
import '../widgets/primary_button.dart';

class IssueSelect extends StatelessWidget {
  IssueSelect({super.key});

  final controller = Get.put(IssueSelectController());
  final recoveryAiController = Get.put(RecoveryAiController());

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final auth = context.watch<AuthProvider>();
    final profile = auth.profile;
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
                            final hasBasicProfile = profile != null &&
                                profile.name != null &&
                                (profile.dateOfBirth != null &&
                                    profile.dateOfBirth!.isNotEmpty) &&
                                profile.heightCm != null &&
                                profile.weightKg != null &&
                                profile.gender != null &&
                                profile.gender!.isNotEmpty;

                            if (hasBasicProfile) {
                              // Best-effort: skip the Recovery AI onboarding UI
                              // screens and reuse data from the profile that was
                              // already collected during login.
                              final settingCtrl =
                                  Get.put(SettingScreenController());
                              settingCtrl.maybeInitFromProfile(profile);

                              final healthCtrl =
                                  Get.put(OnboardingHealthController());
                              final nutritionCtrl =
                                  Get.put(OnboardingNutritionController());
                              final calibratingCtrl =
                                  Get.put(CalibratingController());
                              final goalsCtrl =
                                  Get.put(RecoveryGoalController());

                              // Health concerns selection.
                              for (final opt in healthCtrl.options) {
                                opt.isSelected.value = false;
                              }
                              final healthList = profile.healthConsiderations ?? [];
                              if (healthList.isEmpty) {
                                for (final opt in healthCtrl.options) {
                                  if (opt.title == "None/Prefer not to say") {
                                    opt.isSelected.value = true;
                                    break;
                                  }
                                }
                              } else {
                                final lower =
                                    healthList.map((e) => e.toLowerCase());
                                bool has(String k) =>
                                    lower.any((x) => x.contains(k));

                                if (has("blood pressure") || has("pressure")) {
                                  for (final opt in healthCtrl.options) {
                                    if (opt.title ==
                                        "Blood Pressure Concern") {
                                      opt.isSelected.value = true;
                                      break;
                                    }
                                  }
                                } else if (has("sleep") || has("recovery")) {
                                  for (final opt in healthCtrl.options) {
                                    if (opt.title == "Sleep and Recovery") {
                                      opt.isSelected.value = true;
                                      break;
                                    }
                                  }
                                } else if (has("breath") || has("lung")) {
                                  for (final opt in healthCtrl.options) {
                                    if (opt.title == "Breathing or Lungs") {
                                      opt.isSelected.value = true;
                                      break;
                                    }
                                  }
                                } else if (has("sugar") ||
                                    has("diabetes") ||
                                    has("metabolism")) {
                                  for (final opt in healthCtrl.options) {
                                    if (opt.title ==
                                        "Blood Sugar and metabolism") {
                                      opt.isSelected.value = true;
                                      break;
                                    }
                                  }
                                } else {
                                  for (final opt in healthCtrl.options) {
                                    if (opt.title == "Health Condition") {
                                      opt.isSelected.value = true;
                                      break;
                                    }
                                  }
                                }
                              }

                              // Allergies selection.
                              for (final opt in nutritionCtrl.allergiesOptions) {
                                opt.isSelected.value = false;
                              }
                              final foodAllergies = profile.foodAllergies ?? [];
                              if (foodAllergies.isEmpty) {
                                for (final opt in nutritionCtrl.allergiesOptions) {
                                  if (opt.title == "None") {
                                    opt.isSelected.value = true;
                                    break;
                                  }
                                }
                              } else {
                                for (final allergy in foodAllergies) {
                                  final al = allergy.toLowerCase();
                                  for (final opt in nutritionCtrl.allergiesOptions) {
                                    if (opt.title.toLowerCase() == al) {
                                      opt.isSelected.value = true;
                                      break;
                                    }
                                  }
                                }
                              }

                              // Dietary selection.
                              for (final opt in nutritionCtrl.dietaryOptions) {
                                opt.isSelected.value = false;
                              }
                              final dietaryGoal =
                                  profile.dietaryGoal?.toLowerCase() ?? '';
                              if (dietaryGoal.isNotEmpty) {
                                for (final opt in nutritionCtrl.dietaryOptions) {
                                  final t = opt.title.toLowerCase();
                                  final firstToken = t.split(' ').first;
                                  if (dietaryGoal.contains(firstToken)) {
                                    opt.isSelected.value = true;
                                    break;
                                  }
                                }
                              }

                              // Mobility (default) + daily activity best-effort mapping.
                              for (final m in calibratingCtrl.mobilityOptions) {
                                m.isSelected.value = false;
                              }
                              for (final m in calibratingCtrl.mobilityOptions) {
                                if (m.title == "Fully Active") {
                                  m.isSelected.value = true;
                                  break;
                                }
                              }
                              for (final d in calibratingCtrl.dailyActivityOptions) {
                                d.isSelected.value = false;
                              }
                              final al = profile.activityLevel?.toLowerCase() ?? '';
                              if (al.contains('moderate')) {
                                for (final d in calibratingCtrl.dailyActivityOptions) {
                                  if (d.title == "Moderate Activity") {
                                    d.isSelected.value = true;
                                    break;
                                  }
                                }
                              } else if (al.contains('light')) {
                                for (final d in calibratingCtrl.dailyActivityOptions) {
                                  if (d.title == "Light Activity") {
                                    d.isSelected.value = true;
                                    break;
                                  }
                                }
                              } else {
                                for (final d in calibratingCtrl.dailyActivityOptions) {
                                  if (d.title == "Sedentary") {
                                    d.isSelected.value = true;
                                    break;
                                  }
                                }
                              }

                              // Primary goal selection.
                              for (final p in goalsCtrl.plansOptions) {
                                p.isSelected.value = false;
                              }
                              final pg = profile.primaryGoal?.toLowerCase() ?? '';
                              bool selectGoal(String title) {
                                for (final p in goalsCtrl.plansOptions) {
                                  if (p.title.toLowerCase() == title.toLowerCase()) {
                                    p.isSelected.value = true;
                                    return true;
                                  }
                                }
                                return false;
                              }

                              if (pg.contains('pain') || pg.contains('reduce')) {
                                selectGoal("Manage Chronic Pain");
                              } else if (pg.contains('sleep')) {
                                selectGoal("Improve sleep Quality");
                              } else if (pg.contains('stress') || pg.contains('anxiety')) {
                                selectGoal("Reduce Stress/Anxiety");
                              } else if (pg.contains('surgery') || pg.contains('post')) {
                                selectGoal("Post-Surgery Recovery");
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecoveryGoals(),
                                ),
                              );
                              return;
                            }

                            // First-time: go through onboarding screens.
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SettingScreen(),
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
                            BottomBorderChip(
                              title: "MY PLAN",
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MyPlan(),
                                  ),
                                );
                              },
                            ),
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
                              onTap: () {
                                // Matches RecoveryAiApi mapping: PHYSICAL -> Sport
                                recoveryAiController.selectedRecoveryOption.value =
                                    "PHYSICAL";
                              },
                            ),
                            StaticOptionChip(
                              title: "Medical",
                              description: "Surgery, Pain, Rehab",
                              onTap: () {
                                // Matches RecoveryAiApi mapping: HEALTH -> Medical
                                recoveryAiController.selectedRecoveryOption.value =
                                    "HEALTH";
                              },
                            ),
                            StaticOptionChip(
                              title: "Psych",
                              description: "Stress,anxiety,Sleep",
                              onTap: () {
                                // Matches RecoveryAiApi mapping: MENTAL -> Psychological
                                recoveryAiController.selectedRecoveryOption.value =
                                    "MENTAL";
                              },
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
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MyPlan(),
                                  ),
                                );
                              },
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
