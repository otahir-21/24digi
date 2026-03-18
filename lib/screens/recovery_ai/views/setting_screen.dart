import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/setting_screen_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/onboarding_health.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gender_widget.dart';
import 'package:kivi_24/widgets/custom_gradient_textfield.dart';
import 'package:provider/provider.dart';

import 'package:kivi_24/api/models/profile_models.dart';
import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../widgets/primary_button.dart';

class SettingScreen extends StatelessWidget {
  final controller = Get.put(SettingScreenController());

  SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final auth = context.watch<AuthProvider>();
    controller.maybeInitFromProfile(auth.profile);
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
                  SizedBox(height: 23 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        CustomCard(
                          title:
                              "This help AI understand your starting fitness level, You can update it anytime.",
                        ),
                        Text(
                          "Name",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        CustomGradientTextField(
                          hintText: "Your Name",
                          controller: controller.nameCtrl,
                        ),
                        SizedBox(height: 58 * s),
                        Text(
                          "Date of Birth",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        CustomGradientTextField(
                          hintText: "YYYY-MM-DD",
                          controller: controller.dobCtrl,
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            size: 25,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        SizedBox(height: 40 * s),
                        Row(
                          children: [
                            // Height Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Height",
                                    style: TextStyle(
                                      fontFamily: "HelveticaNeue",
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffEAF2F5),
                                    ),
                                  ),
                                  CustomGradientTextField(
                                    hintText: "0",
                                    controller: controller.heightCtrl,
                                    suffixIcon: Text(
                                      "cm",
                                      style: TextStyle(
                                        fontFamily: "HelveticaNeue",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14 * s,
                                        color: Color(0xFF6B7680),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: 20 * s),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Weight",
                                    style: TextStyle(
                                      fontFamily: "HelveticaNeue",
                                      fontSize: 18 * s,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffEAF2F5),
                                    ),
                                  ),
                                  CustomGradientTextField(
                                    hintText: "0",
                                    controller: controller.weightCtrl,
                                    suffixIcon: Text(
                                      "kg",
                                      style: TextStyle(
                                        fontFamily: "HelveticaNeue",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14 * s,
                                        color: Color(0xFF6B7680),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20 * s),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 60 * s,
                          children: [
                            Column(
                              spacing: 12 * s,
                              children: [
                                GenderWidget(
                                  image: "assets/fonts/female.png",
                                  selectedGender: controller.selectedGender,
                                  value: 'female',
                                  onTap: () => controller.selectedGender.value =
                                      "female",
                                ),
                                Text(
                                  "Female",
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffEAF2F5),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              spacing: 12 * s,
                              children: [
                                GenderWidget(
                                  image: "assets/fonts/male.png",
                                  selectedGender: controller.selectedGender,
                                  value: 'male',
                                  onTap: () =>
                                      controller.selectedGender.value = "male",
                                ),
                                Text(
                                  "Male",
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffEAF2F5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 60 * s),
                        PrimaryButton(
                          onTap: () async {
                            final name = controller.nameCtrl.text.trim();
                            final dob = controller.dobCtrl.text.trim();
                            final heightStr = controller.heightCtrl.text.trim();
                            final weightStr = controller.weightCtrl.text.trim();
                            final heightCm = double.tryParse(heightStr);
                            final weightKg = double.tryParse(weightStr);

                            await auth.updateBasic(
                              ProfileBasicPayload(
                                name: name.isEmpty ? null : name,
                                dateOfBirth: dob.isEmpty ? null : dob,
                                heightCm: heightCm,
                                weightKg: weightKg,
                                gender: controller.selectedGender.value.isEmpty
                                    ? null
                                    : controller.selectedGender.value,
                              ),
                            );

                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OnboardingHealth(),
                              ),
                            );
                          },
                          title: "CONTINUE",
                        ),
                        SizedBox(height: 12 * s),
                        Text(
                          textAlign: TextAlign.center,
                          "By creating an account, you agree to sharing basic health and activity data when you connect a 24DIGI device.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        SizedBox(height: 30 * s),
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
