import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recovery_ai_controller.dart';
import '../../../widgets/header.dart';
import '../widgets/primary_button.dart';
import '../widgets/recovery_option_card.dart';

class RecoveryAiScreen extends StatelessWidget {
  RecoveryAiScreen({super.key});

  final controller = Get.put(RecoveryAiController());

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
                  RecoveryHeaderWidget(
                    onBackTap: () => Get.back(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        const SizedBox(height: 30),

                        Center(
                          child: const Text(
                            "Select your recovery path",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          "Choose one or more areas you’d like to focus on for your personalized AI assessment.",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xffA8B3BA),
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// Recovery Options
                        ...controller.recoveryOptions.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 42),
                            child: RecoveryOptionCard(
                              icon: option.icon,
                              title: option.title,
                              heading: option.heading,
                              description: option.description,
                            ),
                          );
                        }).toList(),

                        /// Button
                        PrimaryButton(title: "Continue"),

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
