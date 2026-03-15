import 'package:get/get.dart';
import 'package:kivi_24/screens/wallet/views/rewards.dart';
import 'package:kivi_24/screens/wallet/views/top_up_points_one.dart';
import 'package:kivi_24/screens/wallet/views/transaction_history.dart';
import 'package:kivi_24/screens/wallet/views/wallet_analytics.dart';

import '../views/wallet.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  // List of your actual Screen Widgets
  final List screens = [
     Wallet(),
    TransactionHistory(),
    TopUpPointsOne(),
    Rewards(),
    WalletAnalytics(),
  ];

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
