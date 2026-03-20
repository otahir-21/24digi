import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/auth/auth_provider.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/onboarding_health_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/onboarding_nutrition.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/gradient_option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/lemon_lime_button.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import 'package:kivi_24/api/models/profile_models.dart';
import 'package:provider/provider.dart';

class OnboardingHealth extends StatelessWidget {
  OnboardingHealth({super.key});

  final controller = Get.put(OnboardingHealthController());

  @override
  Widget build(BuildContext context) {
    final s =UIScale.of(context);
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
              padding:   EdgeInsets.all(16* s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const DigiPillHeader(),
                  SizedBox(height: 30 * s,),
                  Expanded(
                    child: ListView(
                      children: [
                         SizedBox(height: 30* s),
                          Text(
                          "Do you have any health considerations?",
                          style: TextStyle(
                            fontFamily: "HelveticaNeueLight",
                            fontSize: 22* s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 20* s,),
                        CustomCard(
                          backgroundColor: Color(0xff1C242B),
                          borderColor: Color(0xff1C242B),
                          prefixIcon: Image.asset(
                            "assets/icons/privacy_lock.png",
                          ),
                          title:
                              "Sharing this helps our AI personalize insights and alerts adjust intensity and recommendations safely. Your data is encrypted and private. This is not a medical diagnosis.",
                        ),
                        SizedBox(height: 26* s,),
                        ...controller.options.map((option) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 26* s),
                            child: Obx(
                              () => GradientOptionTile(
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.toggleSelection(option),
                              ),
                            ),
                          );
                        }),
                        LemonLimeButton(
                          onTap: () async {
                            final auth = context.read<AuthProvider>();

                            final selected = controller.options
                                .where((o) => o.isSelected.value)
                                .map((o) => o.title)
                                .toList();

                            // Store empty when user selected "None/Prefer not to say".
                            final healthConsiderations = selected.any(
                                    (t) => t.toLowerCase().contains('none'))
                                ? null
                                : (selected.isEmpty ? null : selected);

                            await auth.updateHealth(
                              ProfileHealthPayload(
                                healthConsiderations: healthConsiderations,
                              ),
                            );

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OnboardingNutrition(),
                              ),
                            );
                          },
                        )
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
