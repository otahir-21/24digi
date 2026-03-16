import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
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
                          SizedBox(height: 30* s),
                        Center(
                          child:   Text(
                            "Settings",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24* s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45* s),
                        CustomCard(
                          titleFontSize: 24* s,
                          titleFontWeight: FontWeight.w500,
                          title:
                              "Manage your profile, recovery tools, and subscriptions",
                        ),
                        SizedBox(height: 45* s),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25* s,
                          verticalPadding: 20* s,
                          title: "Edit profile",
                          titleFontSize: 18* s,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Update personal and health information",
                        ),
                        SizedBox(height: 15* s),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25* s,
                          verticalPadding: 20* s,
                          title: "My Plans",
                          titleFontSize: 18* s,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Active and past recovery plans",
                        ),
                        SizedBox(height: 15* s),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25* s,
                          verticalPadding: 20* s,
                          title: "Subscriptions",
                          titleFontSize: 18* s,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Plan status and billing",
                        ),
                        SizedBox(height: 45* s),
                        Center(
                          child:   Text(
                            "Metrics",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24* s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45* s,),
                        OptionTile(
                          backgroundColor: Color(0xff151B20),
                          borderColor: Color(0xffC084FC),
                          borderRadius: 25* s,
                          verticalPadding: 20* s,
                          title: "Manual Metrics Entry",
                          titleFontSize: 18* s,
                          titleColor: Color(0xffA8B3BA),
                          suffixIcon: "assets/icons/open_icon.png",
                          showSuffixIcon: true,
                          isSelected: false,
                          onTap: () {},
                          showPrefix: false,
                          icon: "icon",
                          description: "Add on edit metrics",
                        ),
                        SizedBox(height: 45* s,),
                        PrimaryButton(title: "Logout"),
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
