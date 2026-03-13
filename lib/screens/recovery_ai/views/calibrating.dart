import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/calibrating_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/recovery_ai_screen.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';

import '../../../widgets/header.dart';

class Calibrating extends StatelessWidget {
  Calibrating({super.key});

  final s = Get.width / 440;
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
              padding: EdgeInsets.all(16 * s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RecoveryHeaderWidget(onBackTap: () => Get.back()),
                  Expanded(
                    child: ListView(
                      children: [
                         SizedBox(height: 20* s),
                         Text(
                          "Lets calibrate your profile.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22 * s,
                            fontWeight: FontWeight.w400,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20),
                        CustomCard(
                          title:
                              "This helps our AI tailor recommendations to your current mobility and daily activity.",
                        ),
                        SizedBox(height: 40* s),
                        Text(
                          textAlign: TextAlign.center,
                          "Mobility Level",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20 * s),
                        ...controller.mobilityOptions.map((option) {
                          return Padding(
                            padding:  EdgeInsets.only(bottom: 26 * s),
                            child: Obx(
                              () => OptionTile(
                                backgroundColor: Color(0xff151B20),
                                borderColor: Color(0xff151B20),
                                borderRadius: 15,
                                titleFontSize: 24 * s,
                                titleColor: Color(0xffA8B3BA),
                                descriptionFontSize: 18 * s,
                                showPrefix: false,
                                verticalSpace: 12 * s,
                                title: option.title,
                                description: option.description,
                                icon: option.icon,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 20 * s),
                         Text(
                          textAlign: TextAlign.center,
                          "Daily Activity Level",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20 * s),
                        ...controller.dailyActivityOptions.map((option) {
                          return Padding(
                            padding:  EdgeInsets.only(bottom: 26 * s),
                            child: Obx(
                              () => OptionTile(
                                backgroundColor: Color(0xff151B20),
                                borderColor: Color(0xff151B20),
                                borderRadius: 15,
                                titleFontSize: 24 * s,
                                titleColor: Color(0xffA8B3BA),
                                descriptionFontSize: 18 * s,
                                showPrefix: false,
                                verticalSpace: 12 * s,
                                title: option.title,
                                description: option.description,
                                icon: option.icon,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 40 * s),
                        PrimaryButton(
                            onTap: () {
                              Get.to(() => RecoveryAiScreen());
                            },
                            title: "Logout")
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
