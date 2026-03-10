import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/screens/subscribe/controller/subscription_controller.dart';
import 'package:kivi_24/screens/subscribe/widgets/bundles_card.dart';

import '../../../widgets/header.dart';
import '../../recovery_ai/widgets/primary_button.dart';
import '../widgets/active_subscription_card.dart';
import '../widgets/base_card.dart';
import '../widgets/subscription_details_card.dart';
import '../widgets/subscription_insight_details_card.dart';

class Subscription extends StatelessWidget {
  Subscription({super.key});

  final controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0E1215),
      body: SafeArea(
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
                    BaseCard(
                      title: "Subscriptions",
                      status: "24DIGI",
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SubscriptionDetailsCard(
                                  icon: 'assets/icons/Wallet.png',
                                  title: 'Monthly Cost',
                                  detail:
                                      controller.subscriptionDetails[0].detail,
                                  unit: controller.subscriptionDetails[0].unit,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: SubscriptionDetailsCard(
                                  icon: 'assets/icons/CalendarClock.png',
                                  title: 'Next Billing',
                                  detail:
                                      controller.subscriptionDetails[1].detail,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: SubscriptionDetailsCard(
                                  icon: 'assets/icons/Layers3.png',
                                  title: 'Active Plans',
                                  detail:
                                      controller.subscriptionDetails[2].detail,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          ),

                          const SizedBox(height: 12),

                          SubscriptionDetailsCard(
                            icon: 'assets/icons/TrendingUp.png',
                            title: 'Insight',
                            detail: controller.subscriptionDetails[3].detail,
                            detailsFontSize: 15,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45),
                    BaseCard(
                      cardGradientColorList: [
                        Color(0xff002C22).withValues(alpha: 0.4),
                        Color(0xff022F2E).withValues(alpha: 0.3),
                      ],
                      cardBorderColor: Color(0xff00BC7D).withValues(alpha: 0.2),
                      topBorderWidth: 3,
                      prefixIcon: "assets/icons/ShieldCheck.png",
                      iconGradient: LinearGradient(
                        begin: AlignmentGeometry.topCenter,
                        end: AlignmentGeometry.bottomCenter,
                        colors: [Color(0xff00BC7D), Color(0xff009689)],
                      ),
                      title: "SafeLife Premium",
                      titleFontSize: 19,
                      description: "Emerging monitoring & response",
                      status: "Coverage Active",
                      statusFontSize: 12,
                      statusFontColor: Color(0xff00D492),
                      statusBackgroundColor: Color(
                        0xff00BC7D,
                      ).withValues(alpha: 0.1),
                      statusBorderColor: Color(
                        0xff00BC7D,
                      ).withValues(alpha: 0.2),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SubscriptionDetailsCard(
                                  icon: 'assets/icons/Wallet.png',
                                  title: 'Monitoring',
                                  detailsFontSize: 14,
                                  showTitleBelow: true,
                                  detail: controller
                                      .premiumSubscriptionDetails[0]
                                      .detail,
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: SubscriptionDetailsCard(
                                  icon: 'assets/icons/CalendarClock.png',
                                  title: 'Renewal',
                                  detailsFontSize: 14,
                                  showTitleBelow: true,
                                  detail: controller
                                      .premiumSubscriptionDetails[1]
                                      .detail,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: SubscriptionDetailsCard(
                                  icon: 'assets/icons/CalendarClock.png',
                                  title: 'Priority',
                                  showTitleBelow: true,
                                  detailsFontSize: 14,
                                  detail: controller
                                      .premiumSubscriptionDetails[2]
                                      .detail,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          BaseCard(
                            prefixIcon: "assets/icons/AlertTriangle.png",
                            prefixIconWithBase: false,
                            title:
                                "This is a critical safety subscription. Cancellation requires additional verification to ensure your safety coverage continues.",
                            titleFontColor: Color(
                              0xffFFD230,
                            ).withValues(alpha: 0.8),
                            cardBorderColor: Color(
                              0xfffe9a00,
                            ).withValues(alpha: 0.15),
                            cardGradientColorList: [
                              Color(0xfffe9a00).withValues(alpha: 0.05),
                              Color(0xfffe9a00).withValues(alpha: 0.05),
                            ],
                            titleFontSize: 12,
                            bottomSpacing: false,
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45),
                    BaseCard(
                      cardBorderColor: Color(0xff1e2a3d),
                      cardGradientColorList: [
                        Color(0xff0f1520),
                        Color(0xff0f1520),
                      ],
                      prefixIcon: "assets/icons/Bot.png",
                      iconGradient: LinearGradient(
                        colors: [Color(0xff0092B8), Color(0xff00786F)],
                      ),
                      title: "C By AI Assistant",
                      titleFontSize: 20,
                      description: "Smart subscription insight",
                      child: Column(
                        spacing: 12,
                        children: [
                          SubscriptionInsightDetailsCard(
                            icon: controller
                                .smartSubscriptionInsightDetails[0]
                                .icon,
                            description: controller
                                .smartSubscriptionInsightDetails[0]
                                .description,
                            option: controller
                                .smartSubscriptionInsightDetails[0]
                                .option,
                          ),
                          SubscriptionInsightDetailsCard(
                            iconBgColor: Color(
                              0xffD4A574,
                            ).withValues(alpha: 0.1),
                            iconBorderColor: Color(
                              0xffD4A574,
                            ).withValues(alpha: 0.2),
                            icon: controller
                                .smartSubscriptionInsightDetails[1]
                                .icon,
                            description: controller
                                .smartSubscriptionInsightDetails[1]
                                .description,
                            option: controller
                                .smartSubscriptionInsightDetails[1]
                                .option,
                          ),
                          SubscriptionInsightDetailsCard(
                            iconBgColor: Color(
                              0xffFF6900,
                            ).withValues(alpha: 0.1),
                            iconBorderColor: Color(
                              0xffFF6900,
                            ).withValues(alpha: 0.2),
                            icon: controller
                                .smartSubscriptionInsightDetails[2]
                                .icon,
                            description: controller
                                .smartSubscriptionInsightDetails[2]
                                .description,
                            option: controller
                                .smartSubscriptionInsightDetails[2]
                                .option,
                          ),
                          SizedBox(height: 30),
                          PrimaryButton(
                            onTap: () {},
                            title: "Optimize My Plan",
                            isGradient: true,
                            gradientColorList: [
                              Color(0xffD4A574),
                              Color(0xffC08B5C),
                            ],
                            height: 42,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontColor: Color(0xff080C14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 45),
                    ActiveSubscriptionCard(
                      prefixIcon: controller.activeSubscriptions[0].icon,
                      iconGradient: LinearGradient(
                        colors: [Color(0xff0092B8), Color(0xff00786F)],
                      ),
                      title: controller.activeSubscriptions[0].name,
                      plan: controller.activeSubscriptions[0].plan,
                      status: "Active",
                      price: controller.activeSubscriptions[0].price,
                      unit: "/mo",
                      nextPaymentDate:
                          controller.activeSubscriptions[0].nextPaymentDate,
                    ),
                    SizedBox(height: 16),
                    ActiveSubscriptionCard(
                      prefixIcon: controller.activeSubscriptions[1].icon,
                      iconGradient: LinearGradient(
                        colors: [Color(0xff4F39F6), Color(0xff7008E7)],
                      ),
                      title: controller.activeSubscriptions[1].name,
                      plan: controller.activeSubscriptions[1].plan,
                      status: "Active",
                      price: controller.activeSubscriptions[1].price,
                      unit: "/mo",
                      nextPaymentDate:
                          controller.activeSubscriptions[1].nextPaymentDate,
                    ),
                    SizedBox(height: 16),
                    ActiveSubscriptionCard(
                      prefixIcon: controller.activeSubscriptions[2].icon,
                      iconGradient: LinearGradient(
                        colors: [Color(0xffEC003F), Color(0xffEC003F)],
                      ),
                      title: controller.activeSubscriptions[2].name,
                      plan: controller.activeSubscriptions[2].plan,
                      status: "Trail",
                      price: controller.activeSubscriptions[2].price,
                      unit: "/mo",
                      nextPaymentDate:
                          controller.activeSubscriptions[2].nextPaymentDate,
                    ),
                    SizedBox(height: 45),
                    BaseCard(
                      title: "Bundles & Savings",
                      titleFontSize: 19,
                      titleFontColor: Color(0xffE8ECF4),
                      description: "Save more by combining your subscriptions",
                      titleTrailingIcon: "assets/icons/Gift.png",
                      child: BundlesCard(title: "title", status: "save 32", description: "148.99",),
                    ),
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
