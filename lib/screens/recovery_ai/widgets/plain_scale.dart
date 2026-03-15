import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kivi_24/core/utils/ui_scale.dart';

class PlainStaticScale extends StatelessWidget {
  final int maxNumber;
  final RxInt selectedIndex; // Pass the specific RxInt from screen controller
  final Function(int) onSelect; // Callback for when a value is tapped

  const PlainStaticScale({
    super.key,
    this.maxNumber = 10,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = UIScale.of(context);
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        // Background Track
        Container(
          height: 6 * s,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xff26313A),
            borderRadius: BorderRadius.circular(16 * s),
          ),
        ),
        // Numbers and Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(maxNumber + 1, (index) {
            return GestureDetector(
              onTap: () => onSelect(index),
              behavior: HitTestBehavior.opaque,
              child: Obx(() {
                bool isSelected = selectedIndex.value == index;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$index",
                      style: TextStyle(
                        fontFamily: "HelveticaNeue",
                        fontSize: 14 * s,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? const Color(0xFFC084FC)
                            : const Color(0xffA8B3BA),
                      ),
                    ),
                    SizedBox(height: 18 * s),
                    Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(width: 24 * s, height: 6 * s),
                        if (isSelected)
                          Positioned(
                            top: -5.5 * s,
                            child: Container(
                              width: 15 * s,
                              height: 15 * s,
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
  }
}
