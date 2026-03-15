import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class StaticFrequencyScale extends StatelessWidget {
  final int maxNumber;
  final controller = Get.isRegistered<ScaleController>()
      ? Get.find<ScaleController>()
      : Get.put(ScaleController());

  StaticFrequencyScale({super.key, this.maxNumber = 5});

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 8* s),
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
                      height: 6* s,
                      decoration: BoxDecoration(color: const Color(0xff26313A),
                      borderRadius: BorderRadius.circular(16* s) ),
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
                                  fontSize: 12* s,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF6FFFE9)
                                      : const Color(0xff6B7680),
                                ),
                              ),
                                SizedBox(height: 4* s),
                              Stack(
                                alignment: Alignment.bottomCenter,
                                clipBehavior:
                                    Clip.none,
                                children: [
                                  Container(
                                    width: 8* s,
                                    height: 14* s,
                                    decoration:  BoxDecoration(
                                      color: Color(0xff26313A),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6* s),
                                        topRight: Radius.circular(6* s),
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      bottom: -8* s,
                                      child: Container(
                                        width: 24.08* s,
                                        height: 24.08* s,
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
