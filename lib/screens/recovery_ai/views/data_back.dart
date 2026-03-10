import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/data_back_controller.dart';
import 'package:kivi_24/screens/recovery_ai/controllers/data_front_controller.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/issue_type_card.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/plain_scale.dart';

import '../../../widgets/header.dart';
import '../widgets/primary_button.dart';

class DataBack extends StatelessWidget {
  DataBack({super.key});

  final controller = Get.put(DataBackController());

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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: const Text(
                            "Select your issue",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0),
                          child: const Text(
                            "choose the issue that best matches what you are experiencing. Then select a pain area, onset, and severity.",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xffA8B3BA),
                            ),
                          ),
                        ),
                        const SizedBox(height: 45),
                        const Text(
                          "Issue Type",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        const SizedBox(height: 15),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 100,
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
                        const SizedBox(height: 45),
                        Center(
                          child: const Text(
                            "Pain Area",
                            style: TextStyle(
                              fontFamily: "HelveticaNeue",
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffEAF2F5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 45),
                        Image.asset("assets/images/back_body.png"),
                        const Text(
                          "When did it start?",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15,),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: controller.issueDuration.map((option) {
                            return Obx(
                                  () => OptionChip(
                                    borderRadius: 25,
                                height: 37,
                                title: option.title,
                                isSelected: option.isSelected.value,
                                onTap: () => controller.selectChip(option),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 45),
                        const Text(
                          "Severity",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xffEAF2F5),
                          ),
                        ),
                        SizedBox(height: 15,),
                        PlainStaticScale(),
                        SizedBox(height: 45),
                        PrimaryButton(title: "Continue"),
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
