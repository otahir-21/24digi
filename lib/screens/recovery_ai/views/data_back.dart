import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/data_back_controller.dart';
import 'package:kivi_24/screens/recovery_ai/views/choose_plan.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/issue_type_card.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/plain_scale.dart';

import 'package:kivi_24/widgets/digi_pill_header.dart';
import '../widgets/primary_button.dart';

class DataBack extends StatelessWidget {
  DataBack({super.key});

  final controller = Get.put(DataBackController());

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
                  const DigiPillHeader(),
                  SizedBox(height: 20 * s),
                  Expanded(
                    child: ListView(
                      children: [
                        SizedBox(height: 30 * s),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s),
                          child: Text(
                            "Select your issue",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24 * s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12 * s),
                          child: Text(
                            "Choose the issue that best matches what you are experiencing. Then select a pain area, onset, and severity.",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffA8B3BA),
                            ),
                          ),
                        ),
                         SizedBox(height: 45 * s),
                        Text(
                          "Issue Type",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 18 * s,
                                mainAxisSpacing: 16 * s,
                                mainAxisExtent: 100 * s,
                              ),
                          itemCount: controller.issueType.length,
                          itemBuilder: (context, index) {
                            final issue = controller.issueType[index];
                            return Obx(
                              () => IssueTypeCard(
                                icon: issue.icon,
                                issue: issue.issue,
                                onTap: () => controller.toggleActivity(issue),
                                isSelected: issue.isSelected.value,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 45 * s),
                        Center(
                          child: Text(
                            "Pain Area",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18 * s,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        SizedBox(height: 45 * s),
                        Image.asset("assets/images/back_body.png"),
                        Text(
                          "When did it start?",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        Wrap(
                          spacing: 12 * s,
                          runSpacing: 12 * s,
                          children: controller.issueDuration.map((option) {
                            return Obx(
                              () => OptionChip(
                                borderRadius: 25,
                                height: 37 * s,
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.selectChip(option),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 45 * s),
                        Text(
                          "Severity",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18 * s,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15 * s),
                        PlainStaticScale(
                          selectedIndex: controller.severity,
                          onSelect: (val) => controller.severity.value = val,
                        ),
                        SizedBox(height: 45 * s),
                        PrimaryButton(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChoosePlan(),
                              ),
                            );
                          },
                          title: "Continue",
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
