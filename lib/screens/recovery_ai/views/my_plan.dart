import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/choose_plan_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/recovery_ai_subscription.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/bottom_border_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/subscribe/views/subscription.dart';

import '../../../widgets/header.dart';

class MyPlan extends StatelessWidget {
  MyPlan({super.key});

  final controller = Get.put(ChoosePlanController());

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
              padding:   EdgeInsets.all(16* s),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RecoveryHeaderWidget(
                    onBackTap: () => Navigator.of(context).maybePop(),
                  ),
                    SizedBox(height: 30* s),
                  Expanded(
                    child: ListView(
                      children: [
                         SizedBox(height: 30 * s),
                        Center(
                          child:   Text(
                            "My Plans",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24 * s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45* s),
                        CustomCard(
                          title:
                              "View your plan history. Tap any plan to open the full overview.",
                        ),
                        SizedBox(height: 45* s),
                        CustomCard(
                          title: "No Plans yet",
                          titleFontSize: 24* s,
                          titleFontWeight: FontWeight.w500,
                          fontColor: Color(0xffeaf2f5),
                          showDescription: true,
                          descriptionFontSize: 18*s,
                          description:
                              "• Create a recovery plan to start tracking your progress.",
                          padding: EdgeInsetsGeometry.symmetric(
                            horizontal: 35* s,
                            vertical: 20* s,
                          ),
                        ),
                        SizedBox(height: 45* s),
                        Padding(
                          padding:   EdgeInsets.symmetric(horizontal: 80* s),
                          child: BottomBorderChip(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecoveryAiSubscription(),
                                ),
                              );
                            },
                            title: "Get A Plan",

                            borderRadius: 25* s,
                            fontColor: Color(0xffC084FC),
                            height: 66 * s,
                          ),
                        ),
                          SizedBox(height: 20* s),
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
