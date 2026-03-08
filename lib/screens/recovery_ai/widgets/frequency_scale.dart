import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StaticFrequencyScale extends StatelessWidget {
  final int maxNumber;
  final controller = Get.isRegistered<ScaleController>()
      ? Get.find<ScaleController>()
      : Get.put(ScaleController());

  StaticFrequencyScale({super.key, this.maxNumber = 5});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned(
                    bottom: 0,
                    left: 3,
                    right: 3,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(color: const Color(0xff26313A),
                      borderRadius: BorderRadius.circular(16) ),
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
                          bool isSelected =
                              controller.selectedIndex.value == index;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Number Label
                              Text(
                                "$index",
                                style: TextStyle(
                                  fontFamily: "HelveticaNeue",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF6FFFE9)
                                      : const Color(0xff6B7680),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                clipBehavior:
                                    Clip.none,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      color: Color(0xff26313A),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      bottom: -8,
                                      child: Container(
                                        width: 24.08,
                                        height: 24.08,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF6FFFE9),
                                          shape: BoxShape.circle,
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Color(0x666FFFE9),
                                          //     blurRadius: 10,
                                          //     spreadRadius: 2,
                                          //   ),
                                          // ],
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
          ),
        ],
      ),
    );
  }
}

class ScaleController extends GetxController {
  // Store the selected index (e.g., 0, 1, 2, 3...)
  var selectedIndex = 0.obs;

  void selectValue(int index) {
    selectedIndex.value = index;
  }
}
