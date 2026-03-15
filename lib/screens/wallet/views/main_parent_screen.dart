import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

import '../controller/bottom_nav_controller.dart';

class MainParentScreen extends StatelessWidget {
  const MainParentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BottomNavController());
    final s = UIScale.of(context);

    return Scaffold(
      backgroundColor: const Color(0xff080C14),
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.screens.cast<Widget>(),
        ),
      ),
      bottomNavigationBar: Container(
        height: 80 * s,
        decoration: BoxDecoration(
          color: Color(0xff0C0C18).withValues(alpha: 0.08),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.04)),
          ),
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(controller, 0, "assets/icons/Wallet.png", "Wallet", s),
              _navItem(controller, 1, "assets/icons/history.png", "History", s),
              _centerTopUp(controller, s), // The Custom Center Button
              _navItem(controller, 3, "assets/icons/reward.png", "Rewards", s),
              _navItem(controller, 4, "assets/icons/analytics.png", "Analytics", s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BottomNavController controller,
    int index,
    String icon,
    String label,
    double s,
  ) {
    bool isSelected = controller.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            width: 24 * s,
            color: isSelected ? Colors.white : const Color(0xff8888A0),
          ),
          SizedBox(height: 4 * s),
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * s,
              color: isSelected ? Colors.white : const Color(0xff8888A0),
            ),
          ),
        ],
      ),
    );
  }

  // Specialized Center Top Up Item
  Widget _centerTopUp(BottomNavController controller, double s) {
    bool isSelected = controller.selectedIndex.value == 2;
    return GestureDetector(
      onTap: () => controller.changeIndex(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(0, -20 * s), // Lift it slightly
            child: Container(
              width: 54.75 * s,
              height: 54.75 * s,
              decoration: BoxDecoration(
                color: const Color(0xff00D4AA),
                borderRadius: BorderRadius.circular(16.85 * s),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff00D4AA).withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                "assets/icons/ArrowUpCircle.png",
                color: Colors.black,

              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -14*s),
            child: Text(
              "Top up",
              style: TextStyle(
                fontSize: 10 * s,
                color: isSelected
                    ? const Color(0xff00D4AA)
                    : const Color(0xff00D4AA),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
