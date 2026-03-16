import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/views/recovery_goals.dart';

import '../../../widgets/header.dart';
import '../controllers/recovery_ai_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/recovery_option_card.dart';

class RecoveryAiScreen extends StatelessWidget {
  RecoveryAiScreen({super.key});

  final controller = Get.put(RecoveryAiController());

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
                  RecoveryHeaderWidget(
                    onBackTap: () => Navigator.of(context).maybePop(),
                  ),
                  SizedBox(height: 30 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 30 * s),

                        Center(
                          child: Text(
                            "Select your recovery path",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24 * s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),

                        SizedBox(height: 30 * s),

                        Text(
                          "Choose one or more areas you’d like to focus on for your personalized AI assessment.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),

                        SizedBox(height: 30 * s),
                        ...controller.recoveryOptions.map((option) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 42 * s),
                            child: RecoveryOptionCard(
                              icon: option.icon,
                              title: option.title,
                              heading: option.heading,
                              description: option.description,
                              onTap: () => controller.selectedRecoveryOption.value = option.title,
                              value: option.title,
                              selectedValue: controller.selectedRecoveryOption,

                            ),
                          );
                        }).toList(),
                        PrimaryButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RecoveryGoals(),
                              ),
                            );
                          },
                          title: "Continue",
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
