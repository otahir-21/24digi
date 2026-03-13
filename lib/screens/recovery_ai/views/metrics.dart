import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/today_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/profile_settings.dart';
import 'package:kivi_24/screens/recovery_ai/views/setting_screen.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/form_label.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';
import 'package:kivi_24/widgets/custom_text_field.dart';

import '../../../widgets/header.dart';

class Metrics extends StatelessWidget {
  Metrics({super.key});

  final controller = Get.put(TodayGoalController());

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
                  RecoveryHeaderWidget(onBackTap: () => Get.back()),
                  SizedBox(height: 30 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 30 * s),
                        Text(
                          "Manual Metrics",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 24 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        CustomCard(
                          borderColor: Color(0xffC084FC),
                          backgroundColor: Color(0xff151B20),
                          title:
                              "Enter daily metrics manually. This replaces 24DIGI bracelet sync for now.",
                        ),
                        SizedBox(height: 45 * s),
                        FormLabel("Date (YYY-MM-DD)"),
                        CustomTextField(hintText: "2026-02-23"),
                        SizedBox(height: 33 * s),
                        FormLabel("Resting heart rate"),
                        CustomTextField(hintText: "60"),
                        SizedBox(height: 33 * s),
                        FormLabel("HRV"),
                        CustomTextField(hintText: "45"),
                        SizedBox(height: 33 * s),
                        FormLabel("Sleep Duration (hours)"),
                        CustomTextField(hintText: "7.5"),
                        SizedBox(height: 33 * s),
                        FormLabel("Sleep Quality (0-100)"),
                        CustomTextField(hintText: "35"),
                        SizedBox(height: 33 * s),
                        FormLabel("Sp02"),
                        CustomTextField(hintText: "98"),
                        SizedBox(height: 33 * s),
                        FormLabel("Steps"),
                        CustomTextField(hintText: "6500"),
                        SizedBox(height: 45 * s),
                        PrimaryButton(
                          onTap: () {
                            Get.to(() => ProfileSettings());
                          },
                          title: "Save",
                        ),
                        SizedBox(height: 20 * s),
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
