import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  List<SubscriptionDetailModel> subscriptionDetails = [
    SubscriptionDetailModel(detail: '820.96', unit: 'AED'),
    SubscriptionDetailModel(detail: 'Mar 5'),
    SubscriptionDetailModel(detail: '4'),
    SubscriptionDetailModel(
      detail: 'You have 4 active subscriptions - next billing in 4 days',
    ),
  ];

  List<PremiumSubscriptionDetailModel> premiumSubscriptionDetails = [
    PremiumSubscriptionDetailModel(detail: '24/7 Active'),
    PremiumSubscriptionDetailModel(detail: 'Mar 7, 2026'),
    PremiumSubscriptionDetailModel(detail: 'Critical'),
  ];

  List<SmartSubscriptionInsightModel> smartSubscriptionInsightDetails = [
    SmartSubscriptionInsightModel(
      "assets/icons/Icon (7).png",
      "You rarely use AI Models Pro — consider downgrading to save 36.99 AED/mo.",
      "Downgrade >",
    ),
    SmartSubscriptionInsightModel(
      "assets/icons/Icon8.png",
      "Upgrade to Premium Bundle and save 18% monthly.",
      "View Bundle >",
    ),
    SmartSubscriptionInsightModel(
      "assets/icons/Icon (9).png",
      "Your 24 Challenge subscription increased your active",
      "View Stats >",
    ),
  ];

  List<ActiveSubscriptions> activeSubscriptions = [
    ActiveSubscriptions("assets/icons/Bot.png", "C By AI", "3100.00", "Pro Plan", "Mar 7, 2026", "Active"),
    ActiveSubscriptions("assets/icons/Bot.png", "Ai Model", "3-.99", "Pro", "Mar 5, 2026", "Active"),
    ActiveSubscriptions("assets/icons/Bot.png", "24 Bracelet", "54.99", "Premium", "54.99", "Trail")
  ];
}

class SubscriptionDetailModel {
  final String detail;
  final String? unit;

  SubscriptionDetailModel({required this.detail, this.unit});
}

class PremiumSubscriptionDetailModel {
  final String detail;

  PremiumSubscriptionDetailModel({required this.detail});
}

class SmartSubscriptionInsightModel {
  final String icon;
  final String description;
  final String option;

  SmartSubscriptionInsightModel(this.icon, this.description, this.option);
}

class ActiveSubscriptions {
  final String icon;
  final String name;
  final String price;
  final String plan;
  final String nextPaymentDate;
  final String status;

  ActiveSubscriptions(this.icon, this.name, this.price, this.plan, this.nextPaymentDate, this.status);
}
