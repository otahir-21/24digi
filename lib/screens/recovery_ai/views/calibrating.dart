import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/calibrating_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';

import '../../../widgets/header.dart';

class Calibrating extends StatelessWidget {
  Calibrating({super.key});

  final controller = Get.put(CalibratingController());

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
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Lets calibrate your profile.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomCard(
                          title:
                              "This helps our AI tailor recommendations to your current mobility and daily activity.",
                        ),
                        SizedBox(height: 40),
                        const Text(
                          textAlign: TextAlign.center,
                          "Mobility Level",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20),
                        ...controller.mobilityOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(
                              () => OptionTile(
                                backgroundColor: Color(0xff151B20),
                                borderColor: Color(0xff151B20),
                                borderRadius: 15,
                                titleFontSize: 24,
                                titleColor: Color(0xffA8B3BA),
                                descriptionFontSize: 18,
                                showPrefix: false,
                                verticalSpace: 12,
                                title: option.title,
                                description: option.description,
                                icon: option.icon,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 20),
                        const Text(
                          textAlign: TextAlign.center,
                          "Daily Activity Level",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20),
                        ...controller.dailyActivityOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 26),
                            child: Obx(
                              () => OptionTile(
                                backgroundColor: Color(0xff151B20),
                                borderColor: Color(0xff151B20),
                                borderRadius: 15,
                                titleFontSize: 24,
                                titleColor: Color(0xffA8B3BA),
                                descriptionFontSize: 18,
                                showPrefix: false,
                                verticalSpace: 12,
                                title: option.title,
                                description: option.description,
                                icon: option.icon,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 40),
                        PrimaryButton(title: "Logout")
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
