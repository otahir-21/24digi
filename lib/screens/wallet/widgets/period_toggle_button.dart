import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import '../controller/wallet_analytics_controller.dart';

class PeriodToggleButton extends StatelessWidget {
  const PeriodToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    final WalletAnalyticsController controller = Get.find<WalletAnalyticsController>();

    return Obx(() {
      bool isWeek = controller.selectedPeriodIndex.value == 0;

      return Container(
        width: 180 * s,
        height: 36 * s,
        // padding: EdgeInsets.all(4 * s),
        decoration: BoxDecoration(
          color: const Color(0xff1A2233), // Background track
          borderRadius: BorderRadius.circular(12 * s),
        ),
        child: Stack(
          children: [
            // Sliding Background Selector
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: isWeek ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 84 * s,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff00D4AA), // Indigo active color
                  borderRadius: BorderRadius.circular(12 * s),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff6366F1).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),

            // Clickable Text Labels
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.updatePeriod(0),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        "Week",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: isWeek ? Color(0xff0A0A12) : const Color(0xff8888A0),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.updatePeriod(1),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Text(
                        "6 Months",
                        style: TextStyle(
                          fontFamily: "HelveticaNeue",
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w600,
                          color: !isWeek ? Color(0xff0A0A12) : const Color(0xff8888A0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
