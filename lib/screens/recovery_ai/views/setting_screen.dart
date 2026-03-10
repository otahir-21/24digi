import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gender_widget.dart';
import 'package:kivi_24/widgets/custom_gradient_textfield.dart';

import '../../../widgets/header.dart';
import '../widgets/primary_button.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

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
                        const SizedBox(height: 20),
                        CustomCard(title: "This help AI understand your starting fitness level, You can update it anytime."),
                        const Text(
                          "Name",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        CustomGradientTextField(hintText: "Your Name"),
                        SizedBox(height: 58),
                        const Text(
                          "Date of Birth",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        CustomGradientTextField(
                          hintText: "DD/MM/YYYY",
                          suffixIcon: Icon(
                            Icons.calendar_month,
                            size: 25,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        SizedBox(height: 58),
                        Row(
                          children: [
                            // Height Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Height",
                                    style: TextStyle(
                                      fontFamily: "HelveticaNeue",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffEAF2F5),
                                    ),
                                  ),
                                  const CustomGradientTextField(
                                    hintText: "0",
                                    suffixIcon: Text(
                                      "cm",
                                      style: TextStyle(
                                        fontFamily: "HelveticaNeue",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xFF6B7680),
                                        height: 1.0, // line-height 100%
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Weight",
                                    style: TextStyle(
                                      fontFamily: "HelveticaNeue",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xffEAF2F5),
                                    ),
                                  ),
                                  const CustomGradientTextField(
                                    hintText: "0",
                                    suffixIcon: Text(
                                      "kg",
                                      style: TextStyle(
                                        fontFamily: "HelveticaNeue",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xFF6B7680),
                                        height: 1.0, // line-height 100%
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 60,
                          children: [
                            Column(
                              spacing: 12,
                              children: [
                                GenderWidget(image: "assets/fonts/female.png"),
                                const Text(
                                  "Female",
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffEAF2F5),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              spacing: 12,
                              children: [
                                GenderWidget(image: "assets/fonts/male.png",),
                                const Text(
                                  "Male",
                                  style: TextStyle(
                                    fontFamily: "HelveticaNeue",
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xffEAF2F5),
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ),
                        SizedBox(height: 60,),
                        PrimaryButton(title: "CONTINUE"),
                        SizedBox(height: 12,),
                        const Text(
                          textAlign: TextAlign.center,
                          "By creating an account, you agree to sharing basic health and activity data when you connect a 24DIGI device.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffA8B3BA),
                          ),
                        ),
                        const SizedBox(height: 30),
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
