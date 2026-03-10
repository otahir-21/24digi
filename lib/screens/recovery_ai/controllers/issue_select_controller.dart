import 'package:get/get.dart';

class IssueSelectController extends GetxController {
  var subscriptionStatus = SubscriptionModel(status: "Inactive",
      painAccess: "Temporary free for now",
      periodEnd: "Not set",
      message: "Temporary plans metrics to improve plan recommendations");
}

//Model
class SubscriptionModel {
  final String status;
  final String painAccess;
  final String periodEnd;
  final String message;

  SubscriptionModel({
    required this.status,
    required this.painAccess,
    required this.periodEnd,
    required this.message,
  });
}