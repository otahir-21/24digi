import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/today_goal_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/description_widget.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_tile.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/primary_button.dart';

import '../../../widgets/header.dart';

class ProfileSettings extends StatelessWidget {
  ProfileSettings({super.key});

  final controller = Get.put(TodayGoalController());

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
                        const SizedBox(height: 30),
                        Center(
                          child: const Text(
                            "Settings",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45),
                        CustomCard(
                          titleFontSize: 24,
                          titleFontWeight: FontWeight.w500,
                          title:
                              "Manage your profile, recovery tools, and subscriptions",
                        ),
                        SizedBox(height: 45),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25,
                          verticalPadding: 20,
                          title: "Edit profile",
                          titleFontSize: 18,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Update personal and health information",
                        ),
                        SizedBox(height: 15),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25,
                          verticalPadding: 20,
                          title: "My Plans",
                          titleFontSize: 18,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Active and past recovery plans",
                        ),
                        SizedBox(height: 15),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25,
                          verticalPadding: 20,
                          title: "Subscriptions",
                          titleFontSize: 18,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Plan status and billing",
                        ),
                        SizedBox(height: 45),
                        Center(
                          child: const Text(
                            "Settings",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45,),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25,
                          verticalPadding: 20,
                          title: "Manual Metrics Entry",
                          titleFontSize: 18,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Add on edit metrics",
                        ),
                        SizedBox(height: 45,),
                        PrimaryButton(title: "Logout"),
                        const SizedBox(height: 20),
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
