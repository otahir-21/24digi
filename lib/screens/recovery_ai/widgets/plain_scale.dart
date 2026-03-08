import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlainStaticScale extends StatelessWidget {
  final int maxNumber;
  final controller = Get.isRegistered<PlainScaleController>()
      ? Get.find<PlainScaleController>()
      : Get.put(PlainScaleController());

  PlainStaticScale({super.key, this.maxNumber = 10});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xff26313A),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(maxNumber + 1, (index) {
                return GestureDetector(
                  onTap: () => controller.selectValue(index),
                  behavior: HitTestBehavior.opaque,
                  child: Obx(() {
                    bool isSelected = controller.selectedIndex.value == index;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$index",
                          style: TextStyle(
                            fontFamily: "HelveticaNeue",
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFFC084FC)
                                : const Color(0xffA8B3BA),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            const SizedBox(width: 24, height: 6),
                            if (isSelected)
                              Positioned(
                                top: -5.5,
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC084FC),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}


class PlainScaleController extends GetxController {
  var selectedIndex = 0.obs;

  void selectValue(int index) {
    selectedIndex.value = index;
  }
}
