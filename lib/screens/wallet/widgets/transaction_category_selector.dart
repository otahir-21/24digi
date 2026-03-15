import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';
import 'package:kivi_24/screens/recovery_ai/widgets/option_chip.dart';
import 'package:kivi_24/screens/wallet/controller/rewards_controller.dart';
import 'package:kivi_24/screens/wallet/controller/transaction_history_controller.dart';

class TransactionCategorySelector extends StatelessWidget {

  const TransactionCategorySelector({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionHistoryController>();
    final s = UIScale.of(context);
    Color activeColor = Color(0xff00D4AA);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16 * s),
      child: Obx(
            () => Row(
          children: controller.categories.map((category) {
            bool isSelected = controller.selectedCategory.value == category;

            return Padding(
              padding: EdgeInsets.only(right: 8 * s),
              child: OptionChip(
                title: category,
                fontSize: 12 * s,
                isSelected: isSelected,
                onTap: () => controller.selectCategory(category),
                fontColor: isSelected
                    ? Color(0xff0A0A12)
                    : const Color(0xff8888A0),
                backgroundColor: isSelected
                    ? activeColor
                    : const Color(0xffFFFFFF).withValues(alpha: 0.03),
                borderColor: const Color(0xffFFFFFF).withValues(alpha: 0.04),
                isSelectedBorderColor: activeColor,
                borderRadius: 16,
                height: 34 * s,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
