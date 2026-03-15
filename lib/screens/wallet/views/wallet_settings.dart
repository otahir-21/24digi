import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/widgets/card.dart';
import 'package:kivi_24/screens/wallet/widgets/recent_activity_card.dart';

import '../../../core/utils/ui_scale.dart';
import '../../../widgets/header.dart';
import '../controller/wallet_settings_controller.dart';

class WalletSettings extends StatelessWidget {
  WalletSettings({super.key});

  final controller = Get.put(WalletSettingsController());

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Scaffold(
      backgroundColor: Color(0xff0E1215),
      body: SafeArea(
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
                      "Settings",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 20 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xffFFFFFF),
                      ),
                    ),
                    Text(
                      "Security, payment & transaction",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 12 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 45 * s),
                    RecentActivityCard(
                      horizontalPadding: 17 * s,
                      verticalPadding: 17 * s,
                      cardBorderColor: Color(
                        0xff00D4AA,
                      ).withValues(alpha: 0.08),
                      cardColor: Color(0xff00D4AA).withValues(alpha: 0.04),
                      prefixIcon: "assets/icons/verifiedd.png",
                      iconBgColor: Color(0xff00D4AA).withValues(alpha: 0.1),
                      title: "Account Verified",
                      description: "All systems verified • No anomalies",
                      suffixIcon: "assets/icons/verified_tick.png",
                    ),
                    SizedBox(height: 63 * s),
                    Text(
                      "SECURITY AND VERIFICATION",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    BaseCard(
                      verticalPadding: 15 * s,
                      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
                      backgroundColor: Color(
                        0xffFFFFFF,
                      ).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      child: Obx(
                        () => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.securityAndVerification.length,
                          separatorBuilder: (context, index) => Container(
                            margin: EdgeInsetsGeometry.symmetric(
                              vertical: 15 * s,
                            ),
                            height: 2,
                            color: Color(0xffFFFFFF).withValues(alpha: 0.02),
                          ),
                          itemBuilder: (context, index) {
                            final securityAndVerification =
                                controller.securityAndVerification[index];
                            return RecentActivityCard(
                              horizontalPadding: 15 * s,
                              prefixIcon: securityAndVerification.icon,
                              iconBgColor: securityAndVerification.themeColor
                                  .withValues(alpha: 0.063),
                              title: securityAndVerification.title,
                              description: securityAndVerification.description,
                              status: securityAndVerification.status,
                              statusBgColor: securityAndVerification.themeColor
                                  .withValues(alpha: 0.063),
                              statusColor: securityAndVerification.themeColor,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 46 * s),
                    Text(
                      "PAYMENT METHODS",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    BaseCard(
                      verticalPadding: 15 * s,
                      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
                      backgroundColor: Color(
                        0xffFFFFFF,
                      ).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      child: Obx(
                        () => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.paymentMethod.length,
                          separatorBuilder: (context, index) => Container(
                            margin: EdgeInsetsGeometry.symmetric(
                              vertical: 15 * s,
                            ),
                            height: 2,
                            color: Color(0xffFFFFFF).withValues(alpha: 0.02),
                          ),
                          itemBuilder: (context, index) {
                            final paymentMethod =
                                controller.paymentMethod[index];
                            return RecentActivityCard(
                              horizontalPadding: 15 * s,
                              prefixIcon: paymentMethod.icon,
                              iconBgColor: paymentMethod.themeColor.withValues(
                                alpha: 0.063,
                              ),
                              title: paymentMethod.title,
                              description: paymentMethod.description,
                              status: paymentMethod.status,
                              statusBgColor: paymentMethod.themeColor
                                  .withValues(alpha: 0.063),
                              statusColor: paymentMethod.themeColor,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 63 * s),
                    Text(
                      "TRANSPARENCY",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    BaseCard(
                      verticalPadding: 15 * s,
                      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
                      backgroundColor: Color(
                        0xffFFFFFF,
                      ).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      child: Obx(
                        () => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.transparency.length,
                          separatorBuilder: (context, index) => Container(
                            margin: EdgeInsetsGeometry.symmetric(
                              vertical: 15 * s,
                            ),
                            height: 2,
                            color: Color(0xffFFFFFF).withValues(alpha: 0.02),
                          ),
                          itemBuilder: (context, index) {
                            final securityAndVerification =
                                controller.transparency[index];
                            return RecentActivityCard(
                              horizontalPadding: 15 * s,
                              prefixIcon: securityAndVerification.icon,
                              iconBgColor: securityAndVerification.themeColor
                                  .withValues(alpha: 0.063),
                              title: securityAndVerification.title,
                              description: securityAndVerification.description,
                              suffixIcon: "assets/icons/arrow_right.png",
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 45 * s),
                    Text(
                      "CONNECTED SYSTEMS",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    BaseCard(
                      verticalPadding: 15 * s,
                      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
                      backgroundColor: Color(
                        0xffFFFFFF,
                      ).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      child: Obx(
                        () => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.connectedSystems.length,
                          separatorBuilder: (context, index) => Container(
                            margin: EdgeInsetsGeometry.symmetric(
                              vertical: 15 * s,
                            ),
                            height: 2,
                            color: Color(0xffFFFFFF).withValues(alpha: 0.02),
                          ),
                          itemBuilder: (context, index) {
                            final connectedSystems =
                                controller.connectedSystems[index];
                            return RecentActivityCard(
                              horizontalPadding: 15 * s,
                              prefixIcon: connectedSystems.icon,
                              iconBgColor: connectedSystems.themeColor
                                  .withValues(alpha: 0.063),
                              title: connectedSystems.title,
                              description: connectedSystems.description,
                              status: connectedSystems.status,
                              statusBgColor: connectedSystems.themeColor
                                  .withValues(alpha: 0.063),
                              statusColor: connectedSystems.themeColor,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 45 * s),
                    Text(
                      "NOTIFICATIONS",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 10 * s,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff555568),
                      ),
                    ),
                    SizedBox(height: 7 * s),
                    BaseCard(
                      verticalPadding: 15 * s,
                      borderColor: Color(0xffFFFFFF).withValues(alpha: 0.04),
                      backgroundColor: Color(
                        0xffFFFFFF,
                      ).withValues(alpha: 0.02),
                      borderRadius: 17 * s,
                      child: Obx(
                        () => ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.notification.length,
                          separatorBuilder: (context, index) => Container(
                            margin: EdgeInsetsGeometry.symmetric(
                              vertical: 15 * s,
                            ),
                            height: 2,
                            color: Color(0xffFFFFFF).withValues(alpha: 0.02),
                          ),
                          itemBuilder: (context, index) {
                            final notification = controller.notification[index];
                            return RecentActivityCard(
                              horizontalPadding: 15 * s,
                              prefixIcon: notification.icon,
                              iconBgColor: notification.themeColor.withValues(
                                alpha: 0.063,
                              ),
                              title: notification.title,
                              description: notification.description,
                              showToggleSuffix: true,
                              isSwitched: notification.toggle,
                              onToggle: (value) {
                                controller.toggleNotifications(value, index);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 46),
                    BaseCard(
                      horizontalPadding: 20 * s,
                      verticalPadding: 18 * s,
                      backgroundColor: Color(
                        0xff6366F1,
                      ).withValues(alpha: 0.04),
                      borderColor: Color(0xff6366F1).withValues(alpha: 0.06),
                      child: Text(
                        "24DIGI uses verified systems and encrypted payment processing to ensure secure point purchases. Your financial data is never shared without consent.",
                        style: TextStyle(
                          fontSize: 11 * s,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff8888a0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20 * s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
